import 'package:frontend/features/jobs/data/jobs_api.dart';
import 'package:frontend/features/jobs/models/job_model.dart';

class JobsRepository {
  final JobsApi api;

  JobsRepository(this.api);

  Future<List<JobModel>> getJobs() async {
    final response = await api.getJobs();
    return response.map<JobModel>((e) => JobModel.fromJson(e)).toList();
  }

  Future<JobModel> getJob(String shareToken) async {
    final response = await api.getJob('/jobs/$shareToken');
    return JobModel.fromJson(response);
  }

  Future<List<JobModel>> getMyJobs() async {
    final data = await api.getMyJobs();

    return (data as List).map((json) => JobModel.fromJson(json)).toList();
  }
}
