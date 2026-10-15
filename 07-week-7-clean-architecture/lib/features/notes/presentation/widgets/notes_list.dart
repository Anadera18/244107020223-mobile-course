import 'package:flutter/material.dart';
import '../../../../core/format.dart';
import '../../domain/entities/note.dart';

class NotesList extends StatelessWidget {
  const NotesList(this.notes, {super.key});
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final n = notes[i];
        return ListTile(
          title: Text(n.title),
          subtitle: Text(n.body.isEmpty ? '-' : n.body,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: Text(formatDate(n.updatedAt)),
        );
      },
    );
  }
}
