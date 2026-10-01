import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/prefs.dart';
import 'data/providers.dart';
import 'pages/home_page.dart';
import 'pages/note_detail_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(
      path: '/note/:id',
      builder: (_, state) =>
          NoteDetailPage(id: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Baca waktu buka sesi sebelumnya, lalu catat sesi sekarang.
  final prefs = PrefsRepository();
  final previous = await prefs.getLastOpened();
  await prefs.markOpenedNow();

  runApp(ProviderScope(
    overrides: [previousOpenedProvider.overrideWithValue(previous)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      title: 'Offline Notes',
      routerConfig: _router,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}
