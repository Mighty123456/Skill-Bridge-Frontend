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

    if (_chatId != null) {
      _socketService.joinChat(_chatId!);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    if (_chatId != null) _socketService.leaveChat(_chatId!);
    _socketService.offMessageReceived();
    // _socketService.disconnect(); // Don't disconnect, might be used in list screen? actually good to keep connected
    
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
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        // Modern White AppBar as requested
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
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
             const SizedBox(width: 10),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     displayRecipientName,
                     style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                     overflow: TextOverflow.ellipsis,
                   ),
                   Row(
                     children: [
                       Container(
                         width: 8, height: 8,
                         decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                       ),
                       const SizedBox(width: 4),
                       const Text(
                         'Online',
                         style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                       ),
                     ],
                   ),
                 ],
               ),
             ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFECE5DD),
          ),
          
          Column(
            children: [
              Expanded(
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
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
      text = DateFormat('MMM d, yyyy').format(date);
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5FE),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFFD9FDD3) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                EncryptionHelper.decryptMessage(message.text),
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('h:mm a').format(message.createdAt.toLocal()),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                   if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all, size: 14, color: Colors.blue),
                   ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.blueAccent, size: 28),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_messageController.value.text.isNotEmpty || true)
             GestureDetector(
               onTap: _sendMessage,
               child: Container(
                 padding: const EdgeInsets.all(10),
                 decoration: BoxDecoration(
                   color: AppTheme.colors.primary,
                   shape: BoxShape.circle,
                 ),
                 child: _isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
               ),
             ),
        ],
      ),
    );
  }
}
