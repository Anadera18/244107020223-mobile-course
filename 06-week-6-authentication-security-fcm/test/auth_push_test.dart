import 'package:campus_notify/data/token_store.dart';
import 'package:campus_notify/messaging/route_parser.dart';
import 'package:campus_notify/providers/auth_provider.dart';
import 'package:campus_notify/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fakes.dart';

ProviderContainer makeContainer(FakeTokenStore store) {
  final container = ProviderContainer(
    overrides: [tokenStoreProvider.overrideWithValue(store)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('routeFromMessage (pure, no Firebase)', () {
    test('handles empty and slash-less routes', () {
      expect(routeFromMessage({}), '/');
      expect(routeFromMessage({'route': 'announcement/3'}), '/announcement/3');
      expect(routeFromMessage({'route': '/announcement/3'}), '/announcement/3');
    });

    test('ignores blank or non-string route values', () {
      expect(routeFromMessage({'route': '   '}), '/');
      expect(routeFromMessage({'route': 42}), '/');
    });

    test('data payload carries the announcement id', () {
      const data = <String, dynamic>{'route': '/announcement/3', 'id': '3'};
      expect(data['id'], '3');
      expect(routeFromMessage(data), AppRoutes.announcement('3'));
    });
  });

  group('truncateToken', () {
    test('shows only the first 12 characters', () {
      final shown = truncateToken('abcdefghijklmnopqrstuvwxyz');
      expect(shown, 'abcdefghijkl...');
      expect(shown.contains('xyz'), isFalse);
    });

    test('never reveals a short token in full', () {
      expect(truncateToken('abcd'), 'ab...');
    });
  });

  group('AuthNotifier (fake secure storage)', () {
    test('no token -> logged out', () async {
      final container = makeContainer(FakeTokenStore());
      expect(await container.read(authStateProvider.future), isFalse);
    });

    test('existing token -> logged in', () async {
      final store = FakeTokenStore()..access = 'mock-access-x';
      final container = makeContainer(store);
      expect(await container.read(authStateProvider.future), isTrue);
    });

    test('login saves both tokens in secure storage', () async {
      final store = FakeTokenStore();
      final container = makeContainer(store);
      await container.read(authStateProvider.future);

      await container
          .read(authStateProvider.notifier)
          .login('andhika@polinema.ac.id', 'secret1');

      expect(container.read(authStateProvider).value, isTrue);
      expect(store.access, startsWith('mock-access-'));
      expect(store.refresh, startsWith('mock-refresh-'));
    });

    test('invalid credentials -> error state, nothing stored', () async {
      final store = FakeTokenStore();
      final container = makeContainer(store);
      await container.read(authStateProvider.future);

      await container.read(authStateProvider.notifier).login('bad', '123');

      expect(container.read(authStateProvider).hasError, isTrue);
      expect(store.access, isNull);
      expect(store.refresh, isNull);
    });

    test('logout clears the session', () async {
      final store = FakeTokenStore()
        ..access = 'mock-access-x'
        ..refresh = 'mock-refresh-x';
      final container = makeContainer(store);
      await container.read(authStateProvider.future);

      await container.read(authStateProvider.notifier).logout();

      expect(await container.read(authStateProvider.future), isFalse);
      expect(store.access, isNull);
      expect(store.refresh, isNull);
    });
  });
}
