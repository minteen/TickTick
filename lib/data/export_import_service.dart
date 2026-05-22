import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/entities/task.dart';
import '../domain/entities/task_list.dart';
import '../domain/entities/tag.dart';
import '../domain/enums/priority.dart';
import 'repositories/task_repository_impl.dart';
import 'repositories/list_repository_impl.dart';
import 'repositories/tag_repository_impl.dart';
import 'database/database.dart' as db;

class ExportImportService {
  final db.AppDatabase _db;
  ExportImportService(this._db);

  TaskRepositoryImpl get _taskRepo => TaskRepositoryImpl(_db);
  ListRepositoryImpl get _listRepo => ListRepositoryImpl(_db);
  TagRepositoryImpl get _tagRepo => TagRepositoryImpl(_db);

  Future<String> exportToJson() async {
    final lists = await _listRepo.getAllLists();
    final allTasks = await _taskRepo.getAllTasks();
    final allTags = await _tagRepo.getAllTags();

    final List<Map<String, dynamic>> listsJson = [];
    for (final list in lists) {
      final listTasks = allTasks.where((t) => t.listId == list.id && t.parentId == null).toList();
      listsJson.add({
        'id': list.id,
        'name': list.name,
        'color': list.color,
        'icon': list.icon,
        'tasks': listTasks.map((t) => _taskToJson(t, allTasks, allTags)).toList(),
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'version': '1.0',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'lists': listsJson,
    });
  }

  Map<String, dynamic> _taskToJson(Task task, List<Task> allTasks, List<Tag> allTags) {
    final subtasks = allTasks.where((t) => t.parentId == task.id).toList();
    return {
      'id': task.id,
      'title': task.title,
      'note': task.note,
      'priority': task.priority.value,
      'dueDate': task.dueDate?.toIso8601String(),
      'dueTime': task.dueTime,
      'isCompleted': task.isCompleted,
      'completedAt': task.completedAt?.toIso8601String(),
      'subtasks': subtasks.map((s) => _taskToJson(s, allTasks, allTags)).toList(),
      'recurring': task.recurringRule != null ? {
        'type': task.recurringRule!.type.value,
        'interval': task.recurringRule!.interval,
        'daysOfWeek': task.recurringRule!.daysOfWeek,
        'dayOfMonth': task.recurringRule!.dayOfMonth,
        'endDate': task.recurringRule!.endDate?.toIso8601String(),
        'maxCount': task.recurringRule!.maxCount,
      } : null,
      'tags': allTags.where((tag) => task.tagNames.contains(tag.name)).map((t) => t.name).toList(),
    };
  }

  Future<void> shareExport() async {
    final json = await exportToJson();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/ticktick_backup.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)], text: 'TickTick Backup');
  }

  Future<int> importFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    if (data['version'] != '1.0') throw Exception('Unsupported backup version');

    int imported = 0;
    final lists = data['lists'] as List<dynamic>;

    for (final listJson in lists) {
      final list = TaskList(
        id: 0,
        name: listJson['name'],
        color: listJson['color'],
        icon: listJson['icon'],
        sortOrder: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final createdList = await _listRepo.createList(list);
      final tasks = listJson['tasks'] as List<dynamic>? ?? [];
      imported += await _importTasks(tasks, createdList.id, null);
    }
    return imported;
  }

  Future<int> _importTasks(List<dynamic> taskJsons, int listId, int? parentId) async {
    int count = 0;
    for (final tJson in taskJsons) {
      int? recurringRuleId;
      if (tJson['recurring'] != null) {
        final r = tJson['recurring'] as Map<String, dynamic>;
        final id = await (_db.into(_db.recurringRules).insert(db.RecurringRulesCompanion(
          type: drift.Value(r['type']?.toString() ?? 'daily'),
          interval: drift.Value(r['interval'] ?? 1),
          daysOfWeek: drift.Value(r['daysOfWeek']?.toString()),
          dayOfMonth: drift.Value(r['dayOfMonth']),
          endDate: drift.Value(r['endDate'] != null ? DateTime.parse(r['endDate']) : null),
          maxCount: drift.Value(r['maxCount']),
        )));
        recurringRuleId = id;
      }

      final priorityValue = tJson['priority'] ?? 0;
      final task = Task(
        id: 0,
        listId: listId,
        title: tJson['title'],
        note: tJson['note'],
        priority: Priority.fromValue(priorityValue is int ? priorityValue : 0),
        dueDate: tJson['dueDate'] != null ? DateTime.parse(tJson['dueDate']) : null,
        dueTime: tJson['dueTime'],
        isCompleted: tJson['isCompleted'] ?? false,
        completedAt: tJson['completedAt'] != null ? DateTime.parse(tJson['completedAt']) : null,
        parentId: parentId,
        recurringRuleId: recurringRuleId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final created = await _taskRepo.createTask(task);
      count++;

      final tagNames = (tJson['tags'] as List<dynamic>?)?.cast<String>() ?? [];
      final tagIds = <int>[];
      for (final name in tagNames) {
        final tag = await _tagRepo.getOrCreateTag(name, '#808080');
        tagIds.add(tag.id);
      }
      if (tagIds.isNotEmpty) {
        await _tagRepo.setTaskTags(created.id, tagIds);
      }

      final subtasks = tJson['subtasks'] as List<dynamic>? ?? [];
      count += await _importTasks(subtasks, listId, created.id);
    }
    return count;
  }

  Future<int> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return 0;
    final file = File(result.files.first.path!);
    final jsonString = await file.readAsString();
    return importFromJson(jsonString);
  }
}
