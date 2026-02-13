import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> generatePersonalizedExplanation({
    required String monumentName,
    required String basicInfo,
    required List<String> userInterests,
  }) async {
    final prompt = """
Monument: $monumentName
Basic Info: $basicInfo
User's Interests: ${userInterests.join(', ')}

Generate a warm, engaging explanation (max 150 words) that connects this monument to their interests. Be conversational and inspiring.
""";

    return await _callOpenAI(prompt);
  }

  Future<String> generateRecommendationReason({
    required String monumentName,
    required List<String> monumentCategories,
    required List<String> userInterests,
  }) async {
    final prompt = """
Monument: $monumentName
Categories: ${monumentCategories.join(', ')}
User Interests: ${userInterests.join(', ')}

In one sentence (max 20 words), explain why this is recommended. Start with "Because you love..."
""";

    return await _callOpenAI(prompt);
  }

  Future<Map<String, dynamic>> parseSearchIntent(String query) async {
    final prompt = """
User query: "$query"

Return ONLY valid JSON:
{
  "categories": ["history", "spirituality", "architecture", "nature"],
  "vibes": ["peaceful", "scenic"],
  "location": "city name or null",
  "crowdPreference": "high/medium/low or null"
}
""";

    final response = await _callOpenAI(prompt);
    
    try {
      String cleaned = response.trim();
      if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
      if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
      if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
      
      return jsonDecode(cleaned.trim());
    } catch (e) {
      return {};
    }
  }

  Future<String> _callOpenAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAiKey}',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [{'role': 'user', 'content': prompt}],
          'max_tokens': 250,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        return 'Unable to generate content.';
      }
    } catch (e) {
      return 'Unable to generate content.';
    }
  }
}