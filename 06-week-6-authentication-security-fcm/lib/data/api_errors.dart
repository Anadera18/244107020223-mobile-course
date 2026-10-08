import 'package:dio/dio.dart';

/// Maps any thrown object to a message that is safe to show to the user.
/// The UI only ever receives text, never a raw DioException.
String friendlyApiError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The server took too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Check your network and retry.';
      case DioExceptionType.badResponse:
        return _fromStatus(error.response?.statusCode);
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  if (error is Exception) {
    final text = error.toString();
    const prefix = 'Exception: ';
    return text.startsWith(prefix) ? text.substring(prefix.length) : text;
  }
  return 'Something went wrong. Please try again.';
}

String _fromStatus(int? code) {
  if (code == 401) return 'Your session has expired. Please log in again.';
  if (code == 403) return 'You do not have permission to do that.';
  if (code == 404) return 'We could not find what you were looking for.';
  if (code != null && code >= 500) {
    return 'The server is having problems. Please try again later.';
  }
  return 'Request failed (HTTP ${code ?? 'unknown'}).';
}
