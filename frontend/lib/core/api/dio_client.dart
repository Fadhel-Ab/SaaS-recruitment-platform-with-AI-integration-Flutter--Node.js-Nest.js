import 'package:dio/dio.dart';
import 'package:frontend/features/auth/data/api/auth_interceptor.dart';

import '../storage/token_storage.dart';
import 'api_constants.dart';

class DioClient {
  late final Dio dio;

  DioClient(TokenStorage storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,

        headers: {'Content-Type': 'application/json'},

        connectTimeout: const Duration(seconds: 10),

        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    dio.interceptors.add(AuthInterceptor(storage));
  }
}
