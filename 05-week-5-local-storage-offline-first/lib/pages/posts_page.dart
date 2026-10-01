import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/network_errors.dart';
import '../data/providers.dart';

/// LAB 3 - Cache-first read: posts tampil dari cache tanpa internet.
class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (cache-first)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(postsProvider),
          ),
        ],
      ),
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyError(e)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(postsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Tidak ada data.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(
                  leading: CircleAvatar(child: Text('${items[i].id}')),
                  title: Text(items[i].title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(items[i].body,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
      ),
    );
  }
}
