import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/task.dart';
import 'database_provider.dart';

final tasksByListProvider =
    FutureProvider.family<List<Task>, int>((ref, listId) {
  return ref.read(taskRepositoryProvider).getTasksByList(listId);
});

final todayTasksProvider = FutureProvider<List<Task>>((ref) {
  return ref.read(taskRepositoryProvider).getTodayAndOverdue();
});

final subtasksProvider =
    FutureProvider.family<List<Task>, int>((ref, taskId) {
  return ref.read(taskRepositoryProvider).getSubtasks(taskId);
});

final taskDetailProvider =
    FutureProvider.family<Task?, int>((ref, id) {
  return ref.read(taskRepositoryProvider).getTask(id);
});

final searchResultsProvider =
    FutureProvider.family<List<Task>, String>((ref, query) {
  final repo = ref.read(taskRepositoryProvider);
  return query.isEmpty
      ? repo.getTodayAndOverdue()
      : repo.searchTasks(query);
});

final taskActionsProvider = Provider<TaskActions>((ref) => TaskActions(ref));

class TaskActions {
  final Ref _ref;
  TaskActions(this._ref);

  Future<Task> createTask(Task task) async {
    final created =
        await _ref.read(taskRepositoryProvider).createTask(task);
    _ref.invalidate(tasksByListProvider(task.listId));
    _ref.invalidate(todayTasksProvider);
    return created;
  }

  Future<Task> updateTask(Task task) async {
    final updated =
        await _ref.read(taskRepositoryProvider).updateTask(task);
    _ref.invalidate(tasksByListProvider(task.listId));
    _ref.invalidate(todayTasksProvider);
    _ref.invalidate(taskDetailProvider(task.id));
    return updated;
  }

  Future<void> toggleTask(int id, int listId) async {
    await _ref.read(taskRepositoryProvider).toggleTask(id);
    _ref.invalidate(tasksByListProvider(listId));
    _ref.invalidate(todayTasksProvider);
    _ref.invalidate(taskDetailProvider(id));
  }

  Future<void> deleteTask(int id, int listId) async {
    await _ref.read(taskRepositoryProvider).deleteTask(id);
    _ref.invalidate(tasksByListProvider(listId));
    _ref.invalidate(todayTasksProvider);
  }

  Future<void> createSubtask(int parentId, String title) async {
    final parent =
        await _ref.read(taskRepositoryProvider).getTask(parentId);
    if (parent == null) return;
    final subtask = Task(
      id: 0,
      listId: parent.listId,
      title: title,
      sortOrder: 0,
      parentId: parentId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _ref.read(taskRepositoryProvider).createTask(subtask);
    _ref.invalidate(taskDetailProvider(parentId));
  }
}
