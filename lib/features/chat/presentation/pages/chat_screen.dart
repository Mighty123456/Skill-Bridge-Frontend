import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../../shared/themes/app_theme.dart';
import '../../data/chat_service.dart';
import '../../data/models/message_model.dart';
import '../../data/socket_service.dart';
import '../../../../core/utils/encryption_helper.dart';
import '../../../auth/data/auth_service.dart';
import 'dart:async';

import 'package:skillbridge_mobile/widgets/premium_loader.dart';

class ChatScreen extends StatefulWidget {
  static const String routeName = '/chat';
  final Map<String, dynamic> chatData;

  const ChatScreen({super.key, required this.chatData});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  List<MessageModel> _messages = [];
  String? _currentUserId;
  bool _isLoading = true;
  Timer? _refreshTimer;
  String? _chatId;
  bool _isSending = false;

  String? _recipientName;
  String? _recipientImage;

  final SocketService _socketService = SocketService();
  
  @override
  void initState() {
    super.initState();
    _chatId = widget.chatData['chatId'];
    _recipientName = widget.chatData['recipientName'];
    _recipientImage = widget.chatData['recipientImage'];
    
    _initSocket();
    _loadData();
    
    // Fallback polling (less frequent now)
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if(mounted && _chatId != null) _refreshMessages();
    });
  }
  
  Future<void> _initSocket() async {
    await _socketService.connect();
    
    _socketService.onMessageReceived((data) {
      if (mounted) {
         // Convert raw json to model
         final newMessage = MessageModel.fromJson(data);
         
         // Avoid duplicates if we just sent it via HTTP and added it manually
         if (_messages.any((m) => m.id == newMessage.id)) {
           return;
         }

         setState(() {
             _messages.add(newMessage);
         });
         _scrollToBottom();
      }
    });

    _socketService.onMessageRead((data) {
       if (data != null && mounted) {
          final List<dynamic> ids = data['messageIds'] ?? [];
          
          setState(() {
             for (int i = 0; i < _messages.length; i++) {
                if (ids.contains(_messages[i].id)) {
                   // Create new instance with updated status (since MessageModel is final)
                   _messages[i] = MessageModel(
                      id: _messages[i].id, 
                      chatId: _messages[i].chatId, 
                      senderId: _messages[i].senderId, 
                      text: _messages[i].text, 
                      createdAt: _messages[i].createdAt,
                      isRead: true, // Mark as read
                      isDelivered: true, // Read implies delivered
                   );
                }
             }
          });
       }
    });

    if (_chatId != null) {
      _socketService.joinChat(_chatId!);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    if (_chatId != null) _socketService.leaveChat(_chatId!);
    _socketService.offMessageReceived();
    _socketService.offMessageRead();
    
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
      try {
           // ... (User ID logic same as before) ...
           // Try to get ID from token first (failsafe)
           final token = await AuthService.getToken();
           if (token != null) {
              try {
                final payload = _parseJwt(token);
                if (payload.containsKey('userId')) {
                   _currentUserId = payload['userId'];
                } else if (payload.containsKey('id')) {
                   _currentUserId = payload['id'];
                } else if (payload.containsKey('_id')) {
                   _currentUserId = payload['_id'];
                }
              } catch (e) {
                 debugPrint('Token parse error: $e');
              }
           }

           if (_currentUserId == null) {
              final userResponse = await _authService.getMe();
              if (userResponse['success'] == true) {
                 final data = userResponse['data'];
                 if (data is Map && data.containsKey('user')) {
                    _currentUserId = data['user']['_id'];
                 } else if (data is Map && data.containsKey('_id')) {
                    _currentUserId = data['_id'];
                 }
              }
           }
           
           // If chatId is null, try to initiate
           if (_chatId == null && widget.chatData['recipientId'] != null) {
              try {
                  final String? jobId = widget.chatData['jobId'];
                  final chat = await _chatService.initiateChat(widget.chatData['recipientId'], jobId: jobId);
                  _chatId = chat.id;
                  _socketService.joinChat(_chatId!); // Join socket room!

                  if (_currentUserId != null && chat.participants.isNotEmpty) {
                    final otherUser = chat.participants.firstWhere(
                      (p) => p['_id'] != _currentUserId,
                      orElse: () => null,
                    );
                    if (otherUser != null) {
                      setState(() {
                        _recipientName = otherUser['name'];
                        _recipientImage = otherUser['profileImage'];
                      });
                    }
                  }
              } catch (e) {
                  debugPrint('Error initiating chat: $e');
              }
           } else if (_chatId != null) {
              _socketService.joinChat(_chatId!);
           }

           if (_chatId != null) {
            await _refreshMessages();
           }
           
           if (mounted) {
             setState(() {
                 _isLoading = false;
             });
             _scrollToBottom();
           }
      } catch (e) {
          debugPrint('Error loading chat data: $e');
          if (mounted) setState(() => _isLoading = false);
      }
  }

  // Helper to parse JWT
  Map<String, dynamic> _parseJwt(String token) {
      final parts = token.split('.');
      if (parts.length != 3) {
        return {};
      }
      final payload = _decodeBase64(parts[1]);
      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        return {};
      }
      return payloadMap;
  }

  String _decodeBase64(String str) {
      String output = str.replaceAll('-', '+').replaceAll('_', '/');
      switch (output.length % 4) {
        case 0:
          break;
        case 2:
          output += '==';
          break;
        case 3:
          output += '=';
          break;
        default:
          throw Exception('Illegal base64url string!"');
      }
      return utf8.decode(base64Url.decode(output));
  }

  Future<void> _refreshMessages() async {
      if (_chatId == null) return;
      try {
          final messages = await _chatService.getMessages(_chatId!);
          if (mounted) {
              setState(() {
                  _messages = messages;
                  // Ensure sorted by date
                  _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              });
          }
      } catch (e) {
          debugPrint('Error refreshing messages: $e');
      }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200, 
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    if (_chatId == null) {
        await _loadData();
        if (_chatId == null) {
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to start chat. Please try again.')));
          }
          return;
        }
    }

    final text = _messageController.text;
    _messageController.clear();
    setState(() => _isSending = true);

    try {
      // Encrypt
      final encryptedText = EncryptionHelper.encryptMessage(text);
      
      // Use HTTP Service for reliable sending
      final sentMessage = await _chatService.sendMessage(_chatId!, encryptedText);

      if (mounted) {
         setState(() {
             _isSending = false;
             _messages.add(sentMessage);
         });
         _scrollToBottom();
      }
    } catch (e) {
       if (mounted) {
         setState(() => _isSending = false);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayRecipientName = _recipientName ?? widget.chatData['recipientName'] ?? 'Unknown User';
    final displayRecipientImage = _recipientImage ?? widget.chatData['recipientImage'];

    return Scaffold(
      backgroundColor: const Color(0xFFE2E5E9), // WA-like background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
             CircleAvatar(
               radius: 18,
               backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
               backgroundImage: displayRecipientImage != null ? NetworkImage(displayRecipientImage) : null,
               child: displayRecipientImage == null ? Text(
                 displayRecipientName.isNotEmpty ? displayRecipientName[0].toUpperCase() : '?', 
                 style: TextStyle(color: AppTheme.colors.primary, fontWeight: FontWeight.bold, fontSize: 14)
               ) : null,
             ),
             const SizedBox(width: 12),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     displayRecipientName,
                     style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600),
                     overflow: TextOverflow.ellipsis,
                   ),
                   const SizedBox(height: 2),
                   // Optional: Last seen or Online status
                 ],
               ),
             ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.blueAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
            ? Center(child: PremiumLoader(color: AppTheme.colors.primary)) 
            : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _currentUserId;
                final showDate = index == 0 || !_isSameDay(_messages[index - 1].createdAt, message.createdAt);
                
                return Column(
                  children: [
                    if (showDate) _buildDateHeader(message.createdAt),
                    _buildMessageBubble(message, isMe),
                  ],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    String text;
    if (_isSameDay(now, date)) {
      text = 'Today';
    } else if (_isSameDay(now.subtract(const Duration(days: 1)), date)) {
      text = 'Yesterday';
    } else {
      text = DateFormat('MMMM d, yyyy').format(date);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final timeStr = DateFormat('h:mm a').format(message.createdAt.toLocal());
    
    // Status Logic
    // Default: Single Tick (Sent)
    // If Delivered -> Double Grey
    // If Read -> Double Blue
    IconData statusIcon = Icons.check_rounded;
    Color statusColor = Colors.grey[400]!;
    
    if (message.isRead) {
       statusIcon = Icons.done_all_rounded;
       statusColor = Colors.blue; 
    } else if (message.isDelivered) {
       statusIcon = Icons.done_all_rounded;
       statusColor = Colors.grey[400]!;
    } else {
       statusIcon = Icons.check_rounded;
       statusColor = Colors.grey[400]!;
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Card(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white, // WA Green for me
          elevation: 1,
          shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.only(
               topLeft: const Radius.circular(8),
               topRight: const Radius.circular(8),
               bottomLeft: isMe ? const Radius.circular(8) : Radius.zero,
               bottomRight: isMe ? Radius.zero : const Radius.circular(8),
             ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // Align contents to end for timestamp placement
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  EncryptionHelper.decryptMessage(message.text),
                  style: const TextStyle(
                    color: Colors.black87, // WA Text is black
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(statusIcon, size: 16, color: statusColor),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {}, // Add attachment logic later
              borderRadius: BorderRadius.circular(24),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[100],
                child: Icon(Icons.add_rounded, color: Colors.grey[600], size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.transparent),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 16),
                  onChanged: (val) {
                     setState(() {}); // Rebuild to update send button state
                  },
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _messageController.text.trim().isEmpty ? null : _sendMessage,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: _messageController.text.trim().isEmpty 
                  ? Colors.grey[200] 
                  : AppTheme.colors.primary,
                child: _isSending 
                   ? const PremiumLoader(size: 20, color: Colors.white)
                   : Icon(
                       Icons.send_rounded, 
                       color: _messageController.text.trim().isEmpty ? Colors.grey[400] : Colors.white, 
                       size: 22
                     ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
