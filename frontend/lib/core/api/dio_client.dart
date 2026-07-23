import 'package:dio/dio.dart';
import 'api_constants.dart';

class DioClient {

  late final Dio dio;


  DioClient() {

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,

        headers: {
          'Content-Type': 'application/json',
        },

        connectTimeout:
            const Duration(seconds: 10),

        receiveTimeout:
            const Duration(seconds: 10),
      ),
    );

  }
}