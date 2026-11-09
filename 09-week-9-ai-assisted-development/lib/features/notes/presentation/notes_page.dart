import 'package:flutter/material.dart';

import '../domain/note.dart';

typedef NoteFilter = List<Note> Function(List<Note> notes, String query);

class NotesPage extends StatefulWidget {
  const NotesPage({required this.notes, required this.filterNotes, super.key});

  final List<Note> notes;
  final NoteFilter filterNotes;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visibleNotes = widget.filterNotes(widget.notes, _query);

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('notes-search-field'),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search note titles',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _query.trim().isEmpty ? 'All notes' : 'Search results',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: visibleNotes.isEmpty
                  ? _EmptyState(hasNotes: widget.notes.isNotEmpty)
                  : ListView.separated(
                      itemCount: visibleNotes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) => _NoteCard(
                        note: visibleNotes[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.notes)),
        title: Text(note.title),
        subtitle: Text(note.body),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasNotes});

  final bool hasNotes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasNotes ? Icons.search_off : Icons.note_add_outlined,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            hasNotes ? 'No notes match your search' : 'No notes yet',
            key: const Key('notes-empty-state'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            hasNotes
                ? 'Try a different title or clear the search.'
                : 'Your notes will appear here.',
          ),
        ],
      ),
    );
  }
}
