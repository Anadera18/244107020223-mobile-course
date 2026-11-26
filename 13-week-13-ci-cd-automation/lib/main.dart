import 'package:flutter/material.dart';

import 'performance_lab_page.dart';
import 'task_page.dart';
import 'task_repository.dart';

void main() => runApp(const CiCdLabApp());

/// Week 13 CI/CD automation lab.
///
/// The same feature covered by the Week 12 test suite: a task feature
/// (validation, repository, loading/empty/error states) plus the performance
/// lab carried over from Week 11. Week 13 wires this project into a GitHub
/// Actions pipeline that formats, analyzes, tests, and builds it on every
/// push and pull request.
class CiCdLabApp extends StatelessWidget {
  const CiCdLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 13 CI/CD Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
        useMaterial3: true,
      ),
      home: const CiCdLabHomePage(),
    );
  }
}

class CiCdLabHomePage extends StatelessWidget {
  const CiCdLabHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Week 13 CI/CD Lab'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _FeatureHeader(
            title: 'CI/CD & Automation',
            subtitle:
                'The Week 12 test suite, now checked automatically in CI.',
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
