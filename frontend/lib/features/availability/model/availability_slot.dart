class AvailabilitySlot {
  final String? id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const AvailabilitySlot({
    this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'] is int
          ? json['dayOfWeek']
          : int.tryParse(json['dayOfWeek'].toString()) ?? 1,
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '17:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {'dayOfWeek': dayOfWeek, 'startTime': startTime, 'endTime': endTime};
  }

  AvailabilitySlot copyWith({
    int? dayOfWeek,
    String? startTime,
    String? endTime,
  }) {
    return AvailabilitySlot(
      id: id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
