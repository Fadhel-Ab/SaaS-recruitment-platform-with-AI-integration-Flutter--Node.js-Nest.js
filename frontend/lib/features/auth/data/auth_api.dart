import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';

class AuthApi {
  final Dio dio;

  AuthApi(this.dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dio.post(
      ApiConstants.login,

      data: {'email': email, 'password': password},
    );

    return response.data;
  }
}
