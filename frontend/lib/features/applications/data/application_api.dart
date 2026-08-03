import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApplicationApi {
  final Dio dio;

  ApplicationApi(this.dio);

  Future<String> uploadCv({
    String? path,
    Uint8List? bytes,
    required String fileName,
  }) async {
    MultipartFile file;

    if (kIsWeb) {
      file = MultipartFile.fromBytes(bytes!, filename: fileName);
    } else {
      file = await MultipartFile.fromFile(path!, filename: fileName);
    }

    final formData = FormData.fromMap({'cvs': file});

    final response = await dio.post('/applications/upload', data: formData);

    return response.data['fileName'];
  }

  Future<Map<String, dynamic>> apply(String shareToken, Map<String, dynamic> data) async {
    final response = await dio.post('/applications/$shareToken', data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> getJobApplications(String jobId) async {
    final response = await dio.get('/applications/job/$jobId');
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> getMyApplications() async {
    final response = await dio.get('/applications/mine');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getApplicationDetails(
    String applicationId,
  ) async {
    final response = await dio.get('/applications/$applicationId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    final response = await dio.patch(
      '/applications/$applicationId/status',
      data: {'status': status},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
