import 'package:campus_notify/data/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeTokenStore store;
  late FakeAuthRepository auth;
  late bool sessionExpired;

  setUp(() {
    store = FakeTokenStore()
      ..access = 'old'
      ..refresh = 'r';
    auth = FakeAuthRepository();
    sessionExpired = false;
  });

  Dio makeDio(ScriptedAdapter adapter) => buildApiClient(
        store,
        auth,
        baseUrl: 'https://test.local',
        adapter: adapter,
        onSessionExpired: () => sessionExpired = true,
      );

  int onlyNewTokenWorks(RequestOptions o) =>
      o.headers['Authorization'] == 'Bearer new' ? 200 : 401;

  test('401 -> exactly one refresh -> request replayed with new token',
      () async {
    final adapter = ScriptedAdapter(onlyNewTokenWorks);
    final res = await makeDio(adapter).get<dynamic>('/x');

    expect(res.statusCode, 200);
    expect(auth.refreshCalls, 1);
    expect(adapter.calls, 2); // original + one replay
    expect(store.access, 'new');
    expect(store.refresh, 'r');
    expect(sessionExpired, isFalse);
  });

  test('dead refresh -> session cleared and re-login requested', () async {
    auth.failRefresh = true;
    final adapter = ScriptedAdapter(onlyNewTokenWorks);

    await expectLater(
      makeDio(adapter).get<dynamic>('/x'),
      throwsA(
        isA<DioException>().having((e) => e.response?.statusCode, 'status', 401),
      ),
    );

    expect(store.clearCount, 1);
    expect(store.access, isNull);
    expect(sessionExpired, isTrue);
  });

  test('replay that still fails does NOT loop or log out', () async {
    final adapter = ScriptedAdapter((_) => 401); // server rejects everything

    await expectLater(
      makeDio(adapter).get<dynamic>('/x'),
      throwsA(isA<DioException>()),
    );

    expect(auth.refreshCalls, 1);
    expect(adapter.calls, 2);
    expect(sessionExpired, isFalse);
  });

  test('no refresh token (never logged in) -> 401 passes through', () async {
    store
      ..access = null
      ..refresh = null;
    final adapter = ScriptedAdapter((_) => 401);

    await expectLater(
      makeDio(adapter).get<dynamic>('/x'),
      throwsA(isA<DioException>()),
    );

    expect(auth.refreshCalls, 0);
    expect(adapter.calls, 1);
  });

  test('two parallel 401s share a single refresh', () async {
    final adapter = ScriptedAdapter(onlyNewTokenWorks);
    final dio = makeDio(adapter);

    final results = await Future.wait([
      dio.get<dynamic>('/a'),
      dio.get<dynamic>('/b'),
    ]);

    expect(results.map((r) => r.statusCode), [200, 200]);
    expect(auth.refreshCalls, 1);
  });

  test('non-401 errors are not touched by the refresh logic', () async {
    final adapter = ScriptedAdapter((_) => 500);

    await expectLater(
      makeDio(adapter).get<dynamic>('/x'),
      throwsA(isA<DioException>()),
    );

    expect(auth.refreshCalls, 0);
    expect(adapter.calls, 1);
  });
}
