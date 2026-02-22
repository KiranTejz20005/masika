import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Result of a successful POST /predict call.
class PredictionResult {
  const PredictionResult({
    required this.prediction,
    this.probabilities,
    this.report,
  });
  final String prediction;
  final Map<String, double>? probabilities;
  /// AI-generated wellness report text, if backend returned it.
  final String? report;
}

/// Thrown when the analysis API is misconfigured, unreachable, or returns an error.
class PredictionException implements Exception {
  const PredictionException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => 'PredictionException: $message';
}

/// Encodes form data into the 12-feature vector expected by the API.
List<double> formToFeatures(Map<String, dynamic> form) {
  double numVal(String key, [double def = 0]) {
    final v = form[key];
    if (v == null) return def;
    if (v is num) return v.toDouble();
    final n = double.tryParse(v.toString().trim());
    return n ?? def;
  }

  int catVal(String key, List<String> options, [int def = 0]) {
    final v = form[key]?.toString().trim() ?? '';
    final i = options.indexOf(v);
    return i >= 0 ? i : def;
  }

  return [
    numVal('currentAge', 25),
    numVal('ageAtFirstPeriod', 13),
    numVal('cycleLength', 28),
    numVal('periodDuration', 5),
    catVal('regularity', ['Regular', 'Irregular', 'Very Irregular'], 0).toDouble(),
    catVal('missedPeriod', ['No', 'Yes'], 0).toDouble(),
    catVal('flowRate', ['Light', 'Medium', 'Heavy'], 0).toDouble(),
    numVal('padsPerDay', 4),
    catVal('bloodClots', ['None', 'Few', 'Many'], 0).toDouble(),
    catVal('painLevel', ['No Pain', 'Mild', 'Moderate', 'Severe'], 0).toDouble(),
    catVal('weaknessDizziness', ['No', 'Yes'], 0).toDouble(),
    numVal('hemoglobin', 12.5),
  ];
}

/// Communicates with the remote Analysis API. All analysis, prediction, and report
/// come from this API. No local backend; base URL and optional key from .env.
class MlBackendService {
  MlBackendService()
      : _baseUrl = _getBaseUrl(),
        _apiKey = _getApiKey();

  static String _getBaseUrl() {
    final fromEnv = dotenv.env['ML_BACKEND_URL'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return fromEnv.trim().replaceFirst(RegExp(r'/$'), '');
    }
    return '';
  }

  static String? _getApiKey() {
    final fromEnv = dotenv.env['ML_API_KEY'];
    if (fromEnv != null && fromEnv.trim().isNotEmpty) {
      return fromEnv.trim();
    }
    return null;
  }

  final String _baseUrl;
  final String? _apiKey;

  /// Long timeout for /predict: Render free tier may need 30–60s to wake (cold start).
  static const _predictTimeoutSeconds = 90;
  static const _healthTimeoutSeconds = 10;

  String get baseUrl => _baseUrl;

  Map<String, String> get _headers {
    final map = <String, String>{'Content-Type': 'application/json'};
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      map['Authorization'] = 'Bearer $_apiKey';
    }
    return map;
  }

  void _ensureConfigured() {
    if (_baseUrl.isEmpty) {
      throw PredictionException(
        'Analysis API not configured. Set ML_BACKEND_URL in .env.',
      );
    }
  }

  /// GET /health — expects { "status": "ok" }. Returns false if URL missing or request fails.
  Future<bool> checkHealth() async {
    if (_baseUrl.isEmpty) return false;
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await http
          .get(
            uri,
            headers: _apiKey != null && _apiKey!.isNotEmpty
                ? {'Authorization': 'Bearer $_apiKey'}
                : null,
          )
          .timeout(const Duration(seconds: _healthTimeoutSeconds));
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      return decoded?['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// POST /predict — request: { "features": [12], optional "input_data": {} }.
  /// Response: { "prediction", "probabilities", optional "report" }.
  Future<PredictionResult> predict(
    List<double> features, {
    Map<String, dynamic>? inputData,
  }) async {
    _ensureConfigured();
    if (features.length != 12) {
      throw PredictionException('Exactly 12 features required, got ${features.length}');
    }
    final uri = Uri.parse('$_baseUrl/predict');
    final bodyMap = <String, dynamic>{'features': features};
    if (inputData != null && inputData.isNotEmpty) {
      bodyMap['input_data'] = inputData;
    }
    final body = jsonEncode(bodyMap);

    http.Response response;
    try {
      response = await http
          .post(uri, headers: _headers, body: body)
          .timeout(
            const Duration(seconds: _predictTimeoutSeconds),
            onTimeout: () => throw PredictionException(
              'The server is taking longer than usual (it may be waking up). '
              'Please check your internet connection and try again.',
            ),
          );
    } catch (e) {
      if (e is PredictionException) rethrow;
      throw PredictionException(
        e.toString().contains('SocketException') ||
                e.toString().contains('Connection refused') ||
                e.toString().contains('Failed host lookup') ||
                e.toString().contains('Connection timed out')
            ? 'Cannot reach the analysis server. Check your internet connection and try again. '
              'If using a free server, the first request may take up to a minute.'
            : 'Connection error. Please check your internet and try again.',
      );
    }

    Map<String, dynamic>? decoded;
    try {
      decoded = response.body.isNotEmpty
          ? (jsonDecode(response.body) as Map<String, dynamic>?)
          : null;
    } catch (_) {
      throw const PredictionException('Analysis failed. Try again.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final pred = decoded?['prediction']?.toString();
      if (pred == null || pred.isEmpty) {
        throw const PredictionException('Analysis failed. Try again.');
      }
      Map<String, double>? probs;
      final p = decoded!['probabilities'];
      if (p is Map<String, dynamic> && p.isNotEmpty) {
        probs = p.map((k, v) => MapEntry(
              k.toString(),
              (v is num) ? (v as num).toDouble() : (double.tryParse(v.toString()) ?? 0.0),
            ));
      }
      final reportStr = decoded['report']?.toString();
      final report = reportStr?.trim().isNotEmpty == true ? reportStr : null;
      return PredictionResult(
        prediction: pred,
        probabilities: probs,
        report: report,
      );
    }

    throw const PredictionException('Analysis failed. Try again.');
  }
}
