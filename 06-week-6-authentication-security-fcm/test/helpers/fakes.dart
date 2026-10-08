import 'dart:typed_data';

import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:dio/dio.dart';

/// In-memory TokenStore: no platform channel, so it works in unit tests.
class FakeTokenStore extends TokenStore {
  String? access;
  String? refresh;
  int clearCount = 0;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    clearCount++;
  }
}

/// Counts refresh calls and can be told to fail.
class FakeAuthRepository extends AuthRepository {
  int refreshCalls = 0;
  bool failRefresh = false;
  String renewed = 'new';

  @override
  Future<String> refresh(String refreshToken) async {
    refreshCalls++;
    if (failRefresh || refreshToken.isEmpty) throw Exception('refresh dead');
    return renewed;
  }
}

/// Dio adapter whose HTTP status is decided by [respond].
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.respond);

  final int Function(RequestOptions options) respond;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      '{"ok":true}',
      respond(options),
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
