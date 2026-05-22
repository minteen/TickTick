import '../entities/task_list.dart';

abstract class ListRepository {
  Future<List<TaskList>> getAllLists();
  Future<TaskList?> getList(int id);
  Future<TaskList> createList(TaskList list);
  Future<TaskList> updateList(TaskList list);
  Future<void> deleteList(int id);
  Future<void> reorderLists(List<int> listIds);
  Stream<List<TaskList>> watchAllLists();
}
