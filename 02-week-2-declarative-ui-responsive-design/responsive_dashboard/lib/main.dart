import 'package:flutter/material.dart';

// 1. Move the breakpoint into a single named constant
const double kWideBreakpoint = 700;

void main() => runApp(const AcademicOverviewApp());

class AcademicOverviewApp extends StatefulWidget {
  const AcademicOverviewApp({super.key});

  @override
  State<AcademicOverviewApp> createState() => _AcademicOverviewAppState();
}

class _AcademicOverviewAppState extends State<AcademicOverviewApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: AcademicDashboard(
        isDark: isDark,
        onThemeToggled: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class AcademicDashboard extends StatelessWidget {
  const AcademicDashboard({
    required this.isDark,
    required this.onThemeToggled,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onThemeToggled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Added missing const here
        title: Semantics(
          header: true,
          child: Text('Academic Overview'),
        ),
        actions: [
          Semantics(
            label: 'Toggle dark mode',
            toggled: isDark,
            child: Row(
              children: [
                Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: isDark,
                  onChanged: onThemeToggled,
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const ProfileHeader(),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
          
              final int columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3.0,
                children: const [
                  InfoCard(title: 'Cumulative GPA', value: '3.75'),
                  InfoCard(title: 'LMS', value: '10 Assignments due'),
                  InfoCard(title: 'Class', value: 'Mobile Programming'),
                  InfoCard(title: 'Attendance', value: 'Alpha 4 hours'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
  
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: 'Student Profile: Andhika Daffa Athaaillah, Informatics Engineering, TI-3I',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.primaryContainer,
        child: Row(
          children: [
            Icon(
              Icons.account_circle, 
              size: 60,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
      
                children: [
                  Text(
                    'Andhika Daffa Athaaillah',

                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Informatics Engineering - TI-3I',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    super.key,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '$title is $value',
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}