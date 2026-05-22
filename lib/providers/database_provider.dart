import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import '../data/notification_service.dart';
import '../data/export_import_service.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/repositories/list_repository_impl.dart';
import '../data/repositories/tag_repository_impl.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/list_repository.dart';
import '../domain/repositories/tag_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(databaseProvider));
});

final listRepositoryProvider = Provider<ListRepository>((ref) {
  return ListRepositoryImpl(ref.watch(databaseProvider));
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(ref.watch(databaseProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final exportImportServiceProvider = Provider<ExportImportService>((ref) {
  return ExportImportService(ref.watch(databaseProvider));
});
