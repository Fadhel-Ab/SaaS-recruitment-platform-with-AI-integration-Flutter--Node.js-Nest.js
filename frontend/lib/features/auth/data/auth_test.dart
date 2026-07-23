import '../../../core/api/dio_client.dart';
import 'auth_api.dart';

Future<void> testLogin() async {
  final dioClient = DioClient();

  final api = AuthApi(dioClient.dio);

  final response = await api.login('Ali@test.com', '123456');

  print(response);
}
