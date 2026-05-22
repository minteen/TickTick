// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_rule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecurringRule _$RecurringRuleFromJson(Map<String, dynamic> json) {
  return _RecurringRule.fromJson(json);
}

/// @nodoc
mixin _$RecurringRule {
  int get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get interval => throw _privateConstructorUsedError;
  String? get daysOfWeek => throw _privateConstructorUsedError;
  int? get dayOfMonth => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int? get maxCount => throw _privateConstructorUsedError;

  /// Serializes this RecurringRule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurringRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurringRuleCopyWith<RecurringRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringRuleCopyWith<$Res> {
  factory $RecurringRuleCopyWith(
          RecurringRule value, $Res Function(RecurringRule) then) =
      _$RecurringRuleCopyWithImpl<$Res, RecurringRule>;
  @useResult
  $Res call(
      {int id,
      String type,
      int interval,
      String? daysOfWeek,
      int? dayOfMonth,
      DateTime? endDate,
      int? maxCount});
}

/// @nodoc
class _$RecurringRuleCopyWithImpl<$Res, $Val extends RecurringRule>
    implements $RecurringRuleCopyWith<$Res> {
  _$RecurringRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurringRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? interval = null,
    Object? daysOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? endDate = freezed,
    Object? maxCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      daysOfWeek: freezed == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as String?,
      dayOfMonth: freezed == dayOfMonth
          ? _value.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxCount: freezed == maxCount
          ? _value.maxCount
          : maxCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecurringRuleImplCopyWith<$Res>
    implements $RecurringRuleCopyWith<$Res> {
  factory _$$RecurringRuleImplCopyWith(
          _$RecurringRuleImpl value, $Res Function(_$RecurringRuleImpl) then) =
      __$$RecurringRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String type,
      int interval,
      String? daysOfWeek,
      int? dayOfMonth,
      DateTime? endDate,
      int? maxCount});
}

/// @nodoc
class __$$RecurringRuleImplCopyWithImpl<$Res>
    extends _$RecurringRuleCopyWithImpl<$Res, _$RecurringRuleImpl>
    implements _$$RecurringRuleImplCopyWith<$Res> {
  __$$RecurringRuleImplCopyWithImpl(
      _$RecurringRuleImpl _value, $Res Function(_$RecurringRuleImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecurringRule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? interval = null,
    Object? daysOfWeek = freezed,
    Object? dayOfMonth = freezed,
    Object? endDate = freezed,
    Object? maxCount = freezed,
  }) {
    return _then(_$RecurringRuleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      interval: null == interval
          ? _value.interval
          : interval // ignore: cast_nullable_to_non_nullable
              as int,
      daysOfWeek: freezed == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as String?,
      dayOfMonth: freezed == dayOfMonth
          ? _value.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxCount: freezed == maxCount
          ? _value.maxCount
          : maxCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurringRuleImpl implements _RecurringRule {
  const _$RecurringRuleImpl(
      {required this.id,
      required this.type,
      this.interval = 1,
      this.daysOfWeek,
      this.dayOfMonth,
      this.endDate,
      this.maxCount});

  factory _$RecurringRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringRuleImplFromJson(json);

  @override
  final int id;
  @override
  final String type;
  @override
  @JsonKey()
  final int interval;
  @override
  final String? daysOfWeek;
  @override
  final int? dayOfMonth;
  @override
  final DateTime? endDate;
  @override
  final int? maxCount;

  @override
  String toString() {
    return 'RecurringRule(id: $id, type: $type, interval: $interval, daysOfWeek: $daysOfWeek, dayOfMonth: $dayOfMonth, endDate: $endDate, maxCount: $maxCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringRuleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.daysOfWeek, daysOfWeek) ||
                other.daysOfWeek == daysOfWeek) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.maxCount, maxCount) ||
                other.maxCount == maxCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type, interval, daysOfWeek,
      dayOfMonth, endDate, maxCount);

  /// Create a copy of RecurringRule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringRuleImplCopyWith<_$RecurringRuleImpl> get copyWith =>
      __$$RecurringRuleImplCopyWithImpl<_$RecurringRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringRuleImplToJson(
      this,
    );
  }
}

abstract class _RecurringRule implements RecurringRule {
  const factory _RecurringRule(
      {required final int id,
      required final String type,
      final int interval,
      final String? daysOfWeek,
      final int? dayOfMonth,
      final DateTime? endDate,
      final int? maxCount}) = _$RecurringRuleImpl;

  factory _RecurringRule.fromJson(Map<String, dynamic> json) =
      _$RecurringRuleImpl.fromJson;

  @override
  int get id;
  @override
  String get type;
  @override
  int get interval;
  @override
  String? get daysOfWeek;
  @override
  int? get dayOfMonth;
  @override
  DateTime? get endDate;
  @override
  int? get maxCount;

  /// Create a copy of RecurringRule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurringRuleImplCopyWith<_$RecurringRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
