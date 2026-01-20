import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../../shared/themes/app_theme.dart';
import '../../../../widgets/premium_app_bar.dart';
import 'chat_screen.dart';
import '../../data/chat_service.dart';
import '../../data/models/chat_model.dart';
import '../../../auth/data/auth_service.dart';
import '../../../../core/utils/encryption_helper.dart';

class ChatListScreen extends StatefulWidget {
  static const String routeName = '/chat-list';

  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  
  List<ChatModel> _chats = [];
  bool _isLoading = true;
  bool _isNavigating = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 1. Try to get ID from token first (failsafe)
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
           debugPrint('Token parse error in list: $e');
         }
      }

      // 2. Fetch latest profile data if needed
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
      
      final chats = await _chatService.getChats();
      if (mounted) {
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error loading chat list: $e');
      }
    }
  }

  // Helper to parse JWT (copied from ChatScreen)
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

  Map<String, dynamic> _getRecipient(ChatModel chat) {
    if (_currentUserId == null) return {};
    
    // Debug print if needed
    // debugPrint('Me: $_currentUserId, Participants: ${chat.participants.map((p) => p['_id']).toList()}');

    final recipient = chat.participants.firstWhere(
      (p) => p['_id'] != _currentUserId,
      orElse: () => {},
    );
    return recipient;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (now.difference(time).inDays < 7) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][time.weekday - 1];
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: const PremiumAppBar(
        title: 'Messages',
        showBackButton: true,
        hideChatAction: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _chats.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    return _buildChatTile(chat);
                  },
                ),
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    final recipient = _getRecipient(chat);
    final recipientName = recipient['name'] ?? 'Unknown User';
    final recipientImage = recipient['profileImage']; 
    // Fix profile image URL if it's partial or needs base URL? 
    // Assuming full URL or handling elsewhere. The mock had 'https://...'
    // If backend returns incomplete path (e.g. 'uploads/...'), we should prepend base URL. But let's assume raw string for now
    
    final unreadCount = chat.unreadCounts[_currentUserId] ?? 0;

    return InkWell(
      onTap: () async {
        if (_isNavigating) return;
        _isNavigating = true;
        try {
          await Navigator.pushNamed(
            context,
            ChatScreen.routeName,
            arguments: {
              'chatId': chat.id,
              'recipientName': recipientName,
              'recipientImage': recipientImage,
              'recipientId': recipient['_id'],
            },
          );
          // Refresh on return
          _loadData();
        } finally {
          _isNavigating = false;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.colors.primary.withValues(alpha: 0.1),
                  backgroundImage: recipientImage != null
                      ? NetworkImage(recipientImage) // If not valid URL this might crash? Use NetworkImage safely?
                      : null,
                  child: recipientImage == null
                      ? Text(
                          recipientName.isNotEmpty ? recipientName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: AppTheme.colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppTheme.colors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        recipientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          color: unreadCount > 0 ? AppTheme.colors.primary : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          EncryptionHelper.decryptMessage(chat.lastMessage),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.colors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
