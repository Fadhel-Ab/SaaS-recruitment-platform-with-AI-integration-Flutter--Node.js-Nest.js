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

  Future<AvailabilitySlot> create(AvailabilitySlot slot) async {
    final data = await api.createAvailability(slot.toJson());
    return AvailabilitySlot.fromJson(data);
  }

  Future<AvailabilitySlot> update(String id, AvailabilitySlot slot) async {
    final data = await api.updateAvailability(id, slot.toJson());
    return AvailabilitySlot.fromJson(data);
  }

  Future<void> delete(String id) {
    return api.deleteAvailability(id);
  }
}
