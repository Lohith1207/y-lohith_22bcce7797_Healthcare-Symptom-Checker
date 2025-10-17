import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';

import '../lib/handlers/symptom_handler.dart';
import '../lib/services/llm_service.dart';
import '../lib/services/data_service.dart';

void main(List<String> args) async {
  // Load environment variables
  final env = DotEnv(includePlatformEnvironment: true)..load();

  // Configuration
  final serverPort = int.parse(env['SERVER_PORT'] ?? '8080');
  final serverHost = env['SERVER_HOST'] ?? '0.0.0.0';
  final hashSalt = env['HASH_SALT'] ?? 'default_salt_change_in_production';

  // Initialize services
  final llmService = LLMService(
    apiKey: env['LLM_API_KEY'] ?? '',
    apiUrl: env['LLM_API_URL'] ?? 'https://api.openai.com/v1/chat/completions',
    model: env['LLM_MODEL'] ?? 'gpt-3.5-turbo',
    temperature: double.parse(env['LLM_TEMPERATURE'] ?? '0.2'),
    maxTokens: int.parse(env['LLM_MAX_TOKENS'] ?? '1000'),
  );

  DataService? dataService;

  // Initialize data service (simplified version)
  try {
    await DataService.initializeSchema();
    dataService = DataService(hashSalt);
    print('Data service initialized successfully');
  } catch (e) {
    print('Warning: Data service initialization failed: $e');
    print('Continuing without data service...');
  }

  // Initialize symptom handler
  final symptomHandler = SymptomHandler(llmService, dataService);

  // Create middleware and pipeline
  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(symptomHandler.router);

  // Start the server
  final server = await io.serve(handler, serverHost, serverPort);
  print('Server listening on ${server.address.host}:${server.port}');
  print(
      'Health check: http://${server.address.host}:${server.port}/api/health');
  print(
      'Symptom check: http://${server.address.host}:${server.port}/api/symptom-check');

  // Graceful shutdown
  ProcessSignal.sigint.watch().listen((signal) async {
    print('\nShutting down server...');
    await server.close();
    if (dataService != null) {
      // Close database connection if available
      // Note: PostgreSQLConnection doesn't have a close method in this version
      // In production, you might want to implement connection pooling
    }
    exit(0);
  });
}
