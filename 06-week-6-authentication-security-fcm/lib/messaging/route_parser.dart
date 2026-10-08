import '../routes.dart';

/// Pure function: FCM `data` map -> GoRouter location.
/// No Firebase imports, so it is unit-testable and safe in the background isolate.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = data['route'];
  if (raw is! String || raw.trim().isEmpty) return AppRoutes.home;
  final route = raw.trim();
  return route.startsWith('/') ? route : '/$route';
}
