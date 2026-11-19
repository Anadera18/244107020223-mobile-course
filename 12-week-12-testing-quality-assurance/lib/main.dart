import 'package:flutter/material.dart';

import 'performance_lab_page.dart';
import 'task_page.dart';
import 'task_repository.dart';

void main() => runApp(const TestingLabApp());

/// Week 12 testing lab.
///
/// Two features live here so the test suite can cover more than one path:
/// a task feature (validation, repository, loading/empty/error states) and
/// the performance lab carried over from Week 11.
class TestingLabApp extends StatelessWidget {
  const TestingLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 12 Testing Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
        useMaterial3: true,
      ),
      home: const TestingLabHomePage(),
    );
  }
}

class TestingLabHomePage extends StatelessWidget {
  const TestingLabHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week 12 Testing Lab'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _FeatureHeader(
            title: 'Testing & Quality Assurance',
            subtitle:
                'Unit, widget, and integration tests for the task feature.',
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              key: const Key('open-task-feature'),
              leading: const CircleAvatar(child: Icon(Icons.checklist_rounded)),
              title: const Text('Task feature'),
              subtitle: const Text('Add tasks, validation, fake repository'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      TaskPage(repository: InMemoryTaskRepository()),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('open-performance-lab'),
              leading: const CircleAvatar(child: Icon(Icons.speed_rounded)),
              title: const Text('Performance lab'),
              subtitle: const Text('Carried over from Week 11'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PerformanceLabPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureHeader extends StatelessWidget {
  const _FeatureHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
    );
  }
}
