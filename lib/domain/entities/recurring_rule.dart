import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ticktick/domain/enums/recurring_type.dart';

part 'recurring_rule.freezed.dart';
part 'recurring_rule.g.dart';

@freezed
class RecurringRule with _$RecurringRule {
  const factory RecurringRule({
    required int id,
    required RecurringType type,
    @Default(1) int interval,
    String? daysOfWeek,
    int? dayOfMonth,
    DateTime? endDate,
    int? maxCount,
  }) = _RecurringRule;

  factory RecurringRule.fromJson(Map<String, dynamic> json) => _$RecurringRuleFromJson(json);
}
