import 'package:dio/dio.dart';

/// Turns any error thrown by a repository call into copy that's safe and
/// useful to show a user — never a raw stack trace or `DioException(...)`
/// dump.
String friendlyErrorMessage(
  Object error, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  if (error is! DioException) return fallback;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return "Can't reach the server. Check your connection and try again.";
    case DioExceptionType.badCertificate:
      return "Couldn't establish a secure connection. Please try again.";
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.badResponse:
      return _messageFromResponse(error.response) ?? fallback;
    case DioExceptionType.unknown:
    default:
      return fallback;
  }
}

String? _messageFromResponse(Response? response) {
  if (response == null) return null;

  final data = response.data;
  if (data is Map) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) {
      return message.map((e) => e.toString()).join('\n');
    }
  }

  switch (response.statusCode) {
    case 400:
      return "That request wasn't valid. Please check the details and try again.";
    case 401:
      return 'Your session has expired. Please log in again.';
    case 403:
      return "You don't have permission to do that.";
    case 404:
      return "We couldn't find what you were looking for.";
    case 409:
      return 'That conflicts with something that already exists.';
    case 429:
      return 'Too many requests. Please slow down and try again in a moment.';
    default:
      final status = response.statusCode;
      if (status != null && status >= 500) {
        return 'Something went wrong on our end. Please try again shortly.';
      }
      return null;
  }
}
