import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/notes_providers.dart';
import '../widgets/notes_list.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New note'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title')),
          TextField(
              controller: body,
              decoration: const InputDecoration(labelText: 'Body')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;

    final result = await ref
        .read(addNoteProvider)
        .call(title: title.text, body: body.text);
    if (result.failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(result.failure!.message)));
      return;
    }
    ref.invalidate(notesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'Announcements',
            onPressed: () => context.go(Routes.announcements),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(notesProvider),
        ),
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('No notes yet.'))
            : NotesList(notes),
      ),
    );
  }
}
