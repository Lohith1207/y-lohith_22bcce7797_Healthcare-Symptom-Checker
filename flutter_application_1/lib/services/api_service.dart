import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/symptom_models.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();

  ApiService({required this.baseUrl});

  /// Calls the symptom check API
  Future<SymptomResponse> checkSymptoms(SymptomRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/symptom-check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return SymptomResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception('API Error: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to check symptoms: $e');
    }
  }

  /// Health check for the API
  Future<bool> isHealthy() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/health'),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}
