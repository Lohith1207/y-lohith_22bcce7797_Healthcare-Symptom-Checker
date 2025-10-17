import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/symptom_request.dart';
import '../models/symptom_response.dart';
import '../services/emergency_checker.dart';
import '../services/llm_service.dart';
import '../services/data_service.dart';

class SymptomHandler {
  final LLMService _llmService;
  final DataService? _dataService;

  SymptomHandler(this._llmService, this._dataService);

  Router get router {
    final router = Router();

    router.post('/api/symptom-check', _handleSymptomCheck);
    router.get('/api/health', _handleHealthCheck);

    return router;
  }

  /// Handles the main symptom checking endpoint
  Future<Response> _handleSymptomCheck(Request request) async {
    try {
      // Parse request body
      final body = await request.readAsString();
      final requestData = jsonDecode(body) as Map<String, dynamic>;

      final symptomRequest = SymptomRequest.fromJson(requestData);

      // Validate required fields
      if (symptomRequest.symptoms.trim().isEmpty) {
        return _errorResponse(400, 'Symptoms field is required');
      }

      // Emergency pre-check
      if (EmergencyChecker.isEmergency(symptomRequest.symptoms)) {
        final emergencyResponse = EmergencyChecker.getEmergencyResponse();

        // Store emergency response if data service is available
        if (_dataService != null) {
          final emergencySymptomResponse =
              SymptomResponse.fromJson(emergencyResponse);
          await _dataService!.storeQuery(
            request: symptomRequest,
            response: emergencySymptomResponse,
          );
        }

        return Response.ok(
          jsonEncode(emergencyResponse),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Call LLM for non-emergency cases
      final symptomResponse = await _llmService.analyzeSymptoms(symptomRequest);

      // Store response if data service is available
      if (_dataService != null) {
        await _dataService!.storeQuery(
          request: symptomRequest,
          response: symptomResponse,
        );
      }

      return Response.ok(
        jsonEncode(symptomResponse.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error processing symptom check: $e');
      return _errorResponse(500, 'Internal server error: ${e.toString()}');
    }
  }

  /// Health check endpoint
  Response _handleHealthCheck(Request request) {
    return Response.ok(
      jsonEncode(
          {'status': 'healthy', 'timestamp': DateTime.now().toIso8601String()}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Helper method for error responses
  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
