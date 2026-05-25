import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
                const gridHeight = (_endHour - _startHour) * _hourHeight;

                return SingleChildScrollView(
                  child: SizedBox(
                    height: gridHeight,
                    child: Stack(
                      children: [
                        // Hour grid lines and labels
                        ...List.generate(_endHour - _startHour + 1, (i) {
                          final hour = _startHour + i;
                          return Positioned(
                            top: i * _hourHeight,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Divider(height: 1, color: hour == _startHour ? Colors.grey.shade400 : const Color(0xFFE8E8E8)),
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
}
