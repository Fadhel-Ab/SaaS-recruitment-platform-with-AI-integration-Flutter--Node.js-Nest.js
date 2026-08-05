import 'package:dio/dio.dart';
import '../../../../core/api/api_constants.dart';

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

  Future<Map<String, dynamic>> register(String fullName, String email, String password, String role, {String? phone}) async {
    final response = await dio.post(
      ApiConstants.register,
      data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMe(String token) async {
    final response = await dio.get(
      '/auth/me',

      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(String phone) async {
    final response = await dio.patch('/users/me', data: {'phone': phone});
    return Map<String, dynamic>.from(response.data as Map);
  }
}
