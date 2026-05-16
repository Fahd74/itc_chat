import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'chat_datasource.dart';

class GroqDataSource implements ChatDataSource {
  final String _apiKey;

  GroqDataSource(String apiKey) : _apiKey = apiKey;

  /// System prompt shared across all Groq calls.
  static const String _systemPrompt = '''أنت مساعد ذكي اسمك "Assist AI" لطلاب كلية تكنولوجيا المعلومات (ITC).
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
    final activeModel = model ?? 'llama-3.3-70b-versatile';
    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    // Build messages list with system prompt
    final List<Map<String, dynamic>> messages = [
      {
        "role": "system",
        "content": _systemPrompt,
      },
    ];

    // Build user message content
    dynamic messageContent;

    if (attachments != null && attachments.isNotEmpty) {
      // Vision request
      final List<Map<String, dynamic>> contentList = [];
      contentList.add({
        "type": "text",
        "text": userMessage.isEmpty ? "What's in this image?" : userMessage,
      });

      for (var attachment in attachments) {
        try {
          final bytes = attachment.bytes ?? await _readFileBytes(attachment.path);
          if (bytes != null) {
            final mimeType = attachment.mimeType ?? lookupMimeType(attachment.path) ?? 'image/jpeg';
            final base64String = base64Encode(bytes);
            contentList.add({
              "type": "image_url",
              "image_url": {
                "url": "data:$mimeType;base64,$base64String"
              }
            });
          }
        } catch (e) {
          // ignore error
        }
      }
      messageContent = contentList;
    } else {
      messageContent = userMessage;
    }

    messages.add({
      "role": "user",
      "content": messageContent,
    });

    final body = jsonEncode({
      "model": activeModel,
      "messages": messages,
      "temperature": 0.7,
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] ?? 'لم أتمكن من الإجابة، حاول مرة أخرى.';
    } else {
      throw Exception('Groq API Error: ${response.body}');
    }
  }

  Future<Uint8List?> _readFileBytes(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return await file.readAsBytes();
  }
}
