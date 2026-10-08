import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// In-memory fake campus API so the app runs with no server.
/// A token is "valid" when it starts with `mock-access-`. Anything else
/// (for example `expired-access`, set from the Debug page) gets a 401.
class MockApiAdapter implements HttpClientAdapter {
  MockApiAdapter({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;

  static const announcements = <Map<String, Object>>[
    {
      'id': 1,
      'title': 'Welcome to the new semester',
      'body': 'Classes start on Monday. Check your schedule in SIAKAD.',
      'date': '2026-09-28',
    },
    {
      'id': 2,
      'title': 'Library opening hours',
      'body': 'The library is open 08:00 to 20:00 on weekdays.',
      'date': '2026-09-29',
    },
    {
      'id': 3,
      'title': 'Schedule changed',
      'body': 'Mobile class moved to Room A2 at 1:00 PM.',
      'date': '2026-10-01',
    },
    {
      'id': 4,
      'title': 'Wi-Fi maintenance',
      'body': 'Campus Wi-Fi will be down on Saturday 22:00 to 24:00.',
      'date': '2026-10-02',
    },
  ];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await Future<void>.delayed(latency);

    final auth = options.headers['Authorization'];
    final token = auth is String ? auth.replaceFirst('Bearer ', '') : '';
    if (!token.startsWith('mock-access-')) {
      return _json(401, {'error': 'token_expired'});
    }

    final path = options.path;
    if (options.method == 'GET' && path == '/announcements') {
      return _json(200, {'data': announcements});
    }
    if (options.method == 'GET' && path.startsWith('/announcements/')) {
      final id = path.substring('/announcements/'.length);
      for (final item in announcements) {
        if ('${item['id']}' == id) return _json(200, item);
      }
      return _json(404, {'error': 'not_found'});
    }
    if (options.method == 'POST' && path == '/devices') {
      return _json(201, {'status': 'registered'});
    }
    return _json(404, {'error': 'not_found'});
  }

  ResponseBody _json(int status, Object body) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
