import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';
import 'providers/push_provider.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must be initialised before runApp. If google-services.json is
  // not set up yet the app still runs (login + token refresh work), and the
  // Debug page explains that push is not configured.
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (e) {
    debugPrint('Firebase not initialised: $e');
  }

  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
      child: const CampusNotifyApp(),
    ),
  );
}

class CampusNotifyApp extends ConsumerWidget {
  const CampusNotifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start push only while logged in, stop it on logout.
    ref.listen<AsyncValue<bool>>(authStateProvider, (previous, next) {
      final loggedIn = next.valueOrNull ?? false;
      final wasLoggedIn = previous?.valueOrNull ?? false;
      if (loggedIn) {
        ref.read(pushProvider.notifier).start();
      } else if (wasLoggedIn) {
        ref.read(pushProvider.notifier).stop();
      }
    });

    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Campus Notify',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F7DC9),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
