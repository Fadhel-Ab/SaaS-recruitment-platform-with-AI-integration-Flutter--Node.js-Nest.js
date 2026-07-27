import 'package:dio/dio.dart';
import 'package:frontend/features/jobs/models/job_model.dart';

class JobsApi {
  final Dio dio;

  JobsApi(this.dio);

  Future<List<dynamic>> getJobs() async {
    final response = await dio.get('/jobs');
    print(response.data);
    return response.data;
  }

  Future<JobModel> getJob(String shareToken) async {
    final response = await dio.get('/jobs/$shareToken');

    return JobModel.fromJson(response.data);
  }
}
