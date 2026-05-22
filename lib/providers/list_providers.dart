import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/task_list.dart';
import 'database_provider.dart';

final allListsProvider =
    AsyncNotifierProvider<AllListsNotifier, List<TaskList>>(
  AllListsNotifier.new,
);

class AllListsNotifier extends AsyncNotifier<List<TaskList>> {
  @override
  Future<List<TaskList>> build() async {
    final repo = ref.read(listRepositoryProvider);
    return repo.getAllLists();
  }

  Future<TaskList> createList(String name, String color) async {
    final repo = ref.read(listRepositoryProvider);
    final list = TaskList(
      id: 0,
      name: name,
      color: color,
      sortOrder: state.value?.length ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final created = await repo.createList(list);
    ref.invalidateSelf();
    return created;
  }

  Future<void> updateList(TaskList list) async {
    final repo = ref.read(listRepositoryProvider);
    await repo.updateList(list);
    ref.invalidateSelf();
  }

  Future<void> deleteList(int id) async {
    final repo = ref.read(listRepositoryProvider);
    await repo.deleteList(id);
    ref.invalidateSelf();
  }
}
