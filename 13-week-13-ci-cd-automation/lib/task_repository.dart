/// Data-source contract for the task feature.
///
/// The UI and the [TaskService] depend on this abstraction instead of a
/// concrete data source. A test can provide a small fake implementation
/// and control success, empty, and failure behavior without a network.
abstract interface class TaskRepository {
  Future<List<String>> getTasks();
}

/// Thin service layer that the UI talks to.
///
/// It forwards to the repository and does not hide errors, so a failure
/// stays observable and testable.
class TaskService {
  TaskService(this._repository);

  final TaskRepository _repository;

  Future<List<String>> loadTasks() {
    return _repository.getTasks();
  }
}

/// In-memory repository used by the running app.
///
/// This is the production data source for the lab: it keeps the task list
/// in memory so the app works offline and on every platform, including
/// the web build.
class InMemoryTaskRepository implements TaskRepository {
  InMemoryTaskRepository([List<String>? initial])
      : _tasks = List<String>.of(initial ?? const <String>[]);

  final List<String> _tasks;

  @override
  Future<List<String>> getTasks() async {
    return List<String>.unmodifiable(_tasks);
  }
}
