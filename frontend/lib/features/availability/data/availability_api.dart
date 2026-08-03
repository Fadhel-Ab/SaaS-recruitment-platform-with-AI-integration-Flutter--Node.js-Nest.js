import 'package:dio/dio.dart';

class AvailabilityApi {
  final Dio dio;

  AvailabilityApi(this.dio);

  Future<Map<String, dynamic>> createAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final response = await dio.post(
      '/availability',
      data: {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> getMyAvailability() async {
    final response = await dio.get('/availability/my');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateAvailability(
    String id, {
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    final response = await dio.patch(
      '/availability/$id',
      data: {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteAvailability(String id) async {
    await dio.delete('/availability/$id');
  }
}
