class QaPair {
  final String question;
  final String answer;

  const QaPair({required this.question, required this.answer});
}

class AiScoreDetail {
  final double cvScore;
  final double? interviewScore;
  final double overallScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final String summary;
  final String recommendation;

  const AiScoreDetail({
    required this.cvScore,
    this.interviewScore,
    required this.overallScore,
    required this.strengths,
    required this.weaknesses,
    required this.summary,
    required this.recommendation,
  });

  factory AiScoreDetail.fromJson(Map<String, dynamic> json) {
    return AiScoreDetail(
      cvScore: (json['cvScore'] as num?)?.toDouble() ?? 0,
      interviewScore: (json['interviewScore'] as num?)?.toDouble(),
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0,
      strengths: _stringList(json['strengths']),
      weaknesses: _stringList(json['weaknesses']),
      summary: json['summary'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }
}

class AiInterviewDetail {
  final String status;
  final String? transcript;
  final String? summary;
  final int questionCount;

  const AiInterviewDetail({
    required this.status,
    this.transcript,
    this.summary,
    required this.questionCount,
  });

  factory AiInterviewDetail.fromJson(Map<String, dynamic> json) {
    return AiInterviewDetail(
      status: json['status'] ?? 'PENDING',
      transcript: json['transcript'],
      summary: json['summary'],
      questionCount: json['questionCount'] ?? 0,
    );
  }

  /// Parses the flat "Interviewer: ...\nCandidate: ..." transcript into
  /// ordered question/answer pairs for the chat-style transcript view.
  List<QaPair> get qaPairs {
    final text = transcript;
    if (text == null || text.trim().isEmpty) return const [];

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final pairs = <QaPair>[];
    String? pendingQuestion;

    for (final line in lines) {
      if (line.startsWith('Interviewer:')) {
        if (pendingQuestion != null) {
          pairs.add(QaPair(question: pendingQuestion, answer: ''));
        }
        pendingQuestion = line.substring('Interviewer:'.length).trim();
      } else if (line.startsWith('Candidate:')) {
        final answer = line.substring('Candidate:'.length).trim();
        pairs.add(QaPair(question: pendingQuestion ?? '', answer: answer));
        pendingQuestion = null;
      }
    }

    if (pendingQuestion != null) {
      pairs.add(QaPair(question: pendingQuestion, answer: ''));
    }

    return pairs;
  }
}

class InterviewSchedule {
  final String status;
  final DateTime? scheduledAt;
  final String? meetingLink;

  const InterviewSchedule({
    required this.status,
    this.scheduledAt,
    this.meetingLink,
  });

  factory InterviewSchedule.fromJson(Map<String, dynamic> json) {
    return InterviewSchedule(
      status: json['status'] ?? 'PENDING',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString())
          : null,
      meetingLink: json['meetingLink'],
    );
  }
}

class ApplicationDetail {
  final String id;
  final String status;
  final DateTime appliedAt;
  final String candidateId;
  final String candidateName;
  final String candidateEmail;
  final String candidatePhone;
  final String? resumeFileName;
  final String? resumeUrl;
  final String jobTitle;
  final AiScoreDetail? aiScore;
  final AiInterviewDetail? aiInterview;
  final InterviewSchedule? interview;

  const ApplicationDetail({
    required this.id,
    required this.status,
    required this.appliedAt,
    required this.candidateId,
    required this.candidateName,
    required this.candidateEmail,
    required this.candidatePhone,
    this.resumeFileName,
    this.resumeUrl,
    required this.jobTitle,
    this.aiScore,
    this.aiInterview,
    this.interview,
  });

  factory ApplicationDetail.fromJson(Map<String, dynamic> json) {
    final candidate = json['candidate'] as Map<String, dynamic>? ?? {};
    final job = json['job'] as Map<String, dynamic>? ?? {};
    final aiScoreJson = json['aiScore'] as Map<String, dynamic>?;
    final aiInterviewJson = json['aiInterview'] as Map<String, dynamic>?;
    final interviewJson = json['interview'] as Map<String, dynamic>?;

    return ApplicationDetail(
      id: json['id'] ?? '',
      status: json['status'] ?? 'PENDING',
      appliedAt:
          DateTime.tryParse(json['appliedAt']?.toString() ?? '') ??
          DateTime.now(),
      candidateId: candidate['id'] ?? '',
      candidateName: candidate['fullName'] ?? 'Unknown Candidate',
      candidateEmail: candidate['email'] ?? '',
      candidatePhone: candidate['phone'] ?? '',
      resumeFileName: candidate['resumeFileName'],
      resumeUrl: candidate['resumeUrl'],
      jobTitle: job['title'] ?? '',
      aiScore: aiScoreJson != null ? AiScoreDetail.fromJson(aiScoreJson) : null,
      aiInterview: aiInterviewJson != null
          ? AiInterviewDetail.fromJson(aiInterviewJson)
          : null,
      interview: interviewJson != null
          ? InterviewSchedule.fromJson(interviewJson)
          : null,
    );
  }
}
