import 'package:dio/dio.dart';

class DashboardApi {
  final Dio dio;

  DashboardApi(this.dio);

  Future<dynamic> getSummary() async {
    final response = await dio.get('/dashboard');

    return response.data;
  }
}
