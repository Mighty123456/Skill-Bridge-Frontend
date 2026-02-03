class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final bool isDelivered;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
    this.isDelivered = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: (json['readBy'] as List?)?.isNotEmpty ?? false,
      isDelivered: (json['deliveredTo'] as List?)?.isNotEmpty ?? false,
    );
  }
}
