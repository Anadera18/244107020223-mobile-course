/// App-wide configuration. No secrets live here: the base URL is not a secret
/// and can be overridden at build time:
///   flutter run --dart-define=API_BASE_URL=https://api.campus.example
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://example-campus-api.test',
);

/// When true the app talks to [MockApiAdapter] instead of a real backend, so
/// the whole auth + refresh flow can be demonstrated without a server.
/// Set to false (or pass --dart-define=USE_MOCK_BACKEND=false) to use a real API.
const bool kUseMockBackend = bool.fromEnvironment(
  'USE_MOCK_BACKEND',
  defaultValue: true,
);

/// FCM topic used for campus-wide broadcasts.
const String kAnnouncementTopic = 'campus-announcement';
