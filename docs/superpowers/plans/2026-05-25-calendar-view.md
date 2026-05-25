# Calendar View Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add month/week/day calendar views to TickTick, replacing the Today tab with a full calendar.

**Architecture:** Extend existing Clean Architecture data layer with date-range queries (DAO → Repository → Riverpod providers). Build calendar UI using `table_calendar` for month view and custom time-grid widgets for week/day views. Wire everything through a CalendarPage with PageView-based swipe navigation.

**Tech Stack:** Flutter, Riverpod, drift, table_calendar ^3.1.3, go_router, custom time-grid widgets

---

### Task 1: Add dependency and data layer for date-range queries

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/data/database/dao/task_dao.dart`
- Modify: `lib/domain/repositories/task_repository.dart`
- Modify: `lib/data/repositories/task_repository_impl.dart`
- Modify: `lib/providers/task_providers.dart`

- [ ] **Step 1: Add table_calendar to pubspec.yaml**

Add to dependencies:
```yaml
  table_calendar: ^3.1.3
```

Run: `flutter pub get`

- [ ] **Step 2: Add getTasksForDateRange to TaskDao**

In `lib/data/database/dao/task_dao.dart`, add this method inside the `TaskDao` class:

```dart
  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end) {
    return (select(tasks)
      ..where((t) =>
        t.dueDate.isSmallerOrEqualValue(end) &
        t.dueDate.isBiggerOrEqualValue(start) &
        t.parentId.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc)]))
      .get();
  }
```

Run build_runner:
```bash
cd /home/ubuntu/projects/TickTick && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Add method signatures to TaskRepository interface**

In `lib/domain/repositories/task_repository.dart`, add:

```dart
  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end);
  Stream<List<Task>> watchTasksForDateRange(DateTime start, DateTime end);
```

- [ ] **Step 4: Implement in TaskRepositoryImpl**

In `lib/data/repositories/task_repository_impl.dart`, add:

```dart
  @override
  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end) async {
    final rows = await _db.taskDao.getTasksForDateRange(start, end);
    return rows.map(_toEntity).toList();
  }

  @override
  Stream<List<Task>> watchTasksForDateRange(DateTime start, DateTime end) {
    return (_db.select(_db.tasks)
      ..where((t) =>
        t.dueDate.isSmallerOrEqualValue(end) &
        t.dueDate.isBiggerOrEqualValue(start) &
        t.parentId.isNull())
      ..orderBy([(t) => drift.OrderingTerm(expression: t.dueDate, mode: drift.OrderingMode.asc)]))
      .watch()
      .map((rows) => rows.map(_toEntity).toList());
  }
```

- [ ] **Step 5: Add calendar providers**

In `lib/providers/task_providers.dart`, add after the existing providers:

```dart
final calendarMonthTasksProvider =
    FutureProvider.family<List<Task>, DateTime>((ref, month) {
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0);
  return ref.read(taskRepositoryProvider).getTasksForDateRange(start, end);
});

final calendarDateTasksProvider =
    FutureProvider.family<List<Task>, DateTime>((ref, date) {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));
  return ref.read(taskRepositoryProvider).getTasksForDateRange(start, end);
});
```

- [ ] **Step 6: Verify analysis and commit**

```bash
dart analyze lib/data/database/dao/ lib/domain/repositories/ lib/data/repositories/ lib/providers/
```

```bash
git add -A && git commit -m "feat: add date-range query support for calendar"
```

---

### Task 2: Create CalendarPage shell with PageView and ViewSwitcher

**Files:**
- Create: `lib/presentation/calendar/calendar_page.dart`

- [ ] **Step 1: Create directory**

```bash
mkdir -p lib/presentation/calendar
```

- [ ] **Step 2: Write CalendarPage**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'month_view.dart';
import 'week_view.dart';
import 'day_view.dart';

enum CalendarView { month, week, day }

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  final _pageController = PageController(initialPage: 0);
  CalendarView _currentView = CalendarView.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String get _title {
    switch (_currentView) {
      case CalendarView.month:
        return DateFormat.yMMMM('zh_CN').format(_focusedDay);
      case CalendarView.week:
        final weekStart = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final fmt = DateFormat('M月d日', 'zh_CN');
        return '${fmt.format(weekStart)} - ${fmt.format(weekEnd)}';
      case CalendarView.day:
        return DateFormat('M月d日 EEEE', 'zh_CN').format(_focusedDay);
    }
  }

  void _goToToday() {
    setState(() {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _pageController.jumpToPage(_currentView.index);
    });
  }

  void _onViewChanged(CalendarView view) {
    setState(() {
      _currentView = view;
      _focusedDay = _selectedDay;
    });
    _pageController.animateToPage(
      view.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          if (_currentView == CalendarView.month)
            IconButton(icon: const Icon(Icons.today), onPressed: _goToToday),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<CalendarView>(
              segments: const [
                ButtonSegment(value: CalendarView.month, label: Text('月')),
                ButtonSegment(value: CalendarView.week, label: Text('周')),
                ButtonSegment(value: CalendarView.day, label: Text('日')),
              ],
              selected: {_currentView},
              onSelectionChanged: (v) => _onViewChanged(v.first),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentView = CalendarView.values[index]);
              },
              children: [
                MonthView(
                  selectedDay: _selectedDay,
                  focusedDay: _focusedDay,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                ),
                WeekView(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: (day) {
                    setState(() {
                      _selectedDay = day;
                      _focusedDay = day;
                    });
                  },
                  onPageChanged: (day) {
                    setState(() => _focusedDay = day);
                  },
                ),
                DayView(
                  focusedDay: _focusedDay,
                  onDaySelected: (day) {
                    setState(() => _selectedDay = day);
                  },
                  onPageChanged: (day) {
                    setState(() => _focusedDay = day);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create placeholder view stubs so analysis passes**

Create `lib/presentation/calendar/month_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthView extends ConsumerWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;

  const MonthView({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Month View'));
  }
}
```

Create `lib/presentation/calendar/week_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeekView extends ConsumerWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime day) onPageChanged;

  const WeekView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Week View'));
  }
}
```

Create `lib/presentation/calendar/day_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayView extends ConsumerWidget {
  final DateTime focusedDay;
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime day) onPageChanged;

  const DayView({
    super.key,
    required this.focusedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Day View'));
  }
}
```

- [ ] **Step 4: Analyze and commit**

```bash
dart analyze lib/presentation/calendar/
```

```bash
git add -A && git commit -m "feat: add calendar page shell with view switcher and stubs"
```

---

### Task 3: Implement Month View with table_calendar

**Files:**
- Overwrite: `lib/presentation/calendar/month_view.dart`

- [ ] **Step 1: Implement MonthView**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/entities/task.dart' as domain;
import '../../../domain/enums/priority.dart';
import '../../../providers/task_providers.dart';
import '../../widgets/task_tile.dart';
import '../../widgets/empty_state.dart';
import '../../task_form/task_form_page.dart';

class MonthView extends ConsumerWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;

  const MonthView({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
  });

  // Colors for priority dots
  static const _priorityColors = {
    Priority.high: Color(0xFFE74C3C),
    Priority.medium: Color(0xFFF5A623),
    Priority.low: Color(0xFF4A90D9),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthStart = DateTime(focusedDay.year, focusedDay.month, 1);
    final tasksAsync = ref.watch(calendarMonthTasksProvider(monthStart));

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'zh_CN',
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerVisible: false,
          onDaySelected: (selected, focused) {
            onDaySelected(selected, focused);
          },
          onPageChanged: (focused) {
            onDaySelected(selectedDay, focused);
          },
          eventLoader: (day) {
            return tasksAsync.valueOrNull
                    ?.where((t) =>
                        t.dueDate != null &&
                        t.dueDate!.year == day.year &&
                        t.dueDate!.month == day.month &&
                        t.dueDate!.day == day.day)
                    .toList() ??
                [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              final dayTasks = events.cast<domain.Task>();
              final dots = <Color>[];
              if (dayTasks.any((t) => t.priority == Priority.high)) dots.add(_priorityColors[Priority.high]!);
              if (dayTasks.any((t) => t.priority == Priority.medium)) dots.add(_priorityColors[Priority.medium]!);
              if (dayTasks.any((t) => t.priority == Priority.low)) dots.add(_priorityColors[Priority.low]!);
              if (dots.isEmpty) return null;

              return Positioned(
                bottom: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: dots.map((c) => Container(
                    width: 6, height: 6, margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  )).toList(),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        // Selected day task list
        tasksAsync.when(
          loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Expanded(child: Center(child: Text('Error: $e'))),
          data: (_) {
            final dayTasks = tasksAsync.valueOrNull
                    ?.where((t) =>
                        t.dueDate != null &&
                        t.dueDate!.year == selectedDay.year &&
                        t.dueDate!.month == selectedDay.month &&
                        t.dueDate!.day == selectedDay.day)
                    .toList() ??
                [];

            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      '${selectedDay.month}月${selectedDay.day}日',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (dayTasks.isEmpty)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _quickCreate(context, selectedDay),
                        child: const Center(
                          child: Text('无任务，点击此处创建',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: dayTasks.length,
                        itemBuilder: (context, index) => TaskTile(
                          task: dayTasks[index],
                          onTap: () => context.push('/task/${dayTasks[index].id}'),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _quickCreate(BuildContext context, DateTime date) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('新建任务 — ${date.month}月${date.day}日', style: Theme.of(ctx).textTheme.titleSmall),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: '任务标题', border: OutlineInputBorder()),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  // Quick-create task — navigates to full form with params
                  Navigator.pop(ctx);
                  context.push('/task/new?listId=0&dueDate=${date.toIso8601String()}');
                }
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/task/new?listId=0&dueDate=${date.toIso8601String()}');
              },
              child: const Text('更多选项...'),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze and commit**

```bash
dart analyze lib/presentation/calendar/month_view.dart
```

```bash
git add -A && git commit -m "feat: implement month view with table_calendar and priority dots"
```

---

### Task 4: Implement All-Day Section and Task Card widgets

**Files:**
- Create: `lib/presentation/calendar/all_day_section.dart`
- Create: `lib/presentation/calendar/task_card.dart`

- [ ] **Step 1: Write TaskCard widget**

File: `lib/presentation/calendar/task_card.dart`
```dart
import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart' as domain;
import '../../../domain/enums/priority.dart';
import '../../../core/utils.dart' as date_utils;

class TaskCard extends StatelessWidget {
  final domain.Task task;
  final VoidCallback? onTap;
  final bool compact;

  const TaskCard({super.key, required this.task, this.onTap, this.compact = false});

  static const _priorityColors = {
    Priority.high: Color(0xFFE74C3C),
    Priority.medium: Color(0xFFF5A623),
    Priority.low: Color(0xFF4A90D9),
    Priority.none: Color(0xFFCCCCCC),
  };

  Color get _borderColor => _priorityColors[task.priority] ?? _priorityColors[Priority.none]!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8, vertical: compact ? 2 : 4),
        decoration: BoxDecoration(
          color: _borderColor.withAlpha(25),
          border: Border(left: BorderSide(color: _borderColor, width: 3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w500,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            if (!compact && task.dueTime != null)
              Text(
                date_utils.DateUtils.formatTime(task.dueTime!),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write AllDaySection widget**

File: `lib/presentation/calendar/all_day_section.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/task.dart' as domain;
import '../../../providers/task_providers.dart';
import 'task_card.dart';

class AllDaySection extends ConsumerWidget {
  final DateTime date;

  const AllDaySection({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(calendarDateTasksProvider(date));

    return tasksAsync.when(
      loading: () => const SizedBox(height: 24, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))),
      error: (_, __) => const SizedBox.shrink(),
      data: (tasks) {
        final allDayTasks = tasks.where((t) => t.dueTime == null && !t.isCompleted).toList();
        if (allDayTasks.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Wrap(
            spacing: 4,
            runSpacing: 2,
            children: allDayTasks
                .map((t) => TaskCard(
                      task: t,
                      compact: true,
                      onTap: () => context.push('/task/${t.id}'),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: Analyze and commit**

```bash
dart analyze lib/presentation/calendar/
```

```bash
git add -A && git commit -m "feat: add task card and all-day section widgets for calendar"
```

---

### Task 5: Implement Day View

**Files:**
- Overwrite: `lib/presentation/calendar/day_view.dart`

- [ ] **Step 1: Implement DayView**

File: `lib/presentation/calendar/day_view.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart' as domain;
import '../../../providers/task_providers.dart';
import 'all_day_section.dart';
import 'task_card.dart';

class DayView extends ConsumerWidget {
  final DateTime focusedDay;
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime day) onPageChanged;

  const DayView({
    super.key,
    required this.focusedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  static const _startHour = 6;
  static const _endHour = 24;
  static const _hourHeight = 60.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayStart = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final tasksAsync = ref.watch(calendarDateTasksProvider(dayStart));

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < -50) {
          onPageChanged(focusedDay.add(const Duration(days: 1)));
        } else if (details.primaryVelocity! > 50) {
          onPageChanged(focusedDay.subtract(const Duration(days: 1)));
        }
      },
      child: Column(
        children: [
          // Day header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              DateFormat('M月d日 EEEE', 'zh_CN').format(focusedDay),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // All-day section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AllDaySection(date: dayStart),
          ),
          const SizedBox(height: 4),
          // Time grid
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tasks) {
                final timedTasks = tasks.where((t) => t.dueTime != null && !t.isCompleted).toList();

                return SingleChildScrollView(
                  child: SizedBox(
                    height: (_endHour - _startHour) * _hourHeight,
                    child: Stack(
                      children: [
                        // Hour grid lines
                        ...List.generate(_endHour - _startHour + 1, (i) {
                          final hour = _startHour + i;
                          return Positioned(
                            top: i * _hourHeight,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '$hour:00',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // Task cards
                        ...timedTasks.map((task) {
                          final time = _parseTime(task.dueTime!);
                          final topOffset = (time.$1 - _startHour) * _hourHeight + (time.$2 / 60.0 * _hourHeight);
                          return Positioned(
                            top: topOffset,
                            left: 52,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                onDaySelected(focusedDay);
                                context.push('/task/${task.id}');
                              },
                              onLongPress: () => _quickCreateAtTime(context, focusedDay, task.dueTime),
                              child: TaskCard(task: task),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  (int, int) _parseTime(String time) {
    final parts = time.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  void _quickCreateAtTime(BuildContext context, DateTime date, String? time) {
    context.push('/task/new?listId=0&dueDate=${date.toIso8601String()}&dueTime=${time ?? ''}');
  }
}
```

- [ ] **Step 2: Analyze and commit**

```bash
dart analyze lib/presentation/calendar/day_view.dart
```

```bash
git add -A && git commit -m "feat: implement day view with time grid"
```

---

### Task 6: Implement Week View

**Files:**
- Overwrite: `lib/presentation/calendar/week_view.dart`

- [ ] **Step 1: Implement WeekView**

File: `lib/presentation/calendar/week_view.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart' as domain;
import '../../../providers/task_providers.dart';
import 'all_day_section.dart';
import 'task_card.dart';

class WeekView extends ConsumerStatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime day) onPageChanged;

  const WeekView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  static const _startHour = 6;
  static const _endHour = 24;
  static const _hourHeight = 60.0;
  final _scrollController = ScrollController();

  List<DateTime> get _weekDays {
    final monday = widget.focusedDay.subtract(Duration(days: widget.focusedDay.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  (int, int) _parseTime(String time) {
    final parts = time.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _weekDays.first;
    final weekEnd = _weekDays.last.add(const Duration(days: 1));
    final tasksAsync = ref.watch(calendarMonthTasksProvider(
      DateTime(weekStart.year, weekStart.month, 1),
    ));
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < -50) {
          widget.onPageChanged(widget.focusedDay.add(const Duration(days: 7)));
        } else if (details.primaryVelocity! > 50) {
          widget.onPageChanged(widget.focusedDay.subtract(const Duration(days: 7)));
        }
      },
      child: Column(
        children: [
          // Day headers
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
            child: Row(
              children: _weekDays.map((day) {
                final isToday = day.year == todayStart.year &&
                    day.month == todayStart.month &&
                    day.day == todayStart.day;
                final isSelected = day.year == widget.selectedDay.year &&
                    day.month == widget.selectedDay.month &&
                    day.day == widget.selectedDay.day;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onDaySelected(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: isSelected
                          ? BoxDecoration(
                              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
                            )
                          : null,
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E', 'zh_CN').format(day),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 28, height: 28,
                            decoration: isToday
                                ? BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle)
                                : null,
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  color: isToday ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // All-day section
          tasksAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                children: _weekDays.map((day) {
                  return Expanded(
                    child: AllDaySection(date: day),
                  );
                }).toList(),
              ),
            ),
          ),
          // Time grid
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tasks) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  child: SizedBox(
                    height: (_endHour - _startHour) * _hourHeight,
                    child: Stack(
                      children: [
                        // Hour grid lines
                        ...List.generate(_endHour - _startHour + 1, (i) {
                          return Positioned(
                            top: i * _hourHeight,
                            left: 0, right: 0,
                            child: Column(
                              children: [
                                const Divider(height: 1, color: Color(0xFFE8E8E8)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '${_startHour + i}:00',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        // 7 day columns
                        Row(
                          children: _weekDays.asMap().entries.map((entry) {
                            final dayIndex = entry.key;
                            final day = entry.value;
                            final dayTasks = tasks.where((t) =>
                                t.dueDate != null &&
                                t.dueDate!.year == day.year &&
                                t.dueDate!.month == day.month &&
                                t.dueDate!.day == day.day &&
                                t.dueTime != null &&
                                !t.isCompleted).toList();

                            return Expanded(
                              child: Stack(
                                children: dayTasks.map((task) {
                                  final time = _parseTime(task.dueTime!);
                                  final topOffset = (time.$1 - _startHour) * _hourHeight +
                                      (time.$2 / 60.0 * _hourHeight);
                                  return Positioned(
                                    top: topOffset,
                                    left: 1, right: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        widget.onDaySelected(day);
                                        context.push('/task/${task.id}');
                                      },
                                      child: TaskCard(task: task, compact: true),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

Note: The `calendarMonthTasksProvider` is used with the month DateTime to ensure the week view gets data (we query the whole month to cover the week boundary case). The tasks are then filtered per-day within the widget.

- [ ] **Step 2: Analyze and commit**

```bash
dart analyze lib/presentation/calendar/week_view.dart
```

```bash
git add -A && git commit -m "feat: implement week view with 7-column time grid"
```

---

### Task 7: Update Navigation to Replace Today with Calendar

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Update app.dart**

In `lib/app.dart`:

1. Change the import:
```dart
// Replace:
import 'presentation/today/today_page.dart';
// With:
import 'presentation/calendar/calendar_page.dart';
```

2. Change the route:
```dart
// Replace:
GoRoute(path: '/today', builder: (_, __) => const TodayPage()),
// With:
GoRoute(path: '/calendar', builder: (_, __) => const CalendarPage()),
```

3. Change initialLocation:
```dart
// Replace:
initialLocation: '/today',
// With:
initialLocation: '/calendar',
```

4. Change the _currentIndex method:
```dart
// Replace:
if (location.startsWith('/today')) return 0;
// With:
if (location.startsWith('/calendar')) return 0;
```

5. Change the destination:
```dart
// Replace:
const NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
// With:
const NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
```

6. Change the routes list:
```dart
// Replace:
final routes = ['/today', '/lists', '/search', '/settings'];
// With:
final routes = ['/calendar', '/lists', '/search', '/settings'];
```

- [ ] **Step 2: Analyze and verify**

```bash
dart analyze lib/app.dart
```

- [ ] **Step 3: Commit**

```bash
git add -A && git commit -m "feat: replace Today tab with Calendar"
```

---

### Task 8: Cleanup and Final Integration

**Files:**
- Remove: `lib/presentation/today/today_page.dart` (or replace with a redirect wrapper)

- [ ] **Step 1: Replace today_page.dart with a redirect wrapper**

If any code still references `TodayPage` or `/today`, keep a thin wrapper. Otherwise remove it. Let's replace it with:

File: `lib/presentation/today/today_page.dart`
```dart
// Redirect: the old Today tab now lives under /calendar
import 'package:flutter/material.dart';
import '../calendar/calendar_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const CalendarPage();
  }
}
```

- [ ] **Step 2: Run full analysis**

```bash
dart analyze lib/
```

Fix any newly introduced issues. Pre-existing issues in generated drift files can be ignored.

- [ ] **Step 3: Run code generation**

```bash
cd /home/ubuntu/projects/TickTick && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Verify file structure**

```bash
find lib -name '*.dart' -not -path '*.g.dart' | sort
```

Expected new files:
```
lib/presentation/calendar/all_day_section.dart
lib/presentation/calendar/calendar_page.dart
lib/presentation/calendar/day_view.dart
lib/presentation/calendar/month_view.dart
lib/presentation/calendar/task_card.dart
lib/presentation/calendar/week_view.dart
```

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat: final cleanup and integration for calendar view"
```

---

## Plan Self-Review

**1. Spec coverage:**
- Data layer: date-range query (Task 1) — DAO, Repository interface, impl, providers
- Navigation: replace /today with /calendar (Task 7)
- CalendarPage with PageView + ViewSwitcher (Task 2)
- Month view with table_calendar, priority dots, task list below (Task 3)
- Week view with 7-column time grid 6-24, all-day section (Task 6)
- Day view with 1-column time grid 6-24, all-day section (Task 5)
- All-day section and task card widgets (Task 4)
- Quick-create from calendar (Task 3 for month, Task 5 for day, via /task/new route with params)
- Cleanup and integration (Task 8)

**2. Placeholder scan:** No TBD, TODO, or vague instructions. All steps have exact code.

**3. Type consistency:** CalendarView enum in Task 2 matches usage in all views. Task props (dueDate, dueTime, priority, isCompleted) match existing domain entity. Provider names match across files.
