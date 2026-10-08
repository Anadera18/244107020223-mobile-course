/// Single source of truth for route strings. GoRouter and FCM deep links
/// (`data.route`) both use these constants.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/';
  static const String debug = '/debug';

  static const String announcementBase = '/announcement';
  static const String announcementPattern = '/announcement/:id';

  static String announcement(String id) => '$announcementBase/$id';
}
