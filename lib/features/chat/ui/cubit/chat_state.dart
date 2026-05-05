import 'package:itc_chat/features/chat/domain/entities/chat_message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatUpdated extends ChatState {
  final List<ChatMessage> messages;
  ChatUpdated(this.messages);
}

// حالة مؤقتة تظهر عندما ننتظر رد المساعد
class ChatWaitingForBot extends ChatState {
  final List<ChatMessage> messages;
  ChatWaitingForBot(this.messages);
}