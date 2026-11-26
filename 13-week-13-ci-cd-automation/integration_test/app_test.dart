import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:week13_ci_cd_automation/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a user opens the task feature and adds a task', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // End-to-end flow across several app components: home -> task page ->
    // repository load -> validation -> add -> list update.
    await tester.tap(find.byKey(const Key('open-task-feature')));
    await tester.pumpAndSettle();

    expect(find.text('Task list'), findsOneWidget);

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
  });
}
