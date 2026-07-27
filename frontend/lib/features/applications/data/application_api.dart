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

  Future<void> apply(String shareToken, Map<String, dynamic> data) async {
    await dio.post('/applications/$shareToken', data: data);
  }
}
