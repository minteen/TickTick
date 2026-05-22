import 'package:drift/drift.dart';
import '../tables.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags, TaskTags])
class TagDao extends DatabaseAccessor<AppDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Future<List<Tag>> getAllTags() => select(tags).get();

  Future<Tag?> getTagByName(String name) {
    return (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();
  }

  Future<int> insertTag(Insertable<Tag> tag) => into(tags).insert(tag);

  Future<void> setTaskTags(int taskId, List<int> tagIds) {
    return transaction(() async {
      await (delete(taskTags)..where((t) => t.taskId.equals(taskId))).go();
      for (final tagId in tagIds) {
        await into(taskTags).insert(TaskTagsCompanion(taskId: Value(taskId), tagId: Value(tagId)));
      }
    });
  }
}
