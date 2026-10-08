# Screenshots to capture

Capture these on your own device/emulator and save them with these exact names
(the report in `../README.md` links to them). **Never show a full token**; the
Debug page already truncates tokens to 12 characters.

| File | What to show |
| --- | --- |
| `lab1-login.png` | Login page, and the error text after a wrong password |
| `lab1-home.png` | Announcement list after a successful login |
| `lab1-refresh.png` | Debug page: access token before and after "Expire" + "Call protected API" (token prefix changes, HTTP 200) |
| `lab1-session-expired.png` | After "Kill refresh token" + API call: back on the login page |
| `lab2-permission.png` | Android 13+ notification permission dialog |
| `lab2-token-debug.png` | Debug page: truncated FCM token, permission granted, backend sync line |
| `lab2-token-refresh.png` | Debug page after clearing app data/reinstall: new truncated token, refresh count |
| `fcm-console-test.png` | Firebase Console campaign + the banner on the phone |
| `lab3-foreground.png` | Local banner while the app is open, and the destination page |
| `lab3-background.png` | System banner with the app minimised, and the destination page |
| `lab3-terminated.png` | App launched from a banner after swipe-closing it, and the destination page |
| `lab3-topic.png` | Debug page topic switch + a topic message arriving |
| `flutteranalyzetest.png` | Terminal with `flutter analyze` (no issues) and `flutter test` (all passed) |
