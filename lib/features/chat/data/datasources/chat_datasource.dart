import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';

/// Abstract interface for chat data sources.
/// Both [GeminiDataSource] and [BackendDataSource] implement this,
/// allowing the repository to swap backends without code changes.
abstract class ChatDataSource {
  Future<String> sendMessage(String userMessage, {List<ChatAttachment>? attachments});
}
