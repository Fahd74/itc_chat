import 'package:itc_chat/features/chat/data/datasources/chat_datasource.dart';
import 'package:itc_chat/features/chat/domain/repositories/chat_repository.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource _dataSource;

  ChatRepositoryImpl({required ChatDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<String> sendMessage(String message, {List<ChatAttachment>? attachments}) async {
    try {
      return await _dataSource.sendMessage(message, attachments: attachments);
    } catch (e) {
      return 'حدث خطأ أثناء الاتصال بالمساعد الذكي: ${e.toString()}';
    }
  }
}
