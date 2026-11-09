import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week11_performance_optimization/main.dart';

void main() {
  testWidgets('optimized mode uses lazy ListView.builder', (tester) async {
    await tester.pumpWidget(const PerformanceLabApp());

    expect(find.byKey(const Key('optimizedList')), findsOneWidget);
    expect(find.byKey(const Key('baselineList')), findsNothing);
    expect(find.text('OPTIMIZED'), findsOneWidget);
    expect(find.text('Flutter layout basics 1'), findsOneWidget);
  });

  testWidgets('switching to baseline shows the eager list for comparison',
      (tester) async {
    await tester.pumpWidget(const PerformanceLabApp());
    await tester.tap(find.text('Baseline').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('baselineList')), findsOneWidget);
    expect(find.byKey(const Key('optimizedList')), findsNothing);
    expect(find.text('BASELINE'), findsOneWidget);
    expect(find.textContaining('Eager children'), findsOneWidget);
  });

  testWidgets('optimized list lazily builds only nearby rows', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const PerformanceLabApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter layout basics 1'), findsOneWidget);
    expect(find.text('Flutter layout basics 120'), findsNothing);
    expect(find.textContaining('120'), findsNothing);
  });
}
