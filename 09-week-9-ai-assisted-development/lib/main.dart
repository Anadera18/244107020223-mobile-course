import 'package:flutter/material.dart';

import 'features/notes/domain/filter_notes.dart';
import 'features/notes/domain/note.dart';
import 'features/notes/presentation/notes_page.dart';

void main() {
  runApp(const WeekNineApp());
}

class WeekNineApp extends StatelessWidget {
  const WeekNineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
        useMaterial3: true,
      ),
      home: const NotesPage(
        notes: [
          Note(title: 'Grocery list', body: 'Milk, bread, and coffee'),
          Note(title: 'Flutter study plan', body: 'Review widgets and tests'),
          Note(title: 'Weekend ideas', body: 'Visit the city park'),
        ],
        filterNotes: filterNotes,
      ),
    );
  }
}
