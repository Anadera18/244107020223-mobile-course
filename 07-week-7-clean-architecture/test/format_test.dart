import 'package:campus_notes_clean/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatDate', () {
    expect(formatDate(DateTime(2026, 9, 27)), '27 Sep 2026');
  });
  test('parseRouteId', () {
    expect(parseRouteId('42'), 42);
    expect(parseRouteId('abc'), isNull);
    expect(parseRouteId(null), isNull);
  });
}
