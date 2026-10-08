import 'package:dio/dio.dart';

import '../config.dart';
import 'auth_repository.dart';
import 'token_store.dart';

const _retriedKey = 'auth_retried';

/// Builds the Dio client with automatic token refresh.
///
/// Rules:
///  * every request gets `Authorization: Bearer <access>`;
///  * a 401 triggers exactly ONE refresh and ONE replay of the request;
///  * parallel 401s share a single refresh call;
///  * if the refresh itself fails the session is cleared and
///    [onSessionExpired] is called so the router sends the user to /login.
Dio buildApiClient(
  TokenStore store,
  AuthRepository auth, {
  String baseUrl = kApiBaseUrl,
  HttpClientAdapter? adapter,
  void Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  if (adapter != null) dio.httpClientAdapter = adapter;

  Future<String?>? inflight;

  Future<String?> renewAccess(String refreshToken) {
    return inflight ??= () async {
      try {
        final renewed = await auth.refresh(refreshToken);
        await store.save(access: renewed, refresh: refreshToken);
        return renewed;
      } catch (_) {
        await store.clear(); // refresh is dead too -> force re-login
        onSessionExpired?.call();
        return null;
      } finally {
        inflight = null;
      }
    }();
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        final request = e.requestOptions;
        final is401 = e.response?.statusCode == 401;
        if (!is401 || request.extra[_retriedKey] == true) {
          return handler.next(e); // not ours, or already retried once
        }

        final refreshToken = await store.readRefresh();
        if (refreshToken == null) return handler.next(e); // never logged in

        // If a parallel request already rotated the token, just replay.
        final sent = request.headers['Authorization'];
        final current = await store.readAccess();
        final String? token;
        if (current != null && sent != 'Bearer $current') {
          token = current;
        } else {
          token = await renewAccess(refreshToken);
        }
        if (token == null) return handler.next(e);

        request.extra[_retriedKey] = true;
        request.headers['Authorization'] = 'Bearer $token';
        try {
          final retry = await dio.fetch<dynamic>(request);
          return handler.resolve(retry);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      },
    ),
  );
  return dio;
}
