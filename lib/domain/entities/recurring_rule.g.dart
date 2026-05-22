// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringRuleImpl _$$RecurringRuleImplFromJson(Map<String, dynamic> json) =>
    _$RecurringRuleImpl(
      id: (json['id'] as num).toInt(),
      type: $enumDecode(_$RecurringTypeEnumMap, json['type']),
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      daysOfWeek: json['daysOfWeek'] as String?,
      dayOfMonth: (json['dayOfMonth'] as num?)?.toInt(),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      maxCount: (json['maxCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RecurringRuleImplToJson(_$RecurringRuleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$RecurringTypeEnumMap[instance.type]!,
      'interval': instance.interval,
      'daysOfWeek': instance.daysOfWeek,
      'dayOfMonth': instance.dayOfMonth,
      'endDate': instance.endDate?.toIso8601String(),
      'maxCount': instance.maxCount,
    };

const _$RecurringTypeEnumMap = {
  RecurringType.daily: 'daily',
  RecurringType.weekly: 'weekly',
  RecurringType.monthly: 'monthly',
  RecurringType.yearly: 'yearly',
};
