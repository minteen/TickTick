import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/tag.dart';
import 'database_provider.dart';

final allTagsProvider = FutureProvider<List<Tag>>((ref) {
  return ref.read(tagRepositoryProvider).getAllTags();
});

final taskTagsProvider = FutureProvider.family<List<Tag>, int>((ref, taskId) {
  return ref.read(tagRepositoryProvider).getTagsForTask(taskId);
});
