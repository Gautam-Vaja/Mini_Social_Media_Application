class ChatModel {
  final String name;
  final String message;
  final String image;
  final String time;
  final int unread;
  final bool isOnline;
  final bool isRead;

  ChatModel({
    required this.name,
    required this.message,
    required this.image,
    required this.time,
    this.unread = 0,
    this.isOnline = false,
    this.isRead = false,
  });
}
