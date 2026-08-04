import 'dart:typed_data';

import 'package:frontend/features/applications/data/application_api.dart';
import 'package:frontend/features/applications/model/applicant_summary.dart';
import 'package:frontend/features/applications/model/application_detail.dart';
import 'package:frontend/features/applications/model/application_result.dart';
import 'package:frontend/features/applications/model/create_application_request.dart';
import 'package:frontend/features/applications/model/my_application_summary.dart';
import 'package:frontend/features/applications/model/pipeline_entry.dart';

class ApplicationRepository {
  final ApplicationApi api;

  ApplicationRepository(this.api);
  Future<String> uploadCv({
    String? path,
    Uint8List? bytes,
    required String fileName,
  }) {
    return api.uploadCv(path: path, bytes: bytes, fileName: fileName);
  }

  Future<ApplicationResult> submitApplication(
    String shareToken,
    CreateApplicationRequest request,
  ) async {
    final response = await api.apply(shareToken, request.toJson());
    return ApplicationResult.fromJson(response);
  }

  Future<List<ApplicantSummary>> getJobApplications(String jobId) async {
    final data = await api.getJobApplications(jobId);
    return data
        .map((e) => ApplicantSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ApplicationDetail> getApplicationDetails(
    String applicationId,
  ) async {
    final response = await api.getApplicationDetails(applicationId);
    return ApplicationDetail.fromJson(response);
  }

  Future<ApplicationDetail> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    await api.updateApplicationStatus(applicationId, status);
    return getApplicationDetails(applicationId);
  }

  Future<List<MyApplicationSummary>> getMyApplications() async {
    final data = await api.getMyApplications();
    return data
        .map(
          (e) => MyApplicationSummary.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> getMyProfile() {
    return api.getMyProfile();
  }

  Future<void> startAiCall(String applicationId) {
    return api.startAiCall(applicationId);
  }

  Future<List<PipelineEntry>> getPipeline() async {
    final data = await api.getPipeline();
    return data
        .map((e) => PipelineEntry.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Returns (updatedCount, skippedCount).
  Future<(int, int)> bulkUpdateStatus(
    List<String> applicationIds,
    String status,
  ) async {
    final response = await api.bulkUpdateStatus(applicationIds, status);
    final updated = (response['updated'] as List?)?.length ?? 0;
    final skipped = (response['skipped'] as List?)?.length ?? 0;
    return (updated, skipped);
  }
}
