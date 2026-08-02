import 'package:dio/dio.dart';

class AvailabilityApi {
  final Dio dio;

  AvailabilityApi(this.dio);

  Future<void> saveAvailability({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) async {
    await dio.post(
      '/availability',
      data: {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
      },
    );
  }

  Future<Map<String, dynamic>?> getMyAvailability() async {
    final response = await dio.get('/availability/me');

    if (response.data == null) {
      return null;
    }

    return response.data;
  }
}
