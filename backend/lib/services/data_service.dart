import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/symptom_request.dart';
import '../models/symptom_response.dart';

class DataService {
  final String _hashSalt;
  final _uuid = const Uuid();

  DataService(this._hashSalt);

  /// Stores a symptom check query with anonymized data (simplified version)
  Future<String> storeQuery({
    required SymptomRequest request,
    required SymptomResponse response,
  }) async {
    final queryId = _uuid.v4();
    final symptomsHash = _hashSymptoms(request.symptoms);

    // For demo purposes, just log the data
    print(
        'Storing query: $queryId, hash: $symptomsHash, triage: ${response.triage.level}');

    return queryId;
  }

  /// Retrieves query history for a user (simplified version)
  Future<List<Map<String, dynamic>>> getQueryHistory(String userId) async {
    // For demo purposes, return empty list
    return [];
  }

  /// Hashes symptoms for privacy protection
  String _hashSymptoms(String symptoms) {
    final bytes = utf8.encode(symptoms + _hashSalt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Initializes the database schema (simplified version)
  static Future<void> initializeSchema() async {
    // For demo purposes, just print
    print('Database schema initialized (demo mode)');
  }
}
