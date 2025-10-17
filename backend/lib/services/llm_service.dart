import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/symptom_request.dart';
import '../models/symptom_response.dart';

class LLMService {
  final String apiKey;
  final String apiUrl;
  final String model;
  final double temperature;
  final int maxTokens;

  LLMService({
    required this.apiKey,
    required this.apiUrl,
    required this.model,
    required this.temperature,
    required this.maxTokens,
  });

  /// Calls the LLM API to analyze symptoms
  Future<SymptomResponse> analyzeSymptoms(SymptomRequest request) async {
    final prompt = _buildPrompt(request);

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': prompt,
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'LLM API error: ${response.statusCode} - ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    final content = responseData['choices'][0]['message']['content'];

    try {
      final jsonResponse = jsonDecode(content);
      return SymptomResponse.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Failed to parse LLM response: $e');
    }
  }

  /// Builds the prompt for the LLM
  List<Map<String, String>> _buildPrompt(SymptomRequest request) {
    final systemMessage = _getSystemPrompt();
    final userMessage = _getUserPrompt(request);

    return [
      {'role': 'system', 'content': systemMessage},
      {'role': 'user', 'content': userMessage},
    ];
  }

  /// System prompt template
  String _getSystemPrompt() {
    return '''
You are a medical AI assistant designed to provide educational symptom analysis. You must be extremely cautious and conservative in your assessments.

CRITICAL REQUIREMENTS:
1. You MUST respond with ONLY valid JSON in the exact schema specified below
2. Include confidence levels (high/medium/low) for all conditions
3. Always emphasize uncertainty and the need for clinical evaluation
4. Include the exact disclaimer in your response
5. When in doubt, recommend urgent medical evaluation
6. Do not provide specific medical advice beyond general guidance

RESPONSE SCHEMA (respond with ONLY this JSON structure):
{
  "triage": {
    "level": "emergency|urgent|non-urgent|self-care",
    "message": "string"
  },
  "conditions": [
    {
      "name": "string",
      "confidence": "high|medium|low",
      "rationale": "string",
      "typical_symptoms": ["string"]
    }
  ],
  "recommended_next_steps": [
    {
      "urgency": "emergency|soon|routine|self-care",
      "action": "string"
    }
  ],
  "disclaimer": "For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.",
  "asked_clarifying_questions": ["string"]
}

EXAMPLES:

Example 1 (Non-urgent):
Input: "I have a mild headache and feel tired"
Response: {
  "triage": {
    "level": "non-urgent",
    "message": "Symptoms suggest mild, non-urgent conditions that may benefit from rest and observation."
  },
  "conditions": [
    {
      "name": "Tension Headache",
      "confidence": "medium",
      "rationale": "Headache with fatigue are common symptoms of tension headache, especially if stress-related.",
      "typical_symptoms": ["headache", "fatigue", "muscle tension"]
    }
  ],
  "recommended_next_steps": [
    {
      "urgency": "self-care",
      "action": "Rest, stay hydrated, and consider over-the-counter pain relief if appropriate"
    },
    {
      "urgency": "routine",
      "action": "If symptoms persist or worsen, consult a healthcare provider"
    }
  ],
  "disclaimer": "For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.",
  "asked_clarifying_questions": ["How long have you had these symptoms?", "Have you had similar symptoms before?"]
}

Example 2 (Emergency):
Input: "I have severe chest pain and can't breathe"
Response: {
  "triage": {
    "level": "emergency",
    "message": "This appears to be a medical emergency requiring immediate attention."
  },
  "conditions": [
    {
      "name": "Potential Cardiac Emergency",
      "confidence": "high",
      "rationale": "Severe chest pain with breathing difficulties may indicate a serious cardiac or respiratory emergency.",
      "typical_symptoms": ["chest pain", "shortness of breath", "emergency symptoms"]
    }
  ],
  "recommended_next_steps": [
    {
      "urgency": "emergency",
      "action": "Call emergency services (911) immediately or go to the nearest emergency room"
    }
  ],
  "disclaimer": "For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.",
  "asked_clarifying_questions": []
}

Remember: Be conservative, emphasize uncertainty, and always recommend professional medical evaluation when appropriate.
''';
  }

  /// User prompt template
  String _getUserPrompt(SymptomRequest request) {
    final buffer = StringBuffer();

    buffer.writeln('Please analyze the following symptoms:');
    buffer.writeln('Symptoms: ${request.symptoms}');

    if (request.age != null) {
      buffer.writeln('Age: ${request.age}');
    }

    if (request.sex != null) {
      buffer.writeln('Sex: ${request.sex}');
    }

    if (request.otherInfo != null && request.otherInfo!.isNotEmpty) {
      buffer.writeln('Additional Information: ${request.otherInfo}');
    }

    buffer.writeln(
        '\nPlease provide your analysis in the exact JSON format specified in the system prompt.');

    return buffer.toString();
  }
}
