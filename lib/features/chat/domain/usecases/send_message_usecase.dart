import 'package:itc_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase({required ChatRepository repository})
      : _repository = repository;

  Future<String> call(String message, {List<ChatAttachment>? attachments, String? model}) async {
    return await _repository.sendMessage(message, attachments: attachments, model: model);
  }
}
