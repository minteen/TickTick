import 'package:drift/drift.dart' as drift;
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../database/database.dart' as db;

class TagRepositoryImpl implements TagRepository {
  final db.AppDatabase _db;
  TagRepositoryImpl(this._db);

  @override
  Future<List<Tag>> getAllTags() async {
    final List<db.Tag> rows = await _db.tagDao.getAllTags();
    return rows.map((r) => Tag(id: r.id, name: r.name, color: r.color)).toList();
  }

  @override
  Future<Tag> getOrCreateTag(String name, String color) async {
    final existing = await _db.tagDao.getTagByName(name);
    if (existing != null) return Tag(id: existing.id, name: existing.name, color: existing.color);
    final id = await _db.tagDao.insertTag(db.TagsCompanion(name: drift.Value(name), color: drift.Value(color)));
    return Tag(id: id, name: name, color: color);
  }

  @override
  Future<void> setTaskTags(int taskId, List<int> tagIds) {
    return _db.tagDao.setTaskTags(taskId, tagIds);
  }

  @override
  Future<List<Tag>> getTagsForTask(int taskId) async {
    final query = _db.select(_db.taskTags).join([
      drift.innerJoin(_db.tags, _db.tags.id.equalsExp(_db.taskTags.tagId)),
    ])..where(_db.taskTags.taskId.equals(taskId));
    final rows = await query.get();
    return rows.map((r) {
      final tag = r.readTable(_db.tags);
      return Tag(id: tag.id, name: tag.name, color: tag.color);
    }).toList();
  }
}
