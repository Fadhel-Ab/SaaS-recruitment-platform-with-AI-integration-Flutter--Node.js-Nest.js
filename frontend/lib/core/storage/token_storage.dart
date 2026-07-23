import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await storage.write(key: 'access_token', value: token);
  }

  Future<String?> getToken() async {
    return storage.read(key: 'access_token');
  }

  Future<void> clear() async {
    await storage.delete(key: 'access_token');
  }
}
