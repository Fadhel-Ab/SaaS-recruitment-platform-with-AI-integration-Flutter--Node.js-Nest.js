import 'package:frontend/features/jobs/data/jobs_api.dart';
import 'package:frontend/features/jobs/models/create_job_request.dart';
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

  Future<void> createJob(CreateJobRequest request) async {
    await api.createJob(request.toJson());
  }

  Future<List<String>> generateInterviewQuestions(
    CreateJobRequest request,
  ) async {
    // The backend DTO for this endpoint only accepts title/description/
    // requirements (forbidNonWhitelisted is on) so we can't reuse toJson().
    final data = await api.generateInterviewQuestions({
      'title': request.title,
      'description': request.description,
      'requirements': request.requirements,
    });
    return data.map((e) => e.toString()).toList();
  }
}
