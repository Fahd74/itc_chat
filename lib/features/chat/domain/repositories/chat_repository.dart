import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';

abstract class ChatRepository {
  Future<String> sendMessage(String message, {List<ChatAttachment>? attachments});
}
