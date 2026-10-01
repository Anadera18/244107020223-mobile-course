import 'package:dio/dio.dart';

/// Dilempar saat user mencoba sync dalam mode offline.
class OfflineException implements Exception {
  const OfflineException();
  @override
  String toString() => 'Offline: tidak bisa menghubungi server.';
}

/// Mengubah exception teknis menjadi pesan ramah untuk UI.
String friendlyError(Object error) {
  if (error is OfflineException) {
    return 'Anda sedang offline dan belum ada data cache.';
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Cannot reach the server. Check your internet connection.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;
        if (code == 404) return 'Data not found (404).';
        if (code >= 500) return 'Server error. Please try again later.';
        return 'Request failed ($code).';
      default:
        return 'Unexpected network error.';
    }
  }
  return error.toString().replaceFirst('Exception: ', '');
}
