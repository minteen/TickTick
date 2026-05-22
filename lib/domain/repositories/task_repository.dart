import '../entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasksByList(int listId);
  Future<List<Task>> getSubtasks(int taskId);
  Future<List<Task>> getTodayAndOverdue();
  Future<List<Task>> searchTasks(String query);
  Future<Task?> getTask(int id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<void> toggleTask(int id);
  Future<void> completeRecurringTask(int taskId, DateTime nextDueDate);
  Future<void> reorderTasks(int listId, List<int> taskIds);
  Future<List<Task>> getAllTasks();
  Stream<List<Task>> watchTasksByList(int listId);
  Stream<List<Task>> watchTodayAndOverdue();
}
