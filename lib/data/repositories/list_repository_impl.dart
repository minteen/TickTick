import 'dart:async';
import 'package:drift/drift.dart' as drift;
import '../../domain/entities/task_list.dart';
import '../../domain/repositories/list_repository.dart';
import '../database/database.dart' as db;

class ListRepositoryImpl implements ListRepository {
  final db.AppDatabase _db;
  ListRepositoryImpl(this._db);

  TaskList _toEntity(db.TaskList l) => TaskList(
        id: l.id,
        name: l.name,
        color: l.color,
        icon: l.icon,
        sortOrder: l.sortOrder,
        createdAt: l.createdAt,
        updatedAt: l.updatedAt,
      );

  db.TaskListsCompanion _toCompanion(TaskList l) => db.TaskListsCompanion(
        id: l.id > 0 ? drift.Value(l.id) : const drift.Value.absent(),
        name: drift.Value(l.name),
        color: drift.Value(l.color),
        icon: drift.Value(l.icon),
        sortOrder: drift.Value(l.sortOrder),
        createdAt: drift.Value(l.createdAt),
        updatedAt: drift.Value(DateTime.now()),
      );

  @override
  Future<List<TaskList>> getAllLists() async {
    final List<db.TaskList> rows = await _db.listDao.getAllLists();
    return rows.map((r) => _toEntity(r)).toList();
  }

  @override
  Future<TaskList?> getList(int id) async {
    final row = await _db.listDao.getList(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<TaskList> createList(TaskList list) async {
    final id = await _db.listDao.insertList(_toCompanion(list));
    final created = await getList(id);
    return created!;
  }

  @override
  Future<TaskList> updateList(TaskList list) async {
    await _db.listDao.updateList(_toCompanion(list));
    final updated = await getList(list.id);
    return updated!;
  }

  @override
  Future<void> deleteList(int id) async {
    await _db.listDao.deleteList(id);
  }

  @override
  Future<void> reorderLists(List<int> listIds) async {
    for (var i = 0; i < listIds.length; i++) {
      await (_db.update(_db.taskLists)..where((t) => t.id.equals(listIds[i]))).write(
        db.TaskListsCompanion(sortOrder: drift.Value(i)),
      );
    }
  }

  @override
  Stream<List<TaskList>> watchAllLists() {
    return (_db.select(_db.taskLists)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.sortOrder, mode: drift.OrderingMode.asc)]))
        .watch()
        .map((List<db.TaskList> rows) => rows.map((r) => _toEntity(r)).toList());
  }
}
