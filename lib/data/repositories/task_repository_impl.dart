import 'dart:async';
import 'package:drift/drift.dart' as drift;
import '../../domain/entities/task.dart';
import '../../domain/enums/priority.dart';
import '../../domain/repositories/task_repository.dart';
import '../database/database.dart' as db;

class TaskRepositoryImpl implements TaskRepository {
  final db.AppDatabase _db;
  TaskRepositoryImpl(this._db);

  Task _toEntity(db.Task t) => Task(
        id: t.id,
        listId: t.listId,
        title: t.title,
        note: t.note,
        priority: Priority.fromValue(t.priority),
        dueDate: t.dueDate,
        dueTime: t.dueTime,
        isCompleted: t.isCompleted,
        completedAt: t.completedAt,
        sortOrder: t.sortOrder,
        parentId: t.parentId,
        recurringRuleId: t.recurringRuleId,
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      );

  db.TasksCompanion _toCompanion(Task t) {
    final priorityValue = t.priority.value;
    return db.TasksCompanion(
      id: t.id > 0 ? drift.Value(t.id) : const drift.Value.absent(),
      listId: drift.Value(t.listId),
      title: drift.Value(t.title),
      note: drift.Value(t.note),
      priority: drift.Value(priorityValue),
      dueDate: drift.Value(t.dueDate),
      dueTime: drift.Value(t.dueTime),
      isCompleted: drift.Value(t.isCompleted),
      completedAt: drift.Value(t.completedAt),
      sortOrder: drift.Value(t.sortOrder),
      parentId: drift.Value(t.parentId),
      recurringRuleId: drift.Value(t.recurringRuleId),
      createdAt: drift.Value(t.createdAt),
      updatedAt: drift.Value(DateTime.now()),
    );
  }

  @override
  Future<List<Task>> getTasksByList(int listId) async {
    final List<db.Task> rows = await _db.taskDao.getTasksByList(listId);
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<List<Task>> getSubtasks(int taskId) async {
    final List<db.Task> rows = await _db.taskDao.getSubtasks(taskId);
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<List<Task>> getTodayAndOverdue() async {
    final List<db.Task> rows = await _db.taskDao.getTodayAndOverdue();
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    final List<db.Task> rows = await _db.taskDao.searchTasks(query);
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<Task?> getTask(int id) async {
    final result = await (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
    return result == null ? null : _toEntity(result);
  }

  @override
  Future<Task> createTask(Task task) async {
    final id = await _db.taskDao.insertTask(_toCompanion(task));
    final created = await getTask(id);
    return created!;
  }

  @override
  Future<Task> updateTask(Task task) async {
    await _db.taskDao.updateTask(_toCompanion(task));
    final updated = await getTask(task.id);
    return updated!;
  }

  @override
  Future<void> deleteTask(int id) => _db.taskDao.deleteTask(id);

  @override
  Future<void> toggleTask(int id) async {
    final task = await getTask(id);
    if (task != null) {
      final updated = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: task.isCompleted ? null : DateTime.now(),
      );
      await _db.taskDao.updateTask(_toCompanion(updated));
    }
  }

  @override
  Future<void> completeRecurringTask(int taskId, DateTime nextDueDate) {
    return _db.taskDao.completeRecurringTask(taskId, nextDueDate);
  }

  @override
  Future<void> reorderTasks(int listId, List<int> taskIds) async {
    for (var i = 0; i < taskIds.length; i++) {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(taskIds[i]))).write(
        db.TasksCompanion(sortOrder: drift.Value(i)),
      );
    }
  }

  @override
  Future<List<Task>> getAllTasks() async {
    final List<db.Task> rows = await _db.select(_db.tasks).get();
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Stream<List<Task>> watchTasksByList(int listId) {
    return (_db.select(_db.tasks)
          ..where((t) => t.listId.equals(listId) & t.parentId.isNull())
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder, mode: drift.OrderingMode.asc)]))
        .watch()
        .map((List<db.Task> rows) => rows.map((r) => _toEntity(r)).toList());
  }

  @override
  Stream<List<Task>> watchTodayAndOverdue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (_db.select(_db.tasks)
          ..where((t) => t.dueDate.isSmallerOrEqualValue(today) & t.isCompleted.equals(false) & t.parentId.isNull())
          ..orderBy([(t) => drift.OrderingTerm(expression: t.dueDate, mode: drift.OrderingMode.asc)]))
        .watch()
        .map((List<db.Task> rows) => rows.map((r) => _toEntity(r)).toList());
  }
}
