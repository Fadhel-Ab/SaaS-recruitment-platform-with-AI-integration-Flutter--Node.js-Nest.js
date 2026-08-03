import 'package:dio/dio.dart';

class SearchApi {
  final Dio dio;

  SearchApi(this.dio);

  Future<Map<String, dynamic>> search(String query) async {
    final response = await dio.get('/search', queryParameters: {'q': query});
    return Map<String, dynamic>.from(response.data as Map);
  }
}
