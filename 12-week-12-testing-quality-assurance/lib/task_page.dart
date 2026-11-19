import 'package:flutter/material.dart';

import 'is_valid_task_title.dart';
import 'task_repository.dart';

/// Task list screen used to demonstrate unit, widget, and integration tests.
///
/// The screen owns only presentation and interaction. Data access goes
/// through a [TaskRepository], which makes the widget easy to test with a
/// fake repository.
class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _tasks = <String>[];

  bool _loading = true;
  String? _error;
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loaded = await TaskService(widget.repository).loadTasks();
      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(loaded);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load tasks. Please try again.';
      });
    }
  }

  void _addTask() {
    final value = _controller.text;
    if (!isValidTaskTitle(value)) {
      setState(() => _inputError = 'Enter a task title before saving.');
      return;
    }
    setState(() {
      _inputError = null;
      _tasks.add(value.trim());
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task list'),
        actions: [
          IconButton(
            key: const Key('reload-tasks-button'),
            tooltip: 'Reload',
            onPressed: _loading ? null : _loadTasks,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const Key('task-title-field'),
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addTask(),
                  decoration: InputDecoration(
                    labelText: 'Task title',
                    hintText: 'Read the material',
                    border: const OutlineInputBorder(),
                    errorText: _inputError,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('save-task-button'),
                    onPressed: _addTask,
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('Save task'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        key: Key('task-loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return _TaskMessage(
        key: const Key('task-error'),
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        title: 'Something went wrong',
        message: _error!,
      );
    }
    if (_tasks.isEmpty) {
      return const _TaskMessage(
        key: Key('task-empty'),
        icon: Icons.inbox_outlined,
        color: Colors.grey,
        title: 'No tasks yet',
        message: 'Add your first task using the field above.',
      );
    }
    return ListView.builder(
      key: const Key('task-list'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final title = _tasks[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.check_rounded)),
          title: Text(title),
        );
      },
    );
  }
}

class _TaskMessage extends StatelessWidget {
  const _TaskMessage({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
