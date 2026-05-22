import 'package:drift/drift.dart';
import '../tables.dart';

part 'list_dao.g.dart';

@DriftAccessor(tables: [TaskLists])
class ListDao extends DatabaseAccessor<AppDatabase> with _$ListDaoMixin {
  ListDao(super.db);

  Future<List<TaskList>> getAllLists() {
    return (select(taskLists)..orderBy([(t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc)])).get();
  }

  Future<TaskList?> getList(int id) {
    return (select(taskLists)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertList(Insertable<TaskList> list) {
    return into(taskLists).insert(list);
  }

  Future<bool> updateList(Insertable<TaskList> list) {
    return update(taskLists).replace(list);
  }

  Future<int> deleteList(int id) {
    return (delete(taskLists)..where((t) => t.id.equals(id))).go();
  }
}
