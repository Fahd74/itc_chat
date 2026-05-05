import 'package:itc_chat/features/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase({required ChatRepository repository})
      : _repository = repository;

  Future<String> call(String message) async {
    return await _repository.sendMessage(message);
  }
}
