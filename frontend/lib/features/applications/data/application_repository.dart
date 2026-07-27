import 'dart:typed_data';

import 'package:frontend/features/applications/data/application_api.dart';
import 'package:frontend/features/applications/model/create_application_request.dart';

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

  Future<void> submitApplication(
    String shareToken,
    CreateApplicationRequest request,
  ) {
    return api.apply(shareToken, request.toJson());
  }
}
