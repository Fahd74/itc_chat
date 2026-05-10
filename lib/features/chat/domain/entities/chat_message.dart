import 'chat_attachment.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<ChatAttachment> attachments;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.attachments = const [],
  });
}