import 'availability_api.dart';

class AvailabilityRepository {
  final AvailabilityApi api;

  AvailabilityRepository(this.api);

  Future<void> save({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) {
    return api.saveAvailability(
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<Map<String, dynamic>?> getMine() {
    return api.getMyAvailability();
  }
}
