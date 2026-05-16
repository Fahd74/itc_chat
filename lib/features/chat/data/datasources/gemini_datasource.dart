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
  final String _apiKey;

  GeminiDataSource(String apiKey) : _apiKey = apiKey;

  /// System instruction shared across all Gemini calls.
  static const String _systemInstruction = '''أنت مساعد ذكي اسمك "Assist AI" لطلاب كلية تكنولوجيا المعلومات (ITC).
مهمتك هي مساعدة الطلاب بالإجابة على أسئلتهم المتعلقة بالمواد الدراسية والمحاضرات.

المواد الدراسية المتاحة حالياً (الفرقة الثالثة - الفصل الدراسي الثاني):
- Advanced C++ (البرمجة المتقدمة بلغة C++ — OOP, Templates, STL, Polymorphism, Operator Overloading)
- Algorithms (الخوارزميات — Sorting, Searching, Graph Algorithms, Dynamic Programming, Complexity Analysis)
- Embedded Systems (الأنظمة المدمجة — Arduino, Microcontrollers, ADC, DAC, Sensors, Timers, Interrupts, PWM)
- Mobile App Development (تطبيقات الهاتف — Flutter, Dart, Widgets, State Management, Firebase)
- Network Programming (برمجة الشبكات — TCP/IP, UDP, Sockets, Java Networking, Client-Server, Multithreading)
- Software Engineering (هندسة البرمجيات — SDLC, Agile, UML Diagrams, Design Patterns, Testing, Requirements)

قواعد مهمة:
1. أجب بلغة الطالب (عربي أو إنجليزي).
2. كن دقيقاً ومفيداً في إجاباتك.
3. استخدم تنسيق Markdown لتنسيق إجابتك (عناوين، نقاط، كود، إلخ).
4. عند الإجابة عن أسئلة أكاديمية، قدم شرحاً واضحاً مع أمثلة عملية.
5. إذا كان السؤال يتعلق بكود برمجي، اكتب الكود مع شرح تفصيلي.
''';

  @override
  Future<String> sendMessage(String userMessage, {List<ChatAttachment>? attachments, String? model}) async {
    final activeModelName = model ?? 'gemini-2.5-flash';
    
    final generativeModel = GenerativeModel(
      model: activeModelName,
      apiKey: _apiKey,
      systemInstruction: Content.text(_systemInstruction),
    );

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
    final response = await generativeModel.generateContent(content);
    return response.text ?? 'لم أتمكن من الإجابة، حاول مرة أخرى.';
  }

  /// Attempts to read file bytes from path. Returns null if file doesn't exist.
  Future<Uint8List?> _readFileBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }
}
