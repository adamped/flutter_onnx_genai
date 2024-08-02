class Message {
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final int messageId;

  Message({
    required this.text,
    required this.timestamp,
    required this.isMe,
    required this.messageId,
  });
}
