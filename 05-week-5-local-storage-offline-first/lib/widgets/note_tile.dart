import 'package:flutter/material.dart';
import '../data/local/note.dart';

/// Refactoring: baris catatan yang reusable + badge "belum tersinkron".
class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
  });

  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.body.isNotEmpty)
            Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (note.dirty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Chip(
                avatar: Icon(Icons.cloud_off, size: 16),
                label: Text('Belum tersinkron'),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Hapus',
        onPressed: onDelete,
      ),
    );
  }
}
