import 'package:drift/drift.dart';
import '../tables.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks, TaskTags])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<List<Task>> getTasksByList(int listId) {
    return (select(tasks)..where((t) => t.listId.equals(listId) & t.parentId.isNull()))
        .get();
  }

  Future<List<Task>> getSubtasks(int taskId) {
    return (select(tasks)..where((t) => t.parentId.equals(taskId))).get();
  }

  Future<List<Task>> getTodayAndOverdue() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (select(tasks)
      ..where((t) => t.dueDate.isSmallerOrEqualValue(today) & t.isCompleted.equals(false) & t.parentId.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc)]))
        .get();
  }

  Future<List<Task>> searchTasks(String query) {
    final escaped = query.replaceAll('\\', '\\\\').replaceAll('%', '\\%').replaceAll('_', '\\_');
    return (select(tasks)
      ..where((t) => t.title.like('%$escaped%') | t.note.like('%$escaped%'))
      ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();
  }

  Future<int> insertTask(Insertable<Task> task) {
    return into(tasks).insert(task);
  }

  Future<bool> updateTask(Insertable<Task> task) {
    return update(tasks).replace(task);
  }

  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> completeRecurringTask(int taskId, DateTime nextDueDate) {
    return transaction(() async {
      final task = await (select(tasks)..where((t) => t.id.equals(taskId))).getSingle();
      await (update(tasks)..where((t) => t.id.equals(taskId))).write(
        TasksCompanion(isCompleted: const Value(true), completedAt: Value(DateTime.now())),
      );
      await into(tasks).insert(TasksCompanion(
        listId: Value(task.listId),
        title: Value(task.title),
        note: Value(task.note),
        priority: Value(task.priority),
        dueDate: Value(nextDueDate),
        dueTime: Value(task.dueTime),
        recurringRuleId: Value(task.recurringRuleId),
        sortOrder: Value(task.sortOrder),
      ));
    });
  }

  Future<List<TaskWithTags>> getTasksWithTags(int listId) {
    return getTasksByList(listId).then((taskList) async {
      final result = <TaskWithTags>[];
      for (final task in taskList) {
        final tagNames = await getTagNamesForTask(task.id);
        result.add(TaskWithTags(task: task, tagNames: tagNames));
      }
      return result;
    });
  }

  Future<List<String>> getTagNamesForTask(int taskId) {
    final query = select(taskTags).join([
      innerJoin(tags, tags.id.equalsExp(taskTags.tagId)),
    ])..where(taskTags.taskId.equals(taskId));
    return query.map((row) => row.readTable(tags).name).get();
  }
}

class TaskWithTags {
  final Task task;
  final List<String> tagNames;
  TaskWithTags({required this.task, required this.tagNames});
}
