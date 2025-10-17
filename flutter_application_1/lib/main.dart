import 'package:flutter/material.dart';
import 'models/symptom_models.dart';
import 'services/api_service.dart';
import 'widgets/symptom_form.dart';
import 'widgets/results_display.dart';

void main() {
  runApp(const HealthcareSymptomCheckerApp());
}

class HealthcareSymptomCheckerApp extends StatelessWidget {
  const HealthcareSymptomCheckerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthcare Symptom Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const SymptomCheckerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SymptomCheckerPage extends StatefulWidget {
  const SymptomCheckerPage({Key? key}) : super(key: key);

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  final ApiService _apiService = ApiService(baseUrl: 'http://localhost:8080');
  bool _isLoading = false;
  SymptomResponse? _lastResponse;
  String? _errorMessage;
  bool _isApiHealthy = true;

  @override
  void initState() {
    super.initState();
    _checkApiHealth();
  }

  Future<void> _checkApiHealth() async {
    try {
      final isHealthy = await _apiService.isHealthy();
      setState(() {
        _isApiHealthy = isHealthy;
      });
    } catch (e) {
      setState(() {
        _isApiHealthy = false;
      });
    }
  }

  Future<void> _handleSubmit(
    String symptoms,
    int? age,
    String? sex,
    String? otherInfo,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lastResponse = null;
    });

    try {
      final request = SymptomRequest(
        symptoms: symptoms,
        age: age,
        sex: sex,
        otherInfo: otherInfo,
      );

      final response = await _apiService.checkSymptoms(request);

      setState(() {
        _lastResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Symptom Checker'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkApiHealth,
            tooltip: 'Check API Status',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (!_isApiHealthy) _buildApiStatusWarning(),
                SymptomForm(onSubmit: _handleSubmit, isLoading: _isLoading),
                const SizedBox(height: 16),
                if (_errorMessage != null) _buildErrorMessage(),
                if (_lastResponse != null) _buildResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApiStatusWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'API server is not responding. Please ensure the backend server is running on localhost:8080',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_lastResponse == null) return const SizedBox.shrink();

    return ResultsDisplay(response: _lastResponse!);
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
