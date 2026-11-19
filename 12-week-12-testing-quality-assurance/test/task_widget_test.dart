import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/task_page.dart';
import 'package:week12_testing_quality_assurance/task_repository.dart';

/// Fake repository that returns fixed tasks or throws on demand.
class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.tasks = const [], this.error});

  final List<String> tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    if (error != null) throw error!;
    return tasks;
  }
}

Widget _wrap(TaskRepository repository) {
  return MaterialApp(home: TaskPage(repository: repository));
}

void main() {
  group('TaskPage widget', () {
    testWidgets('shows the page title and empty state on first load',
        (tester) async {
      await tester.pumpWidget(_wrap(FakeTaskRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Task list'), findsOneWidget);
      expect(find.byKey(const Key('task-empty')), findsOneWidget);
      expect(find.text('No tasks yet'), findsOneWidget);
    });

    testWidgets('renders tasks returned by the repository', (tester) async {
      await tester.pumpWidget(
        _wrap(FakeTaskRepository(tasks: ['Read the material', 'Write tests'])),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('task-list')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('task-list')),
          matching: find.text('Read the material'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('task-list')),
          matching: find.text('Write tests'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('task-empty')), findsNothing);
    });

    testWidgets('shows validation feedback for whitespace-only input',
        (tester) async {
      await tester.pumpWidget(_wrap(FakeTaskRepository()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        '   ',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Enter a task title before saving.'), findsOneWidget);
      // Nothing was added, so the empty state is still shown.
      expect(find.byKey(const Key('task-empty')), findsOneWidget);
    });

    testWidgets('adds a task on a successful user action', (tester) async {
      await tester.pumpWidget(_wrap(FakeTaskRepository()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Read the material',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('task-list')),
          matching: find.text('Read the material'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('task-list')), findsOneWidget);
      expect(find.byKey(const Key('task-empty')), findsNothing);
    });

    testWidgets('shows an error state when the repository throws',
        (tester) async {
      await tester.pumpWidget(
        _wrap(FakeTaskRepository(error: Exception('boom'))),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('task-error')), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Could not load tasks. Please try again.'),
          findsOneWidget);
    });
  });
}
