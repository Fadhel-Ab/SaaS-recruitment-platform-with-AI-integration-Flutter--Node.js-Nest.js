import 'package:dio/dio.dart';

class JobsApi {
  final Dio dio;

  JobsApi(this.dio);

  Future<List<dynamic>> getJobs() async {
    final response = await dio.get('/jobs');
    print(response.data);
    return response.data;
  }
}
