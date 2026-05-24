import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  GeminiService()
    : _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-3.1-flash-lite',
        systemInstruction: Content.system(
          '''
You are CivicMate, a concise civic assistant inside a community issue reporting app.
Help users write clearer civic reports, identify urgency, suggest practical next steps, and explain what details to include.
Do not claim that an issue has been officially reported or resolved.
Keep replies short, useful, and easy to understand.
Do not use markdown symbols like **, ###, or tables. Use plain text only.
''',
        ),
      );

  final GenerativeModel _model;

  Future<String> ask(String message) async {
    final prompt = message.trim();
    if (prompt.isEmpty) return "Tell me what civic issue you need help with.";

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        return "I could not generate a response. Try asking again.";
      }

      return _cleanResponse(text);
    } catch (e) {
      return "CivicMate AI is not ready yet. Enable Firebase AI Logic for this Firebase project, then try again.";
    }
  }

  String _cleanResponse(String value) {
    final withoutBold = value.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? "",
    );

    return withoutBold
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .replaceAll('**', '')
        .replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '- ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
