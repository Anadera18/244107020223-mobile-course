import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Documented endpoint: POST /devices  body {fcm_token, platform}.
/// The backend stores the token per user.
class DeviceRepository {
  DeviceRepository(this._dio);
  final Dio _dio;

  Future<void> registerToken(String token) async {
    await _dio.post<dynamic>(
      '/devices',
      data: {'fcm_token': token, 'platform': defaultTargetPlatform.name},
    );
  }
}
