import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiDataSource {
  final GenerativeModel _model;

  GeminiDataSource(String apiKey)
      : _model = GenerativeModel(model: 'gemini-3.1-flash-lite-preview', apiKey: apiKey);

  Future<String> sendMessage(String userMessage) async {
    final content = [Content.text(userMessage)];
    final response = await _model.generateContent(content);
    return response.text ?? 'لم أتمكن من الإجابة، حاول مرة أخرى.';
  }
}
