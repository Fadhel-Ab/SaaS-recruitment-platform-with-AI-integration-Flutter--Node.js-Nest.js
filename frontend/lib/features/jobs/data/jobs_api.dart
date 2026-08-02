import 'package:dio/dio.dart';

class JobsApi {
  final Dio dio;

  JobsApi(this.dio);

  Future<List<dynamic>> getJobs() async {
    final response = await dio.get('/jobs');
    return response.data;
  }

  Future<dynamic> getJob(String shareToken) async {
    final response = await dio.get('/$shareToken');

    return response.data;
  }

  Future<dynamic> getMyJobs() async {
    final response = await dio.get('/jobs/my');

    return response.data;
  }

  Future<dynamic> createJob(Map<String, dynamic> data) async {
    final response = await dio.post('/jobs', data: data);

    return response.data;
  }
}
