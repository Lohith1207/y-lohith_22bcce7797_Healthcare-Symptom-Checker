import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  final router = Router();

  // Health check endpoint
  router.get('/api/health', (Request request) {
    return Response.ok(
      jsonEncode(
          {'status': 'healthy', 'timestamp': DateTime.now().toIso8601String()}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Simple symptom check endpoint (without LLM for testing)
  router.post('/api/symptom-check', (Request request) async {
    try {
      final body = await request.readAsString();
      final requestData = jsonDecode(body) as Map<String, dynamic>;
      final symptoms = requestData['symptoms'] as String? ?? '';

      // Simple emergency detection
      if (symptoms.toLowerCase().contains('chest pain') ||
          symptoms.toLowerCase().contains('emergency') ||
          symptoms.toLowerCase().contains('cannot breathe')) {
        final emergencyResponse = {
          'triage': {
            'level': 'emergency',
            'message':
                'This appears to be a medical emergency. Please call emergency services (911) immediately or go to the nearest emergency room.'
          },
          'conditions': [
            {
              'name': 'Potential Medical Emergency',
              'confidence': 'high',
              'rationale':
                  'Symptoms suggest a medical emergency requiring immediate attention.',
              'typical_symptoms': ['Emergency symptoms detected']
            }
          ],
          'recommended_next_steps': [
            {
              'urgency': 'emergency',
              'action':
                  'Call emergency services (911) immediately or go to the nearest emergency room'
            }
          ],
          'disclaimer':
              'For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.',
          'asked_clarifying_questions': []
        };

        return Response.ok(
          jsonEncode(emergencyResponse),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Non-emergency response
      final normalResponse = {
        'triage': {
          'level': 'non-urgent',
          'message':
              'Symptoms suggest mild conditions that may benefit from rest and observation.'
        },
        'conditions': [
          {
            'name': 'General Symptoms',
            'confidence': 'medium',
            'rationale':
                'Symptoms require further evaluation by a healthcare professional.',
            'typical_symptoms': ['General discomfort']
          }
        ],
        'recommended_next_steps': [
          {
            'urgency': 'routine',
            'action': 'Consult a healthcare provider for proper evaluation'
          }
        ],
        'disclaimer':
            'For educational purposes only. This is not medical advice. Consult a licensed healthcare professional.',
        'asked_clarifying_questions': ['How long have you had these symptoms?']
      };

      return Response.ok(
        jsonEncode(normalResponse),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid request: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Add CORS headers
  final handler = Pipeline().addMiddleware((innerHandler) {
    return (Request request) async {
      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      });
    };
  }).addHandler(router);

  final server = await io.serve(handler, 'localhost', 8080);

  print(
      'Simple Healthcare Symptom Checker server running on http://${server.address.host}:${server.port}');
  print(
      'Health check: http://${server.address.host}:${server.port}/api/health');
  print(
      'Symptom check: http://${server.address.host}:${server.port}/api/symptom-check');
}
