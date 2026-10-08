import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../config.dart';
import '../data/api_errors.dart';
import '../data/device_repository.dart';
import '../data/token_store.dart';
import '../messaging/push_service.dart';
import '../messaging/route_parser.dart';
import '../router.dart';
import 'auth_provider.dart';

/// Overridden in main() once Firebase.initializeApp() succeeded.
final firebaseReadyProvider = Provider<bool>((ref) => false);

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(ref.watch(dioProvider)),
);

class PushState {
  const PushState({
    this.status = 'Not started',
    this.permissionGranted,
    this.tokenPreview,
    this.tokenRefreshCount = 0,
    this.lastSync,
    this.topicSubscribed = false,
    this.events = const [],
  });

  final String status;
  final bool? permissionGranted;
  final String? tokenPreview;
  final int tokenRefreshCount;
  final String? lastSync;
  final bool topicSubscribed;
  final List<String> events;

  PushState copyWith({
    String? status,
    bool? permissionGranted,
    String? tokenPreview,
    int? tokenRefreshCount,
    String? lastSync,
    bool? topicSubscribed,
    List<String>? events,
  }) {
    return PushState(
      status: status ?? this.status,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      tokenPreview: tokenPreview ?? this.tokenPreview,
      tokenRefreshCount: tokenRefreshCount ?? this.tokenRefreshCount,
      lastSync: lastSync ?? this.lastSync,
      topicSubscribed: topicSubscribed ?? this.topicSubscribed,
      events: events ?? this.events,
    );
  }
}

final pushProvider =
    NotifierProvider<PushNotifier, PushState>(PushNotifier.new);

/// Orchestrates FCM after login: permission -> token -> backend -> topic ->
/// foreground / background / terminated handlers.
class PushNotifier extends Notifier<PushState> {
  PushService? _service;
  final List<StreamSubscription<dynamic>> _subs = [];
  bool _started = false;

  @override
  PushState build() {
    ref.onDispose(_cancelAll);
    return const PushState();
  }

  void _cancelAll() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  void _go(String route) => ref.read(routerProvider).go(route);

  Future<void> start() async {
    if (_started) return;
    _started = true;

    if (!ref.read(firebaseReadyProvider)) {
      state = state.copyWith(
        status: 'Firebase not configured (see docs/firebase-setup.md)',
      );
      return;
    }

    try {
      final service = PushService();
      _service = service;

      await service.initLocalNotifications(onTap: _go);

      final granted = await service.requestPermission();
      state = state.copyWith(permissionGranted: granted);
      if (!granted) {
        state = state.copyWith(status: 'Notification permission denied');
        return;
      }

      _subs.add(await service.initFcmToken(onToken: _registerToken));

      await service.subscribeTopic(kAnnouncementTopic);
      state = state.copyWith(topicSubscribed: true);

      _subs.addAll(service.listenForeground(go: _go, onEvent: _log));
      await service.handleTerminated(go: _go, onEvent: _log);

      state = state.copyWith(status: 'Ready');
    } catch (e) {
      state = state.copyWith(status: 'Push setup failed: $e');
    }
  }

  /// Called on logout so a signed-out device stops registering tokens.
  void stop() {
    _cancelAll();
    _started = false;
    _service = null;
    state = const PushState();
  }

  Future<void> setTopicSubscribed(bool on) async {
    final service = _service;
    if (service == null) return;
    try {
      if (on) {
        await service.subscribeTopic(kAnnouncementTopic);
      } else {
        await service.unsubscribeTopic(kAnnouncementTopic);
      }
      state = state.copyWith(topicSubscribed: on);
    } catch (e) {
      state = state.copyWith(status: 'Topic error: $e');
    }
  }

  Future<void> _registerToken(String token, bool refreshed) async {
    state = state.copyWith(
      tokenPreview: truncateToken(token), // never keep/log the full token
      tokenRefreshCount:
          refreshed ? state.tokenRefreshCount + 1 : state.tokenRefreshCount,
      lastSync: 'Sending to POST /devices ...',
    );
    try {
      await ref.read(deviceRepositoryProvider).registerToken(token);
      state = state.copyWith(
        lastSync: '${refreshed ? 'Refreshed' : 'Initial'} token registered '
            'at ${_hhmmss(DateTime.now())}',
      );
    } catch (e) {
      state = state.copyWith(
        lastSync: 'Registration failed: ${friendlyApiError(e)}',
      );
    }
  }

  void _log(String source, RemoteMessage message) {
    final entry =
        '${_hhmmss(DateTime.now())}  $source -> ${routeFromMessage(message.data)}';
    state = state.copyWith(events: [entry, ...state.events].take(10).toList());
  }

  String _hhmmss(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
