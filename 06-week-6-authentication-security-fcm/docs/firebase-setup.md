# Firebase & Android setup (FCM)

The app runs without Firebase (login, secure storage and token refresh all work
against the built-in mock backend). Follow these steps to turn push notifications on.

## 1. Create the Firebase project

1. Open the [Firebase Console](https://console.firebase.google.com/) and create a project (Spark plan, free).
2. Add an **Android app**. The package name must equal `applicationId` in
   `android/app/build.gradle(.kts)`. With `flutter create --project-name campus_notify .`
   and no `--org`, that is `com.example.campus_notify`.
3. Download `google-services.json` into `android/app/`.
   **Do not commit it to a public repository** (add it to `.gitignore`).

## 2. Gradle (Kotlin DSL, current Flutter template)

`android/settings.gradle.kts`, inside the `plugins { ... }` block:

```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

`android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")   // add this line
}

android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true   // needed by flutter_local_notifications
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

If your project still uses Groovy (`build.gradle`), the same lines apply in Groovy syntax.
If Gradle rejects a plugin or library version, check the current numbers in the
[FCM Flutter client guide](https://firebase.google.com/docs/cloud-messaging/flutter/client)
and the [flutter_local_notifications README](https://pub.dev/packages/flutter_local_notifications).
If the build complains about `minSdk`, set `minSdk = 23`.

## 3. AndroidManifest (Android 13+)

`android/app/src/main/AndroidManifest.xml`, above `<application>`:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## 4. Test device

Use a physical phone, or an emulator image **with Google Play** (Play Store icon).
An emulator without Play Services returns a `null` token.

## 5. Send the first test (Firebase Console)

1. Firebase Console -> Messaging -> create a campaign -> *Firebase Notification messages*.
2. Title: `Schedule changed`, body: `Mobile class moved to Room A2 at 1:00 PM`.
3. Target: your Android app (or Topic `campus-announcement`).
4. **Additional options -> Custom data:** key `route`, value `/announcement/3`
   (and optionally `id` = `3`). Without `data.route` the tap opens `/` instead of the announcement.
5. Send while the app is in the background, tap the banner, and screenshot the result
   as `screenshots/fcm-console-test.png`.

## 6. Send from a backend (FCM HTTP v1)

Sample bodies: `docs/payload-topic.json` and `docs/payload-device.json`.

```bash
curl -X POST "https://fcm.googleapis.com/v1/projects/<PROJECT_ID>/messages:send" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d @docs/payload-topic.json
```

Rules: always send **notification + data** together. Use a **topic** for broadcasts
(everyone in a class) and a **device token** for personal messages (grades, bills).

## 7. Backend contract used by the app

| Method | Path | Body | Purpose |
| --- | --- | --- | --- |
| POST | `/devices` | `{"fcm_token": "...", "platform": "android"}` | Store/refresh the device token per user (sent on first token and on every `onTokenRefresh`) |
| GET | `/announcements` | - | List announcements |
| GET | `/announcements/:id` | - | One announcement (deep link target) |

Switch from the mock to a real API with
`flutter run --dart-define=USE_MOCK_BACKEND=false --dart-define=API_BASE_URL=https://your-api`.
