import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

/// LAB 1 - Pengaturan: tema gelap/terang + waktu terakhir dibuka.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final lastOpened = ref.watch(previousOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          dark.when(
            loading: () => const ListTile(title: Text('Memuat tema...')),
            error: (e, _) => ListTile(title: Text('Gagal memuat: $e')),
            data: (value) => SwitchListTile(
              title: const Text('Mode gelap'),
              subtitle: const Text('Tersimpan di SharedPreferences'),
              value: value,
              onChanged: (_) =>
                  ref.read(darkModeProvider.notifier).toggle(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Terakhir dibuka'),
            subtitle: Text(lastOpened ?? 'Pertama kali dibuka'),
          ),
        ],
      ),
    );
  }
}
