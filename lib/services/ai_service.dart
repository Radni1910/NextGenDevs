import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  // ⚠️ Replace with your actual API Key from Google AI Studio
  static const String _apiKey = 'AIzaSyBKaRN2YIOIjFbKSSUJsEC9T5zl6r9S8DY';

  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(
    model: 'gemini-1.5-flash', // Use flash for speed and lower cost
    apiKey: _apiKey,
  );

  Future<String> predictPriority(String description) async {
    if (description.trim().isEmpty) return 'Medium';

    final prompt = '''
      You are a maintenance triage assistant. 
      Based on the user's issue description, assign exactly one priority: Low, Medium, High, or Urgent.
      
      Rules:
      - Urgent: Safety hazards, gas smells, sparks, major flooding.
      - High: No water, no electricity, broken locks, leaks.
      - Medium: Broken appliances, slow drains, flickering lights.
      - Low: Cosmetic issues, squeaky doors, minor chips.

      Description: "$description"
      
      Response (One word only):''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      String result = response.text?.trim() ?? 'Medium';

      // Ensure the AI output matches your valid options
      if (['Low', 'Medium', 'High', 'Urgent'].contains(result)) {
        return result;
      }
      return 'Medium'; // Fallback
    } catch (e) {
      print('AI Error: $e');
      return 'Medium';
    }
  }
}