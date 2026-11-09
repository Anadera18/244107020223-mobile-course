import 'package:flutter/material.dart';

void main() => runApp(const PerformanceLabApp());

class PerformanceLabApp extends StatelessWidget {
  const PerformanceLabApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Performance Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
          useMaterial3: true,
        ),
        home: const PerformanceLabPage(),
      );
}

class PerformanceLabPage extends StatefulWidget {
  const PerformanceLabPage({super.key});

  @override
  State<PerformanceLabPage> createState() => _PerformanceLabPageState();
}

class _PerformanceLabPageState extends State<PerformanceLabPage> {
  static const _items = <StudyItem>[
    StudyItem(
        'Flutter layout basics', 'UI & Flutter', Icons.dashboard_rounded, 18),
    StudyItem('Dart async patterns', 'Dart', Icons.bolt_rounded, 24),
    StudyItem('REST API practice', 'Networking', Icons.cloud_outlined, 32),
    StudyItem(
        'Clean architecture notes', 'Architecture', Icons.layers_outlined, 16),
    StudyItem('Widget testing guide', 'Quality', Icons.fact_check_outlined, 12),
    StudyItem(
        'State management review', 'Flutter', Icons.swap_horiz_rounded, 27),
  ];

  bool _optimized = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Lab'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                _optimized ? 'OPTIMIZED' : 'BASELINE',
                key: const Key('modeLabel'),
                style: TextStyle(
                  color: _optimized
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ModePanel(
            optimized: _optimized,
            onChanged: (value) => setState(() => _optimized = value),
          ),
          Expanded(
            child: _optimized
                ? _OptimizedStudyList(items: _items)
                : _BaselineStudyList(items: _items),
          ),
        ],
      ),
    );
  }
}

class _ModePanel extends StatelessWidget {
  const _ModePanel({required this.optimized, required this.onChanged});

  final bool optimized;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus Study Library',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Compare a naive list with a viewport-built list.'),
            const SizedBox(height: 10),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Baseline')),
                ButtonSegment(value: true, label: Text('Optimized')),
              ],
              selected: {optimized},
              onSelectionChanged: (selection) => onChanged(selection.first),
            ),
            const SizedBox(height: 6),
            Text(
              optimized
                  ? 'Lazy builder • const rows • isolated row state'
                  : 'Eager children • recreated row widgets • broad rebuild',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      );
}

class StudyItem {
  const StudyItem(this.title, this.category, this.icon, this.minutes);

  final String title;
  final String category;
  final IconData icon;
  final int minutes;
}

class _BaselineStudyList extends StatelessWidget {
  const _BaselineStudyList({required this.items});

  final List<StudyItem> items;

  @override
  Widget build(BuildContext context) => ListView(
        key: const Key('baselineList'),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: List.generate(
          120,
          (index) => _BaselineStudyCard(
              item: items[index % items.length], index: index),
        ),
      );
}

class _BaselineStudyCard extends StatelessWidget {
  const _BaselineStudyCard({required this.item, required this.index});

  final StudyItem item;
  final int index;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(child: Icon(item.icon)),
          title: Text('${item.title} ${index + 1}'),
          subtitle: Text('${item.category} • ${item.minutes} min'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class _OptimizedStudyList extends StatelessWidget {
  const _OptimizedStudyList({required this.items});

  final List<StudyItem> items;

  @override
  Widget build(BuildContext context) => ListView.builder(
        key: const Key('optimizedList'),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: 120,
        itemBuilder: (context, index) => RepaintBoundary(
          key: ValueKey('row-$index'),
          child: _OptimizedStudyCard(
            item: items[index % items.length],
            index: index,
          ),
        ),
      );
}

class _OptimizedStudyCard extends StatelessWidget {
  const _OptimizedStudyCard({required this.item, required this.index});

  final StudyItem item;
  final int index;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(child: Icon(item.icon)),
          title: Text('${item.title} ${index + 1}'),
          subtitle: Text('${item.category} • ${item.minutes} min'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}
