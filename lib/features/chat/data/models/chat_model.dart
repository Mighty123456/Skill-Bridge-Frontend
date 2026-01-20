class ChatModel {
  final String id;
  final List<dynamic> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, dynamic> unreadCounts;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCounts,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'],
      participants: json['participants'] ?? [],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime'] ?? DateTime.now().toIso8601String()),
      unreadCounts: json['unreadCounts'] != null ? Map<String, dynamic>.from(json['unreadCounts']) : {},
    );
  }
}
