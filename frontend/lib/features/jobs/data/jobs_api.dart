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

  Future<List<dynamic>> generateInterviewQuestions(
    Map<String, dynamic> data,
  ) async {
    final response = await dio.post(
      '/jobs/generate-interview-questions',
      data: data,
    );

    return response.data['questions'] as List<dynamic>;
  }

  Future<List<dynamic>> getDefaultAvailability() async {
    final response = await dio.get('/jobs/default-availability');
    return response.data as List<dynamic>;
  }

  Future<dynamic> updateJob(String id, Map<String, dynamic> data) async {
    final response = await dio.patch('/jobs/$id', data: data);
    return response.data;
  }
}
