import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/api_errors.dart';
import '../providers/announcement_provider.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Announcements'),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'Debug',
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => context.push(AppRoutes.debug),
            ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            await ref.refresh(announcementsProvider.future);
          } catch (_) {
            // The error state is rendered by the list below.
          }
        },
        child: announcements.when(
          loading: () => ListView(
            children: const [
              SizedBox(height: 160),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, stack) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(friendlyApiError(error), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Center(
                child: FilledButton(
                  onPressed: () => ref.invalidate(announcementsProvider),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(child: Text('No announcements yet.')),
                ],
              );
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final a = items[index];
                return ListTile(
                  leading: const Icon(Icons.campaign_outlined),
                  title: Text(a.title),
                  subtitle: Text(
                    a.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(a.date),
                  onTap: () => context.push(AppRoutes.announcement(a.id)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
