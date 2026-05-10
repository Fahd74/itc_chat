import 'package:itc_chat/features/chat/domain/entities/chat_message.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatUpdated extends ChatState {
  final List<ChatMessage> messages;
  final List<ChatAttachment> draftAttachments;
  ChatUpdated(this.messages, {this.draftAttachments = const []});
}

// حالة مؤقتة تظهر عندما ننتظر رد المساعد
class ChatWaitingForBot extends ChatState {
  final List<ChatMessage> messages;
  ChatWaitingForBot(this.messages);
}