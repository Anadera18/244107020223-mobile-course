import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'route_parser.dart';

typedef MessageLogger = void Function(String source, RemoteMessage message);

/// Background handler: MUST be top-level (not a class method) because it runs
/// in a separate isolate, and MUST carry the entry-point pragma so release
/// builds do not tree-shake it. No BuildContext, no Riverpod here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Light work only. Never log tokens. Navigation happens on tap.
  debugPrint(
    '[FCM background] id=${message.messageId} '
    'route=${routeFromMessage(message.data)}',
  );
}

/// Thin wrapper around firebase_messaging + flutter_local_notifications.
/// Nothing here touches BuildContext; navigation is passed in as callbacks.
class PushService {
  PushService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? local,
  })  : _fcm = messaging ?? FirebaseMessaging.instance,
        _local = local ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _local;

  /// Android 13+ and iOS need a runtime permission prompt.
  Future<bool> requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// [onTap] is called with the route when a foreground (local) banner is tapped.
  Future<void> initLocalNotifications({
    required void Function(String route) onTap,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) onTap(payload);
      },
    );
    // iOS: stop the system from also drawing a banner in the foreground,
    // otherwise the user sees a duplicate next to our local notification.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
  }

  /// 1. fetch the token and send it to the backend,
  /// 2. keep listening for rotation. Ignoring onTokenRefresh leaves the
  ///    backend holding a stale token and pushes silently stop arriving.
  /// The caller owns (and must cancel) the returned subscription.
  Future<StreamSubscription<String>> initFcmToken({
    required Future<void> Function(String token, bool refreshed) onToken,
  }) async {
    final token = await _fcm.getToken();
    if (token != null) await onToken(token, false);
    return _fcm.onTokenRefresh.listen((newToken) => onToken(newToken, true));
  }

  Future<void> subscribeTopic(String topic) => _fcm.subscribeToTopic(topic);
  Future<void> unsubscribeTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  /// Foreground: the system draws NO banner, so show one via a local
  /// notification. Background tap: onMessageOpenedApp.
  List<StreamSubscription<RemoteMessage>> listenForeground({
    required void Function(String route) go,
    required MessageLogger onEvent,
  }) {
    final foreground = FirebaseMessaging.onMessage.listen((message) async {
      final route = routeFromMessage(message.data);
      onEvent('foreground', message);
      const androidDetails = AndroidNotificationDetails(
        'announcement',
        'Campus Announcements',
        importance: Importance.high,
        priority: Priority.high,
      );
      await _local.show(
        message.hashCode & 0x7fffffff, // must fit a 32-bit int
        message.notification?.title ?? 'Announcement',
        message.notification?.body ?? '',
        const NotificationDetails(android: androidDetails),
        payload: route,
      );
    });

    final opened = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onEvent('background-tap', message);
      go(routeFromMessage(message.data));
    });

    return [foreground, opened];
  }

  /// Terminated: the app was killed and launched by tapping a notification.
  /// Call this once the router exists.
  Future<void> handleTerminated({
    required void Function(String route) go,
    required MessageLogger onEvent,
  }) async {
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      onEvent('terminated-tap', initial);
      go(routeFromMessage(initial.data));
    }
  }
}
