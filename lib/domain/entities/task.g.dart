// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskImpl _$$TaskImplFromJson(Map<String, dynamic> json) => _$TaskImpl(
      id: (json['id'] as num).toInt(),
      listId: (json['listId'] as num).toInt(),
      title: json['title'] as String,
      note: json['note'] as String?,
      priority: $enumDecodeNullable(_$PriorityEnumMap, json['priority']) ??
          Priority.none,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      dueTime: json['dueTime'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      parentId: (json['parentId'] as num?)?.toInt(),
      recurringRuleId: (json['recurringRuleId'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      subtasks: (json['subtasks'] as List<dynamic>?)
              ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      tagNames: (json['tagNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recurringRule: json['recurringRule'] == null
          ? null
          : RecurringRule.fromJson(
              json['recurringRule'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TaskImplToJson(_$TaskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listId': instance.listId,
      'title': instance.title,
      'note': instance.note,
      'priority': _$PriorityEnumMap[instance.priority]!,
      'dueDate': instance.dueDate?.toIso8601String(),
      'dueTime': instance.dueTime,
      'isCompleted': instance.isCompleted,
      'completedAt': instance.completedAt?.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'parentId': instance.parentId,
      'recurringRuleId': instance.recurringRuleId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'subtasks': instance.subtasks,
      'tagNames': instance.tagNames,
      'recurringRule': instance.recurringRule,
    };

const _$PriorityEnumMap = {
  Priority.none: 'none',
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
};
