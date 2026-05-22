// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Task _$TaskFromJson(Map<String, dynamic> json) {
  return _Task.fromJson(json);
}

/// @nodoc
mixin _$Task {
  int get id => throw _privateConstructorUsedError;
  int get listId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  Priority get priority => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  String? get dueTime => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  int? get parentId => throw _privateConstructorUsedError;
  int? get recurringRuleId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Navigation properties (populated when needed)
  List<Task> get subtasks => throw _privateConstructorUsedError;
  List<String> get tagNames => throw _privateConstructorUsedError;
  RecurringRule? get recurringRule => throw _privateConstructorUsedError;

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call(
      {int id,
      int listId,
      String title,
      String? note,
      Priority priority,
      DateTime? dueDate,
      String? dueTime,
      bool isCompleted,
      DateTime? completedAt,
      int sortOrder,
      int? parentId,
      int? recurringRuleId,
      DateTime createdAt,
      DateTime updatedAt,
      List<Task> subtasks,
      List<String> tagNames,
      RecurringRule? recurringRule});

  $RecurringRuleCopyWith<$Res>? get recurringRule;
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listId = null,
    Object? title = null,
    Object? note = freezed,
    Object? priority = null,
    Object? dueDate = freezed,
    Object? dueTime = freezed,
    Object? isCompleted = null,
    Object? completedAt = freezed,
    Object? sortOrder = null,
    Object? parentId = freezed,
    Object? recurringRuleId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? subtasks = null,
    Object? tagNames = null,
    Object? recurringRule = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      listId: null == listId
          ? _value.listId
          : listId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueTime: freezed == dueTime
          ? _value.dueTime
          : dueTime // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      recurringRuleId: freezed == recurringRuleId
          ? _value.recurringRuleId
          : recurringRuleId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subtasks: null == subtasks
          ? _value.subtasks
          : subtasks // ignore: cast_nullable_to_non_nullable
              as List<Task>,
      tagNames: null == tagNames
          ? _value.tagNames
          : tagNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recurringRule: freezed == recurringRule
          ? _value.recurringRule
          : recurringRule // ignore: cast_nullable_to_non_nullable
              as RecurringRule?,
    ) as $Val);
  }

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecurringRuleCopyWith<$Res>? get recurringRule {
    if (_value.recurringRule == null) {
      return null;
    }

    return $RecurringRuleCopyWith<$Res>(_value.recurringRule!, (value) {
      return _then(_value.copyWith(recurringRule: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
          _$TaskImpl value, $Res Function(_$TaskImpl) then) =
      __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int listId,
      String title,
      String? note,
      Priority priority,
      DateTime? dueDate,
      String? dueTime,
      bool isCompleted,
      DateTime? completedAt,
      int sortOrder,
      int? parentId,
      int? recurringRuleId,
      DateTime createdAt,
      DateTime updatedAt,
      List<Task> subtasks,
      List<String> tagNames,
      RecurringRule? recurringRule});

  @override
  $RecurringRuleCopyWith<$Res>? get recurringRule;
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
      : super(_value, _then);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? listId = null,
    Object? title = null,
    Object? note = freezed,
    Object? priority = null,
    Object? dueDate = freezed,
    Object? dueTime = freezed,
    Object? isCompleted = null,
    Object? completedAt = freezed,
    Object? sortOrder = null,
    Object? parentId = freezed,
    Object? recurringRuleId = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? subtasks = null,
    Object? tagNames = null,
    Object? recurringRule = freezed,
  }) {
    return _then(_$TaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      listId: null == listId
          ? _value.listId
          : listId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as Priority,
      dueDate: freezed == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dueTime: freezed == dueTime
          ? _value.dueTime
          : dueTime // ignore: cast_nullable_to_non_nullable
              as String?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as int?,
      recurringRuleId: freezed == recurringRuleId
          ? _value.recurringRuleId
          : recurringRuleId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      subtasks: null == subtasks
          ? _value._subtasks
          : subtasks // ignore: cast_nullable_to_non_nullable
              as List<Task>,
      tagNames: null == tagNames
          ? _value._tagNames
          : tagNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recurringRule: freezed == recurringRule
          ? _value.recurringRule
          : recurringRule // ignore: cast_nullable_to_non_nullable
              as RecurringRule?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaskImpl implements _Task {
  const _$TaskImpl(
      {required this.id,
      required this.listId,
      required this.title,
      this.note,
      this.priority = Priority.none,
      this.dueDate,
      this.dueTime,
      this.isCompleted = false,
      this.completedAt,
      this.sortOrder = 0,
      this.parentId,
      this.recurringRuleId,
      required this.createdAt,
      required this.updatedAt,
      final List<Task> subtasks = const [],
      final List<String> tagNames = const [],
      this.recurringRule})
      : _subtasks = subtasks,
        _tagNames = tagNames;

  factory _$TaskImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaskImplFromJson(json);

  @override
  final int id;
  @override
  final int listId;
  @override
  final String title;
  @override
  final String? note;
  @override
  @JsonKey()
  final Priority priority;
  @override
  final DateTime? dueDate;
  @override
  final String? dueTime;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final int? parentId;
  @override
  final int? recurringRuleId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
// Navigation properties (populated when needed)
  final List<Task> _subtasks;
// Navigation properties (populated when needed)
  @override
  @JsonKey()
  List<Task> get subtasks {
    if (_subtasks is EqualUnmodifiableListView) return _subtasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subtasks);
  }

  final List<String> _tagNames;
  @override
  @JsonKey()
  List<String> get tagNames {
    if (_tagNames is EqualUnmodifiableListView) return _tagNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagNames);
  }

  @override
  final RecurringRule? recurringRule;

  @override
  String toString() {
    return 'Task(id: $id, listId: $listId, title: $title, note: $note, priority: $priority, dueDate: $dueDate, dueTime: $dueTime, isCompleted: $isCompleted, completedAt: $completedAt, sortOrder: $sortOrder, parentId: $parentId, recurringRuleId: $recurringRuleId, createdAt: $createdAt, updatedAt: $updatedAt, subtasks: $subtasks, tagNames: $tagNames, recurringRule: $recurringRule)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.listId, listId) || other.listId == listId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.dueTime, dueTime) || other.dueTime == dueTime) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.recurringRuleId, recurringRuleId) ||
                other.recurringRuleId == recurringRuleId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._subtasks, _subtasks) &&
            const DeepCollectionEquality().equals(other._tagNames, _tagNames) &&
            (identical(other.recurringRule, recurringRule) ||
                other.recurringRule == recurringRule));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      listId,
      title,
      note,
      priority,
      dueDate,
      dueTime,
      isCompleted,
      completedAt,
      sortOrder,
      parentId,
      recurringRuleId,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_subtasks),
      const DeepCollectionEquality().hash(_tagNames),
      recurringRule);

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaskImplToJson(
      this,
    );
  }
}

abstract class _Task implements Task {
  const factory _Task(
      {required final int id,
      required final int listId,
      required final String title,
      final String? note,
      final Priority priority,
      final DateTime? dueDate,
      final String? dueTime,
      final bool isCompleted,
      final DateTime? completedAt,
      final int sortOrder,
      final int? parentId,
      final int? recurringRuleId,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final List<Task> subtasks,
      final List<String> tagNames,
      final RecurringRule? recurringRule}) = _$TaskImpl;

  factory _Task.fromJson(Map<String, dynamic> json) = _$TaskImpl.fromJson;

  @override
  int get id;
  @override
  int get listId;
  @override
  String get title;
  @override
  String? get note;
  @override
  Priority get priority;
  @override
  DateTime? get dueDate;
  @override
  String? get dueTime;
  @override
  bool get isCompleted;
  @override
  DateTime? get completedAt;
  @override
  int get sortOrder;
  @override
  int? get parentId;
  @override
  int? get recurringRuleId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // Navigation properties (populated when needed)
  @override
  List<Task> get subtasks;
  @override
  List<String> get tagNames;
  @override
  RecurringRule? get recurringRule;

  /// Create a copy of Task
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
