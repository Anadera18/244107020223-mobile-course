import 'package:flutter_test/flutter_test.dart';
import 'package:week13_ci_cd_automation/task_repository.dart';

/// A fake repository whose behavior is fully controlled by the test.
///
/// It lets the suite check success, empty, and failure paths without a
/// live API, authentication, or network access.
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

void main() {
  group('TaskService.loadTasks', () {
    test('returns data from the repository', () async {
      final service = TaskService(
        FakeTaskRepository(tasks: ['Read the material']),
      );

      expect(await service.loadTasks(), ['Read the material']);
    });

    test('returns an empty list when there are no tasks', () async {
      final service = TaskService(FakeTaskRepository());

      expect(await service.loadTasks(), isEmpty);
    });

    test('propagates an error instead of hiding it as an empty list', () async {
      final service = TaskService(
        FakeTaskRepository(error: Exception('network down')),
      );

      // The service must not swallow failures. If it returned [] here,
      // the UI could not tell "no tasks" apart from "load failed".
      expect(
        () => service.loadTasks(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('InMemoryTaskRepository', () {
    test('returns a copy that cannot mutate the stored list', () async {
      final repository = InMemoryTaskRepository(['First']);

      final first = await repository.getTasks();
      expect(() => first.add('Injected'), throwsUnsupportedError);

      expect(await repository.getTasks(), ['First']);
    });
  });
}
