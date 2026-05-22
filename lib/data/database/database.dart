import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'tables.dart';
import 'dao/task_dao.dart';
import 'dao/list_dao.dart';
import 'dao/tag_dao.dart';

part 'database.g.dart';

@DriftDatabase(tables: [TaskLists, Tasks, RecurringRules, Tags, TaskTags], daos: [TaskDao, ListDao, TagDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'ticktick.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
