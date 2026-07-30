import 'package:dio/dio.dart';
import 'package:frontend/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage storage;

  AuthInterceptor(this.storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.readToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}
