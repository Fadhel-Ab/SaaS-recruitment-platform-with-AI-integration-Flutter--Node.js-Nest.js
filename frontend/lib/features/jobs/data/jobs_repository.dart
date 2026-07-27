import 'package:frontend/features/jobs/data/jobs_api.dart';
import 'package:frontend/features/jobs/models/job_model.dart';

class JobsRepository {
  final JobsApi api;

  JobsRepository(this.api);

  Future<List<JobModel>> getJobs() async {
    final response = await api.getJobs();
    return response.map<JobModel>((e) => JobModel.fromJson(e)).toList();
  }
}
