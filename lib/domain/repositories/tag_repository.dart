import '../entities/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getAllTags();
  Future<Tag> getOrCreateTag(String name, String color);
  Future<void> setTaskTags(int taskId, List<int> tagIds);
  Future<List<Tag>> getTagsForTask(int taskId);
}
