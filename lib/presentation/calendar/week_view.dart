import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    // Monday = weekday 1 in Dart
    final monday = widget.focusedDay.subtract(Duration(days: widget.focusedDay.weekday - 1));
    return List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));
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
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    const gridHeight = (_endHour - _startHour) * _hourHeight;

    // Fetch month data covering this week
    final tasksAsync = ref.watch(calendarMonthTasksProvider(
      DateTime(weekStart.year, weekStart.month, 1),
    ));

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
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: _weekDays.map((day) {
                final isToday = day.year == todayStart.year &&
                    day.month == todayStart.month &&
                    day.day == todayStart.day;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onDaySelected(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E', 'zh_CN').format(day),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: isToday
                                ? BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  )
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
          // All-day section row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: _weekDays.map((day) {
                return Expanded(child: AllDaySection(date: day));
              }).toList(),
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
                    height: gridHeight,
                    child: Stack(
                      children: [
                        // Hour grid lines
                        ...List.generate(_endHour - _startHour + 1, (i) {
                          return Positioned(
                            top: i * _hourHeight,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Divider(
                                  height: 1,
                                  color: i == 0 ? Colors.grey.shade400 : const Color(0xFFE8E8E8),
                                ),
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
                        // 7 day columns with task cards
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
                                children: [
                                  // Vertical column dividers
                                  if (dayIndex > 0)
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(width: 1, color: const Color(0xFFEEEEEE)),
                                    ),
                                  // Task cards
                                  ...dayTasks.map((task) {
                                    final time = _parseTime(task.dueTime!);
                                    final topOffset = (time.$1 - _startHour) * _hourHeight +
                                        (time.$2 / 60.0 * _hourHeight);
                                    return Positioned(
                                      top: topOffset,
                                      left: 1,
                                      right: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.onDaySelected(day);
                                          context.push('/task/${task.id}');
                                        },
                                        child: TaskCard(task: task, compact: true),
                                      ),
                                    );
                                  }),
                                ],
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
