import '../../../core/storage/token_storage.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi api;

  final TokenStorage storage;

  AuthRepository(this.api, this.storage);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await api.login(email, password);

    await storage.saveToken(result['accessToken']);

    return result;
  }
}
