class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'],
      chatId: json['chatId'],
      senderId: json['senderId'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
