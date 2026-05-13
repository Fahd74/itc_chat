import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'dart:io';
import 'dart:typed_data';
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
        try {
          // Prefer pre-loaded bytes (cached at pick time) over reading from path
          final bytes = attachment.bytes ?? await _readFileBytes(attachment.path);
          if (bytes == null) {
            parts.add(TextPart('[⚠️ File "${attachment.name}" could not be loaded — it may have been removed from cache.]'));
            continue;
          }
          final mimeType = attachment.mimeType ?? lookupMimeType(attachment.path) ?? 'application/octet-stream';
          parts.add(DataPart(mimeType, bytes));
        } catch (e) {
          parts.add(TextPart('[⚠️ Error reading file "${attachment.name}": $e]'));
        }
      }
    }

    final content = [Content.multi(parts)];
    final response = await _model.generateContent(content);
    return response.text ?? 'لم أتمكن من الإجابة، حاول مرة أخرى.';
  }

  /// Attempts to read file bytes from path. Returns null if file doesn't exist.
  Future<Uint8List?> _readFileBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }
}

