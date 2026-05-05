import 'package:itc_chat/features/chat/data/datasources/gemini_datasource.dart';
import 'package:itc_chat/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final GeminiDataSource _dataSource;

  ChatRepositoryImpl({required GeminiDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<String> sendMessage(String message) async {
    try {
      return await _dataSource.sendMessage(message);
    } catch (e) {
      return 'حدث خطأ أثناء الاتصال بالمساعد الذكي: ${e.toString()}';
    }
  }
}
