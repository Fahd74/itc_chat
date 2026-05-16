import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'chat_datasource.dart';

/// Routes messages to the appropriate AI provider based on the selected model.
/// 
/// Also provides automatic fallback: if the primary provider fails,
/// it tries the other one before giving up.
class HybridDataSource implements ChatDataSource {
  final ChatDataSource geminiDataSource;
  final ChatDataSource groqDataSource;

  HybridDataSource({
    required this.geminiDataSource,
    required this.groqDataSource,
  });

  /// Returns true if the model should be handled by Groq.
  bool _isGroqModel(String? model) {
    if (model == null) return false;
    return model.startsWith('llama') || 
           model.startsWith('mixtral') || 
           model.startsWith('gemma');
  }

  @override
  Future<String> sendMessage(String userMessage, {List<ChatAttachment>? attachments, String? model}) async {
    final ChatDataSource primary;
    final ChatDataSource fallback;

    if (_isGroqModel(model)) {
      primary = groqDataSource;
      fallback = geminiDataSource;
    } else {
      primary = geminiDataSource;
      fallback = groqDataSource;
    }

    try {
      return await primary.sendMessage(userMessage, attachments: attachments, model: model);
    } catch (e) {
      // If primary fails, try fallback with its default model
      try {
        return await fallback.sendMessage(userMessage, attachments: attachments);
      } catch (_) {
        // Both failed — rethrow the original error
        rethrow;
      }
    }
  }
}
