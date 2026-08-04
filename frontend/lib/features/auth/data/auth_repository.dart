import 'package:frontend/features/auth/data/models/user_model.dart';

import '../../../core/storage/token_storage.dart';
import 'api/auth_api.dart';

class AuthRepository {
  final AuthApi api;

  final TokenStorage storage;

  AuthRepository(this.api, this.storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await api.login(email, password);

    await storage.saveToken(result['accessToken']);

    return result;
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password, String role) async {
    final result = await api.register(fullName, email, password, role);
    await storage.saveToken(result['accessToken']);
    return result;
  }

  Future<void> logout() => storage.deleteToken();

  Future<UserModel> getCurrentUser(String token) async {
    final response = await api.getMe(token);

    return UserModel.fromJson(response);
  }

  Future<void> updateProfile(String phone) => api.updateProfile(phone);
}
