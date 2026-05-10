import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'chat_datasource.dart';

/// Direct Gemini data source — calls the Gemini API without RAG.
/// Used as a fallback or for development/testing when the Spring Boot
/// backend is not running.
class GeminiDataSource implements ChatDataSource {
  final GenerativeModel _model;

  GeminiDataSource(String apiKey)
    : _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

  @override
  Future<String> sendMessage(String userMessage, {List<ChatAttachment>? attachments}) async {
    List<Part> parts = [TextPart(userMessage)];

    if (attachments != null && attachments.isNotEmpty) {
      for (var attachment in attachments) {
        final bytes = await File(attachment.path).readAsBytes();
        final mimeType = attachment.mimeType ?? lookupMimeType(attachment.path) ?? 'application/octet-stream';
        parts.add(DataPart(mimeType, bytes));
      }
    }

    final content = [Content.multi(parts)];
    final response = await _model.generateContent(content);
    return response.text ?? 'لم أتمكن من الإجابة، حاول مرة أخرى.';
  }
}
