import 'package:flutter/material.dart';
import 'notes_page.dart';
import 'posts_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [NotesPage(), PostsPage(), SettingsPage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note), label: 'Catatan'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'Posts'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Setelan'),
        ],
      ),
    );
  }
}
