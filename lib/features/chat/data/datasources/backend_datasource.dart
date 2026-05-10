import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itc_chat/features/chat/domain/entities/chat_attachment.dart';
import 'chat_datasource.dart';

/// Data source that communicates with the Spring Boot backend.
/// The backend handles RAG (Retrieval-Augmented Generation):
///   1. Receives the student's question
///   2. Searches the university knowledge base (PDF lectures, syllabi)
///   3. Feeds retrieved context + question to Gemini
///   4. Returns the grounded answer
class BackendDataSource implements ChatDataSource {
  final String _baseUrl;
  final String? _authToken;

  BackendDataSource({
    required String baseUrl,
    String? authToken,
  })  : _baseUrl = baseUrl,
        _authToken = authToken;

  @override
  Future<String> sendMessage(String userMessage, {List<ChatAttachment>? attachments}) async {
    final uri = Uri.parse('$_baseUrl/api/chat');

    if (attachments == null || attachments.isEmpty) {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final body = jsonEncode({
        'message': userMessage,
      });

      final response = await http.post(uri, headers: headers, body: body);
      return _parseResponse(response);
    } else {
      final request = http.MultipartRequest('POST', uri);
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      request.fields['message'] = userMessage;
      
      for (var attachment in attachments) {
        request.files.add(await http.MultipartFile.fromPath('files', attachment.path));
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response);
    }
  }

  String _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? 'لم أتمكن من الإجابة، حاول مرة أخرى.';
    } else {
      throw Exception(
        'خطأ من السيرفر (${response.statusCode}): ${response.body}',
      );
    }
  }
}
