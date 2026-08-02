class ApplicationResult {
  final String applicationId;
  final String status;
  final String message;
  final double? aiScore;
  final double threshold;
  final bool shouldStartAiCall;

  const ApplicationResult({
    required this.applicationId,
    required this.status,
    required this.message,
    required this.threshold,
    required this.shouldStartAiCall,
    this.aiScore,
  });

  factory ApplicationResult.fromJson(Map<String, dynamic> json) {
    return ApplicationResult(
      applicationId: json['applicationId'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      aiScore: (json['aiScore'] as num?)?.toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      shouldStartAiCall: json['shouldStartAiCall'] as bool? ?? false,
    );
  }
}
