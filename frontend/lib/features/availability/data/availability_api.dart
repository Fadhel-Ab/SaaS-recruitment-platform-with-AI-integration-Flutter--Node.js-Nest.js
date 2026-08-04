import 'package:dio/dio.dart';

class AvailabilityApi {
  final Dio dio;

  AvailabilityApi(this.dio);

  Future<Map<String, dynamic>> createAvailability(
    Map<String, dynamic> body,
  ) async {
    final response = await dio.post('/availability', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> getMyAvailability() async {
    final response = await dio.get('/availability/my');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateAvailability(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await dio.patch('/availability/$id', data: body);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteAvailability(String id) async {
    await dio.delete('/availability/$id');
  }

  Future<List<dynamic>> getTodayInterviews() async {
    final response = await dio.get('/interviews/today');
    return response.data as List<dynamic>;
  }
}
