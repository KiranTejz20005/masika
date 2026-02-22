/// One AI diagnosis from the ML backend, optionally persisted to Supabase.
/// [report] is the AI-generated wellness report (from NVIDIA), if available.
class DiagnosisRecord {
  const DiagnosisRecord({
    required this.prediction,
    this.probabilities,
    this.inputData = const {},
    this.report,
    this.id,
    this.patientId,
    this.createdAt,
  });

  final String? id;
  final String? patientId;
  final Map<String, dynamic> inputData;
  final String prediction;
  final Map<String, double>? probabilities;
  /// AI-generated wellness report text (from backend/NVIDIA). Null if not requested or unavailable.
  final String? report;
  final DateTime? createdAt;

  factory DiagnosisRecord.fromJson(Map<String, dynamic> json) {
    Map<String, double>? probs;
    final p = json['probabilities'];
    if (p is Map<String, dynamic> && p.isNotEmpty) {
      probs = p.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }
    DateTime? created;
    final c = json['createdAt'];
    if (c != null) {
      if (c is String) created = DateTime.tryParse(c);
      if (c is DateTime) created = c;
    }
    return DiagnosisRecord(
      id: json['id']?.toString(),
      patientId: json['patientId']?.toString(),
      inputData: json['inputData'] != null
          ? Map<String, dynamic>.from(json['inputData'] as Map)
          : {},
      prediction: json['prediction']?.toString() ?? 'NORMAL',
      probabilities: probs,
      report: json['report']?.toString(),
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (patientId != null) 'patientId': patientId,
        'inputData': inputData,
        'prediction': prediction,
        if (probabilities != null) 'probabilities': probabilities,
        if (report != null) 'report': report,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };
}
