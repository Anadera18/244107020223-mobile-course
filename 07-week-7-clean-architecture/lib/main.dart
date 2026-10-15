import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notes (Clean Architecture)',
      theme: ThemeData(
          colorSchemeSeed: const Color(0xFF4F7DC9), useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}
