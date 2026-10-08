import 'package:campus_notify/data/api_errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException dioError(DioExceptionType type, {int? status}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: type,
    response: status == null
        ? null
        : Response<dynamic>(requestOptions: options, statusCode: status),
  );
}

void main() {
  test('401 -> session expired message', () {
    final msg =
        friendlyApiError(dioError(DioExceptionType.badResponse, status: 401));
    expect(msg, contains('session has expired'));
  });

  test('timeouts -> try again message', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      expect(friendlyApiError(dioError(type)), contains('too long'));
    }
  });

  test('connection error -> offline message', () {
    expect(
      friendlyApiError(dioError(DioExceptionType.connectionError)),
      contains('No internet'),
    );
  });

  test('5xx and 404 map to readable text', () {
    expect(
      friendlyApiError(dioError(DioExceptionType.badResponse, status: 503)),
      contains('server is having problems'),
    );
    expect(
      friendlyApiError(dioError(DioExceptionType.badResponse, status: 404)),
      contains('could not find'),
    );
  });

  test('plain Exception loses its "Exception: " prefix', () {
    expect(
      friendlyApiError(Exception('Invalid email or password')),
      'Invalid email or password',
    );
  });

  test('user-facing text never leaks raw exception details', () {
    final msg =
        friendlyApiError(dioError(DioExceptionType.badResponse, status: 500));
    expect(msg.contains('DioException'), isFalse);
    expect(msg.contains('RequestOptions'), isFalse);
  });
}
