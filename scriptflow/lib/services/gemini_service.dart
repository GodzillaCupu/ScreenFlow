import 'package:google_generative_ai/google_generative_ai.dart';

/// Thin wrapper over the Gemini client. Keeps prompt construction and the
/// system instruction in one place so feature code just asks for "a script"
/// or "a grammar fix" without knowing about the SDK.
class GeminiService {
  GeminiService({required String apiKey, required String model})
      : _model = GenerativeModel(
          model: model,
          apiKey: apiKey,
          systemInstruction: Content.system(_systemPrompt),
          generationConfig: GenerationConfig(temperature: 0.8),
        );

  final GenerativeModel _model;

  static const String _systemPrompt =
      'You are "The Muse", a writing partner for video/podcast creators inside '
      'ScriptFlow. Write natural, spoken-word scripts that sound great read '
      'aloud. Be concise, structured, and avoid filler. Output plain text only '
      '(no markdown headers unless asked).';

  /// One-shot generation. Use for "Generate Idea" / outline creation.
  Future<String> generate(String prompt, {String? scriptContext}) async {
    final input = StringBuffer(prompt);
    if (scriptContext != null && scriptContext.trim().isNotEmpty) {
      input.write('\n\n---\nCurrent script for context:\n$scriptContext');
    }
    final response = await _model.generateContent([Content.text('$input')]);
    return response.text ?? '';
  }

  /// Streaming generation — feed tokens into the editor as they arrive so the
  /// user sees the draft build live (matches the "Ask Muse to brainstorm" UX).
  Stream<String> generateStream(String prompt, {String? scriptContext}) {
    final input = StringBuffer(prompt);
    if (scriptContext != null && scriptContext.trim().isNotEmpty) {
      input.write('\n\n---\nCurrent script for context:\n$scriptContext');
    }
    return _model
        .generateContentStream([Content.text('$input')])
        .map((chunk) => chunk.text ?? '');
  }

  /// "Fix Grammar" toolbar action — returns the corrected passage only.
  Future<String> fixGrammar(String passage) async {
    final response = await _model.generateContent([
      Content.text(
        'Correct grammar, punctuation, and flow of the following passage for '
        'spoken delivery. Return ONLY the corrected text, nothing else:\n\n'
        '$passage',
      ),
    ]);
    return response.text ?? passage;
  }
}
