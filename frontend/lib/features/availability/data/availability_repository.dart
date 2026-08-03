import 'package:frontend/features/availability/model/availability_slot.dart';

import 'availability_api.dart';

class AvailabilityRepository {
  final AvailabilityApi api;

  AvailabilityRepository(this.api);

  Future<List<AvailabilitySlot>> getMine() async {
    final data = await api.getMyAvailability();
    return data
        .map((e) => AvailabilitySlot.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<AvailabilitySlot> create({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final data = await api.createAvailability(
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    return AvailabilitySlot.fromJson(data);
  }

  Future<AvailabilitySlot> update(
    String id, {
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final data = await api.updateAvailability(
      id,
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
    );
    return AvailabilitySlot.fromJson(data);
  }

  Future<void> delete(String id) {
    return api.deleteAvailability(id);
  }
}
