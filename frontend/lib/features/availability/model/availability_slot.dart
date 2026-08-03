enum AvailabilityRecurrence { recurring, specific }

AvailabilityRecurrence _recurrenceFromApi(dynamic value) {
  return value == 'RECURRING'
      ? AvailabilityRecurrence.recurring
      : AvailabilityRecurrence.specific;
}

String _recurrenceToApi(AvailabilityRecurrence recurrence) {
  return recurrence == AvailabilityRecurrence.recurring
      ? 'RECURRING'
      : 'SPECIFIC';
}

class AvailabilitySlot {
  final String? id;

  /// Null when this slot is a general (job-agnostic) fallback; set when it's
  /// scoped to a specific posted job.
  final String? jobId;

  final AvailabilityRecurrence recurrence;

  /// Set when [recurrence] is [AvailabilityRecurrence.specific].
  final DateTime? date;

  /// 1 (Monday) - 7 (Sunday). Set when [recurrence] is
  /// [AvailabilityRecurrence.recurring].
  final int? dayOfWeek;

  final String startTime;
  final String endTime;

  const AvailabilitySlot({
    this.id,
    this.jobId,
    required this.recurrence,
    this.date,
    this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilitySlot.specific({
    String? id,
    String? jobId,
    required DateTime date,
    required String startTime,
    required String endTime,
  }) {
    return AvailabilitySlot(
      id: id,
      jobId: jobId,
      recurrence: AvailabilityRecurrence.specific,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }

  factory AvailabilitySlot.recurring({
    String? id,
    String? jobId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) {
    return AvailabilitySlot(
      id: id,
      jobId: jobId,
      recurrence: AvailabilityRecurrence.recurring,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
  }

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    final recurrence = _recurrenceFromApi(json['recurrence']);
    return AvailabilitySlot(
      id: json['id'],
      jobId: json['jobId'],
      recurrence: recurrence,
      date: json['date'] != null ? DateTime.parse(json['date'].toString()) : null,
      dayOfWeek: json['dayOfWeek'] is int
          ? json['dayOfWeek']
          : int.tryParse(json['dayOfWeek']?.toString() ?? ''),
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'recurrence': _recurrenceToApi(recurrence),
      if (recurrence == AvailabilityRecurrence.specific && date != null)
        'date': formatDate(date!),
      if (recurrence == AvailabilityRecurrence.recurring)
        'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  AvailabilitySlot copyWith({
    String? jobId,
    AvailabilityRecurrence? recurrence,
    DateTime? date,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
  }) {
    return AvailabilitySlot(
      id: id,
      jobId: jobId ?? this.jobId,
      recurrence: recurrence ?? this.recurrence,
      date: date ?? this.date,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
