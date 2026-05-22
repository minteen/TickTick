import 'package:freezed_annotation/freezed_annotation.dart';

import 'recurring_rule.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required int id,
    required int listId,
    required String title,
    String? note,
    @Default(0) int priority,
    DateTime? dueDate,
    String? dueTime,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    @Default(0) int sortOrder,
    int? parentId,
    int? recurringRuleId,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Navigation properties (populated when needed)
    @Default([]) List<Task> subtasks,
    @Default([]) List<String> tagNames,
    RecurringRule? recurringRule,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}
