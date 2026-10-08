# Flutter Week 6 - Authentication, Security & FCM

| **Information** | **Detail** |
| --- | --- |
| Subject | Mobile Development |
| Name | Andhika Daffa Athaaillah |
| Absen | 02 |
| NIM | 244107020223 |

Campus Notification App: mock login with secure token storage, automatic access-token refresh
(Dio interceptor), a GoRouter auth guard, and Firebase Cloud Messaging with deep links that open
`/announcement/:id` from the foreground, background and terminated states.

## Features

- Login with route guard (unauthenticated users always land on `/login`)
- Tokens only in `flutter_secure_storage` (never SharedPreferences, never logged)
- Dio interceptor: one refresh + one replay on 401, parallel 401s share one refresh, dead refresh forces re-login
- FCM: permission, `getToken` + `onTokenRefresh` sent to `POST /devices`, `campus-announcement` topic
- Combined `notification + data` payloads, tap opens `/announcement/:id` in all three app states
- Debug page (debug builds): truncated tokens, push status, 3-state event log, buttons to force 401 / dead refresh
- Loading, error (+ Retry), empty and success states on the data pages
- Built-in mock backend, so everything except real push delivery runs without a server

## Tech Stack

Flutter, flutter_riverpod, go_router, dio, flutter_secure_storage, firebase_core, firebase_messaging, flutter_local_notifications

## How to Run

```bash
cd C:\WiseBrilliance\Mobile_Development
flutter create --project-name campus_notify 06-week-6-authentication-security-fcm
# extract the zip into Mobile_Development and choose "replace" when asked
cd 06-week-6-authentication-security-fcm
del test\widget_test.dart
flutter pub get
flutter run
flutter analyze
flutter test
```

Push notifications need the Firebase setup in [`docs/firebase-setup.md`](docs/firebase-setup.md)
(`google-services.json`, Gradle plugin, notification permission). Without it the app still runs and the
Debug page shows "Firebase not configured".

Test login: any email containing `@` and a password with 6+ characters.

## Project Structure

```
lib/
├── main.dart
├── config.dart
├── routes.dart
├── router.dart
├── data/
│   ├── token_store.dart
│   ├── auth_repository.dart
│   ├── api_client.dart
│   ├── api_errors.dart
│   ├── mock_backend.dart
│   ├── announcement_repository.dart
│   └── device_repository.dart
├── providers/
│   ├── auth_provider.dart
│   ├── announcement_provider.dart
│   └── push_provider.dart
├── messaging/
│   ├── push_service.dart
│   └── route_parser.dart
└── pages/ (login, home, announcement, debug)
test/ (auth_push_test.dart, api_client_test.dart, api_errors_test.dart, helpers/fakes.dart)
docs/ (ai-challenge.md, firebase-setup.md, payload-topic.json, payload-device.json)
screenshots/
```

---

## 1. Lab 1: Authentication & Secure Token Storage

Files: `lib/data/token_store.dart`, `lib/data/auth_repository.dart`, `lib/data/api_client.dart`, `lib/providers/auth_provider.dart`, `lib/router.dart`, `lib/pages/login_page.dart`

1. **Secure storage:** `TokenStore` is the only door for tokens (`save`, `readAccess`, `readRefresh`, `clear`) and wraps `flutter_secure_storage` (Keychain/Keystore).
2. **Auth repository:** `AuthRepository.login` and `refresh` are mocks with a comment marking the exact line where `FirebaseAuth.signInWithEmailAndPassword` or Google Sign-In plugs in. Nothing else has to change.
3. **Dio auto-refresh:** `buildApiClient` adds `Authorization: Bearer <access>`. On a 401 it refreshes once and replays the request once (`auth_retried` flag stops loops). Parallel 401s share one in-flight refresh. If the refresh fails, the store is cleared and `onSessionExpired` invalidates `authStateProvider`.
4. **Provider + route guard:** `AuthNotifier` (`AsyncNotifier<bool>`) reads the token in `build()`, and `login` uses `AsyncValue.guard()`. The GoRouter `redirect` sends logged-out users to `/login`, shows a splash while storage is read, and remembers a deep link that arrived before login.

### Result Output

![Lab 1 Login](screenshots/lab1-login.png)
![Lab 1 Home](screenshots/lab1-home.png)
![Lab 1 Refresh](screenshots/lab1-refresh.png)
![Lab 1 Session expired](screenshots/lab1-session-expired.png)

---

## 2. Lab 2: Firebase Setup, Permission & Token Lifecycle

Files: `lib/main.dart`, `lib/messaging/push_service.dart`, `lib/providers/push_provider.dart`, `lib/data/device_repository.dart`, `docs/firebase-setup.md`

1. **Register the app:** Android app in the Firebase Console, `google-services.json` in `android/app/`, `Firebase.initializeApp()` before `runApp` (wrapped in try/catch so a missing config does not crash the app).
2. **Permission:** `PushService.requestPermission()` (Android 13+ and iOS need a runtime prompt).
3. **Token lifecycle:** `getToken()` is sent to `POST /devices`, and `onTokenRefresh` is listened to for the whole session and sent again. The Debug page shows only the first 12 characters of the token, the refresh count and the last backend sync result.
4. **Console test:** a trial campaign with custom data `route=/announcement/3`, sent while the app is in the background.

### Result Output

![Lab 2 Permission](screenshots/lab2-permission.png)
![Lab 2 Token](screenshots/lab2-token-debug.png)
![Lab 2 Token refresh](screenshots/lab2-token-refresh.png)
![FCM console test](screenshots/fcm-console-test.png)

---

## 3. Lab 3: Notification Handling, Deep Links & Topics

Files: `lib/messaging/push_service.dart`, `lib/messaging/route_parser.dart`, `lib/routes.dart`, `lib/pages/announcement_page.dart`

1. **Background handler:** top-level function with `@pragma('vm:entry-point')`, registered in `main()`. No `BuildContext`, no Riverpod, logs only the message id and route.
2. **Combined payload:** `notification` (human text) + `data.route` (deep link), see `docs/payload-topic.json`.
3. **Three handlers:** `onMessage` shows a manual local notification, `onMessageOpenedApp` handles a background tap, `getInitialMessage()` handles a terminated launch. All of them go through `routeFromMessage`.
4. **Topics:** `campus-announcement` for broadcasts (subscribe/unsubscribe switch on the Debug page). Personal messages (grades, bills) use a device token.

### Mandatory Test Matrix

Same payload (`docs/payload-topic.json`) in each state. Fill the Result column after you run it on your device.

| State | Expected | How to test | Result |
| --- | --- | --- | --- |
| Foreground | Local banner appears, tap routes to `/announcement/3` | App open, send from console/backend | _pass / fail_ |
| Background | System banner appears, tap routes correctly | Press Home, send, tap banner | _pass / fail_ |
| Terminated | App opens to the right route via `getInitialMessage` | Swipe-close the app, send, tap banner | _pass / fail_ |

![Foreground](screenshots/lab3-foreground.png)
![Background](screenshots/lab3-background.png)
![Terminated](screenshots/lab3-terminated.png)
![Topic](screenshots/lab3-topic.png)

---

## 4. AI Challenge

Full prompt, baseline output, verification table, manual fix list and final decision are in [`docs/ai-challenge.md`](docs/ai-challenge.md).

### AI Verification Findings

- **Background handler:** top-level with the entry-point pragma. A class-method version would be rejected.
- **`onTokenRefresh`:** must send to the backend, not only print. It goes through `PushNotifier._registerToken` to `POST /devices`, and the result is shown on the Debug page.
- **Foreground banner:** manual local notification, and iOS system presentation is switched off to avoid duplicates.
- **Click routing bug found:** the baseline stored the tapped route in a global and never navigated while the app was open. Fixed with an `onTap` callback.
- **Interceptor bugs found:** possible infinite refresh loop, one refresh per parallel request, and a cleared session that the router never noticed. All three fixed (see the fix list).
- **Secrets:** no hardcoded tokens, no full-token logging, base URL via `--dart-define`.

---

## 5. Refactoring & Testing

### Refactoring Challenge

- **Routes (`lib/routes.dart`):** every route string lives in `AppRoutes`, used by GoRouter and by FCM deep links.
- **Message parsing (`lib/messaging/route_parser.dart`):** pure `routeFromMessage(Map<String, dynamic>)`, testable without Firebase.
- **Error mapping (`lib/data/api_errors.dart`):** `friendlyApiError` turns `DioException` (401, timeout, offline, 5xx) into text, so the UI never sees raw exceptions.

### Unit Tests (no real Firebase)

| File | What it proves |
| --- | --- |
| `test/auth_push_test.dart` | `routeFromMessage` (empty, slash-less, non-string), `truncateToken`, `AuthNotifier` login / failed login / logout with a fake secure store |
| `test/api_client_test.dart` | 401 -> exactly one refresh + replay, dead refresh clears session and requests re-login, replay failure does not loop or log out, no refresh token passes 401 through, parallel 401s share one refresh, non-401 untouched |
| `test/api_errors_test.dart` | readable messages for 401, timeouts, offline, 404, 5xx; no raw exception text |

### Verification Evidence (Test & Analyze)

![flutter analyze & test](screenshots/flutteranalyzetest.png)

---

## 6. Self-Verification Checklist

Tick each box only after you have seen it work.

- [ ] Tokens live only in `flutter_secure_storage`, never in SharedPreferences, logs or full screenshots.
- [ ] A 401 triggers exactly one refresh + retry; a dead refresh forces re-login.
- [ ] All three app states tested with evidence; taps land on `/announcement/3`.
- [ ] Topic used for broadcasts, device token for personal messages.
- [ ] `flutter analyze` is clean and all tests pass.

## 7. Mini Project Requirements (Industry Challenge)

| # | Requirement | Where |
| --- | --- | --- |
| 1 | Login + route guard | `router.dart`, `login_page.dart` |
| 2 | Secure storage, auto-refresh once on 401, logout when refresh dies | `token_store.dart`, `api_client.dart` |
| 3 | Permission, `getToken` + `onTokenRefresh` to `POST /devices`, topic subscription | `push_service.dart`, `push_provider.dart`, `device_repository.dart` |
| 4 | Combined payloads, taps open `/announcement/:id` in all states, test table | Section 3 |
| 5 | Screenshot evidence | `screenshots/` |
| 6 | At least 2 passing tests | `test/` (route parsing + session/refresh logic) |
| 7 | AI Challenge documented | `docs/ai-challenge.md` |
| 8 | Portfolio folder `06-week-6-authentication-security-fcm/` with `lib/`, `test/`, `docs/`, `README.md`, `screenshots/` | this folder |

## 8. Reflection

- **Why must refresh tokens never live in SharedPreferences? What is the risk if one leaks?**
  SharedPreferences is plain, unencrypted storage that can be read from a rooted device, a backup or a
  stolen phone. A refresh token lives for days, so whoever holds it can keep minting new access tokens
  without the password until it is revoked. That is a long-lived account takeover, whereas a leaked
  15-minute access token expires on its own. Secure storage keeps it in Keychain/Keystore.

- **What breaks if `onTokenRefresh` is ignored for a whole semester?**
  FCM tokens rotate (reinstall, data wipe, security rotation). If the backend keeps the old one, pushes
  go to a dead token and the student silently stops receiving announcements. Nothing crashes, so the bug
  stays invisible until someone misses a class change.

- **When do you use a topic vs a device token? Give one campus message example for each.**
  A topic is for broadcasts to many people who share an interest, for example "Mobile class moved to Room A2"
  sent to `campus-announcement`. A device token is for personal or sensitive messages, for example "Your
  grade was published" or a tuition bill, because topics are not private to one user.

- **Which part of the AI draft did you reject or fix, and why?**
  I fixed the foreground tap, which only saved the route in a global and never navigated, and the Dio
  interceptor, which could loop forever on repeated 401s, refreshed once per parallel request, and cleared
  the token without telling the router. I also kept `notification + data` combined and rejected data-only
  messages because Android does not show them automatically.
