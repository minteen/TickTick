import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_list.freezed.dart';
part 'task_list.g.dart';

@freezed
class TaskList with _$TaskList {
  const factory TaskList({
    required int id,
    required String name,
    required String color,
    String? icon,
    @Default(0) int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskList;

  factory TaskList.fromJson(Map<String, dynamic> json) => _$TaskListFromJson(json);
}
