# AI Challenge: FCM + Auth (Week 6)

## 1. Prompt used

```
Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Generate a PushService with:
- requestPermission + getToken + onTokenRefresh (send to POST /devices)
- onMessage (show a local notification manually)
- onMessageOpenedApp + getInitialMessage (navigate to data.route)
- subscribe/unsubscribe topic campus-announcement
- top-level background handler with @pragma('vm:entry-point')
Mark which parts DIFFER for Android 13+ vs iOS,
and which parts must never touch BuildContext.
```

## 2. Initial AI output (baseline draft)

Baseline used for comparison: the codelab reference snippets, which is the shape an AI draft for this prompt is expected to take:

- top-level functions `requestNotificationPermission`, `initLocalNotifications`, `initFcmToken`,
  `listenForeground`, `handleTerminated` sharing one global `FlutterLocalNotificationsPlugin _local`;
- a global `String? pendingDeepLink` written by the local-notification tap callback;
- a Dio interceptor that refreshes on 401 and replays with `dio.fetch`, clearing the store when refresh fails;
- `routeFromMessage(Map<String, String>)` defined inside the test file.

> Student note: if you also ran the prompt on your own AI assistant, paste its raw answer here
> unedited. The grader asks to keep the **initial** output next to the fixes.

## 3. Verification checklist (AI Verification Checklist from the codelab)

| Check | Finding in the baseline | Final code | Proven on device? |
| --- | --- | --- | --- |
| Background handler top-level + `@pragma('vm:entry-point')`? | Top-level, pragma present. A class-method version would have been rejected. | `firebaseMessagingBackgroundHandler` in `lib/messaging/push_service.dart`; logs only `messageId` + route | [ ] |
| Does `onTokenRefresh` send the new token to the backend, not just print? | Listener forwarded to `onToken`, but a failed POST was an unhandled async error and the new token was never kept for display | `initFcmToken` -> `PushNotifier._registerToken` -> `POST /devices` inside try/catch, result shown on Debug page | [ ] |
| Foreground uses a manual local notification? | Yes. On iOS the system could also draw its own banner (duplicate). | `onMessage` -> `_local.show`; `setForegroundNotificationPresentationOptions(false, false, false)` | [ ] |
| Do taps from all three states land on the right route? | **Bug:** foreground banner tap only wrote `pendingDeepLink`; nothing navigated while the app was alive. | `initLocalNotifications(onTap: go)` navigates immediately; background tap uses `onMessageOpenedApp`; terminated uses `getInitialMessage` | [ ] (fill the test matrix in the README) |
| Tokens/secrets free from hardcoding and full logging? | Baseline never prints a full token, but the mock access token embeds the email address (acceptable for a mock only, never for a real token). | No full token is stored in UI state or logged; `truncateToken` (12 chars + `...`); base URL via `--dart-define` | [ ] |
| Final decision and rationale | See section 5 | | |

## 4. Manual fix list

1. **Refresh loop guard.** The baseline's replay (`dio.fetch`) goes through the interceptor again; a second 401 would refresh again forever. Added a one-shot `auth_retried` flag on the request.
2. **One refresh for parallel 401s.** Added a shared in-flight future plus a "token already rotated, just replay" check.
3. **Session expiry reaches the router.** Clearing storage alone left `authStateProvider` saying "logged in". The interceptor now calls `onSessionExpired`, which invalidates `authStateProvider`, so the guard redirects to `/login`.
4. **Refresh failure vs replay failure.** A 500 after a successful refresh must not log the user out; only a failed refresh does.
5. **Foreground tap navigation** (see checklist above).
6. **Deep link while logged out.** The route is remembered by the guard and opened right after login.
7. **Notification id.** `message.hashCode & 0x7fffffff` so it always fits a 32-bit int.
8. **Firebase not configured.** `Firebase.initializeApp()` is wrapped in try/catch so the app still starts; Debug page explains why push is off.
9. **Testability.** `routeFromMessage` moved to `lib/messaging/route_parser.dart`, takes `Map<String, dynamic>` (the real FCM type) and ignores non-string routes. The `DioException` mapping moved to `lib/data/api_errors.dart`. Route strings moved to `lib/routes.dart`.

## 5. Android 13+ vs iOS, and what must never touch BuildContext

| Topic | Android 13+ | iOS |
| --- | --- | --- |
| Runtime permission | `POST_NOTIFICATIONS` in the manifest + `requestPermission()` | `requestPermission()`; `provisional` status exists only here |
| Foreground display | No automatic banner -> local notification | Disable system presentation options, otherwise duplicates |
| Channel | `AndroidNotificationDetails('announcement', ...)` creates the channel | Not applicable |
| Setup | `google-services.json`, desugaring for flutter_local_notifications | `GoogleService-Info.plist`, APNs key in Firebase Console, Push capability in Xcode |

Never touch `BuildContext`: the background handler (separate isolate), `PushService`, `routeFromMessage`, the Dio interceptor. Navigation is passed in as a `go(route)` callback.

## 6. Decision

Keep: mock auth behind `AuthRepository` (swap point for Firebase Auth), tokens only in `flutter_secure_storage`, combined `notification + data` payloads, topic for broadcasts and device token for personal messages.
Reject: any token in SharedPreferences, data-only messages (Android never shows them automatically), and the baseline's global `pendingDeepLink`.
