import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart' as shelf;

import '../lib/handlers/symptom_handler.dart';
import '../lib/services/llm_service.dart';
import '../lib/services/emergency_checker.dart';
import '../lib/models/symptom_response.dart';
import '../lib/models/symptom_request.dart';

void main() {
  group('SymptomChecker Tests', () {
    late shelf.Handler handler;
    late LLMService mockLLMService;

    setUp(() {
      // Create a mock LLM service that returns predictable responses
      mockLLMService = MockLLMService();

      // Create the symptom handler with mock services
      final symptomHandler = SymptomHandler(mockLLMService, null);
      handler = symptomHandler.router;
    });

    group('Emergency Detection', () {
      test('should return emergency response for chest pain', () async {
        final requestData = {
          'symptoms': 'I have severe chest pain and cannot breathe',
          'age': 45,
          'sex': 'Male',
        };

        final request = shelf.Request(
          'POST',
          Uri.parse('/api/symptom-check'),
          body: jsonEncode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        final response = await handler(request);

        expect(response.statusCode, 200);

        final responseData =
            jsonDecode(await response.readAsString()) as Map<String, dynamic>;

        expect(responseData['triage']['level'], 'emergency');
        expect(responseData['triage']['message'], contains('emergency'));
        expect(responseData['disclaimer'],
            'For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.');
      });

      test('should return emergency response for stroke symptoms', () async {
        final requestData = {
          'symptoms': 'sudden weakness and numbness on my left side',
        };

        final request = shelf.Request(
          'POST',
          Uri.parse('/api/symptom-check'),
          body: jsonEncode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        final response = await handler(request);

        expect(response.statusCode, 200);

        final responseData =
            jsonDecode(await response.readAsString()) as Map<String, dynamic>;
        expect(responseData['triage']['level'], 'emergency');
      });

      test('should return emergency response for severe allergic reaction',
          () async {
        final requestData = {
          'symptoms':
              'I am having a severe allergic reaction with throat swelling',
        };

        final request = shelf.Request(
          'POST',
          Uri.parse('/api/symptom-check'),
          body: jsonEncode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        final response = await handler(request);

        expect(response.statusCode, 200);

        final responseData =
            jsonDecode(await response.readAsString()) as Map<String, dynamic>;
        expect(responseData['triage']['level'], 'emergency');
      });
    });

    group('Normal Symptom Processing', () {
      test('should process non-emergency symptoms through LLM', () async {
        final requestData = {
          'symptoms': 'I have a mild headache and feel tired',
          'age': 30,
          'sex': 'Female',
        };

        final request = shelf.Request(
          'POST',
          Uri.parse('/api/symptom-check'),
          body: jsonEncode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        final response = await handler(request);

        expect(response.statusCode, 200);

        final responseData =
            jsonDecode(await response.readAsString()) as Map<String, dynamic>;

        // Should not be emergency
        expect(responseData['triage']['level'], isNot('emergency'));

        // Should have the required fields
        expect(responseData['triage'], isA<Map<String, dynamic>>());
        expect(responseData['conditions'], isA<List>());
        expect(responseData['recommended_next_steps'], isA<List>());
        expect(responseData['disclaimer'],
            'For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.');
      });

      test('should handle empty symptoms field', () async {
        final requestData = {
          'symptoms': '',
        };

        final request = shelf.Request(
          'POST',
          Uri.parse('/api/symptom-check'),
          body: jsonEncode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        final response = await handler(request);

        expect(response.statusCode, 400);

        final responseData =
            jsonDecode(await response.readAsString()) as Map<String, dynamic>;
        expect(responseData['error'], 'Symptoms field is required');
      });

      test('should handle missing symptoms field', () async {
        final requestData = {
          'age': 25,
        };

        final request = shelf.Request(
          'POST',
          Uri.parse('/api/symptom-check'),
          body: jsonEncode(requestData),
          headers: {'Content-Type': 'application/json'},
        );

        final response = await handler(request);

        expect(response.statusCode, 400);
      });
    });

    group('Health Check', () {
      test('should return health status', () async {
        final request = shelf.Request(
          'GET',
          Uri.parse('/api/health'),
        );

        final response = await handler(request);

        expect(response.statusCode, 200);

        final responseData =
            jsonDecode(await response.readAsString()) as Map<String, dynamic>;
        expect(responseData['status'], 'healthy');
        expect(responseData['timestamp'], isA<String>());
      });
    });
  });

  group('EmergencyChecker Tests', () {
    test('should detect emergency conditions', () {
      expect(EmergencyChecker.isEmergency('severe chest pain'), true);
      expect(EmergencyChecker.isEmergency('cannot breathe'), true);
      expect(EmergencyChecker.isEmergency('sudden weakness'), true);
      expect(EmergencyChecker.isEmergency('severe allergic reaction'), true);
      expect(EmergencyChecker.isEmergency('uncontrolled bleeding'), true);
    });

    test('should not detect non-emergency conditions', () {
      expect(EmergencyChecker.isEmergency('mild headache'), false);
      expect(EmergencyChecker.isEmergency('feeling tired'), false);
      expect(EmergencyChecker.isEmergency('minor cough'), false);
      expect(EmergencyChecker.isEmergency('stuffy nose'), false);
    });

    test('should handle case insensitive detection', () {
      expect(EmergencyChecker.isEmergency('CHEST PAIN'), true);
      expect(EmergencyChecker.isEmergency('Chest Pain'), true);
      expect(EmergencyChecker.isEmergency('chest pain'), true);
    });

    test('should return proper emergency response structure', () {
      final response = EmergencyChecker.getEmergencyResponse();

      expect(response['triage']['level'], 'emergency');
      expect(response['triage']['message'], isA<String>());
      expect(response['conditions'], isA<List>());
      expect(response['recommended_next_steps'], isA<List>());
      expect(response['disclaimer'],
          'For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.');
    });
  });
}

/// Mock LLM Service for testing
class MockLLMService extends LLMService {
  MockLLMService()
      : super(
          apiKey: 'test_key',
          apiUrl: 'test_url',
          model: 'test_model',
          temperature: 0.2,
          maxTokens: 1000,
        );

  @override
  Future<SymptomResponse> analyzeSymptoms(SymptomRequest request) async {
    // Return a mock non-emergency response
    return SymptomResponse(
        triage: TriageLevel(
            level: 'non-urgent',
            message:
                'Symptoms suggest mild conditions that may benefit from rest and observation.'),
        conditions: [
          Condition(
              name: 'Tension Headache',
              confidence: 'medium',
              rationale:
                  'Headache with fatigue are common symptoms of tension headache.',
              typicalSymptoms: ['headache', 'fatigue'])
        ],
        recommendedNextSteps: [
          RecommendedAction(
              urgency: 'self-care', action: 'Rest and stay hydrated')
        ],
        disclaimer:
            'For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.',
        askedClarifyingQuestions: ['How long have you had these symptoms?']);
  }
}
