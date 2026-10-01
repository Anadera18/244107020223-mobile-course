import 'package:flutter/material.dart';
import '../data/local/note.dart';

/// Dialog tambah/ubah catatan. Mengembalikan null bila dibatalkan.
Future<({String title, String body})?> showNoteDialog(
  BuildContext context, {
  Note? initial,
}) {
  return showDialog<({String title, String body})>(
    context: context,
    builder: (_) => _NoteDialog(initial: initial),
  );
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({this.initial});
  final Note? initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _body = TextEditingController(text: widget.initial?.body);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Catatan baru' : 'Ubah catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Judul'),
          ),
          TextField(
            controller: _body,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Isi'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final title = _title.text.trim();
            if (title.isEmpty) return;
            Navigator.pop(context, (title: title, body: _body.text.trim()));
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
