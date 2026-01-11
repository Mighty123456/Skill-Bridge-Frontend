import 'package:flutter/material.dart';
import '../../../../shared/themes/app_theme.dart';
import '../../../../widgets/premium_app_bar.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  static const String routeName = '/chat-list';

  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Mock data for previous chats
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'recipientName': 'John Doe',
      'recipientImage': null,
      'lastMessage': 'Can you come tomorrow at 10 AM?',
      'time': '10:30 AM',
      'unreadCount': 2,
    },
    {
      'id': '2',
      'recipientName': 'Alice Smith',
      'recipientImage': 'https://i.pravatar.cc/150?u=2',
      'lastMessage': 'The job is completed. Please verify.',
      'time': 'Yesterday',
      'unreadCount': 0,
    },
    {
      'id': '3',
      'recipientName': 'Mike Johnson',
      'recipientImage': null,
      'lastMessage': 'Thanks for the quick service!',
      'time': '2 days ago',
      'unreadCount': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: const PremiumAppBar(
        title: 'Messages',
        showBackButton: true,
      ),
      body: _chats.isEmpty
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

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          ChatScreen.routeName,
          arguments: {
            'chatId': chat['id'],
            'recipientName': chat['recipientName'],
          },
        );
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
                  backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
                  backgroundImage: chat['recipientImage'] != null
                      ? NetworkImage(chat['recipientImage'])
                      : null,
                  child: chat['recipientImage'] == null
                      ? Text(
                          chat['recipientName'][0],
                          style: TextStyle(
                            color: AppTheme.colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                if (chat['unreadCount'] > 0)
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
                        chat['recipientName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        chat['time'],
                        style: TextStyle(
                          color: chat['unreadCount'] > 0 ? AppTheme.colors.primary : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: chat['unreadCount'] > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: chat['unreadCount'] > 0 ? Colors.black87 : Colors.grey[600],
                            fontSize: 14,
                            fontWeight: chat['unreadCount'] > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (chat['unreadCount'] > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.colors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat['unreadCount'].toString(),
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
