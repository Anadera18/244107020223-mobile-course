import 'package:flutter_test/flutter_test.dart';
import 'package:week12_testing_quality_assurance/is_valid_task_title.dart';

void main() {
  group('isValidTaskTitle', () {
    test('accepts a title with text', () {
      // Arrange
      const input = 'Learn Flutter';

      // Act
      final result = isValidTaskTitle(input);

      // Assert
      expect(result, isTrue);
    });

    test('rejects empty or whitespace-only text', () {
      expect(isValidTaskTitle(''), isFalse);
      expect(isValidTaskTitle('   '), isFalse);
      expect(isValidTaskTitle('\n\t '), isFalse);
    });

    test('accepts text surrounded by whitespace', () {
      expect(isValidTaskTitle('  Read the material  '), isTrue);
    });

    test('treats a single visible character as valid (boundary)', () {
      expect(isValidTaskTitle('a'), isTrue);
    });

    test('rejects an empty string (boundary)', () {
      expect(isValidTaskTitle(''), isFalse);
    });
  });
}
