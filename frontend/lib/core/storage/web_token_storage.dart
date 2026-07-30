import 'package:shared_preferences/shared_preferences.dart';
import 'token_storage.dart';

class WebTokenStorage implements TokenStorage {
  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('access_token', token);
  }

  @override
  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('access_token');
  }

  @override
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('access_token');
  }
}
