import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart' as domain;
import '../../../domain/enums/priority.dart';
import '../../../providers/task_providers.dart';
import '../widgets/task_tile.dart';

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
              autofocus: true,
              decoration: const InputDecoration(hintText: '任务标题', border: OutlineInputBorder()),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  context.push('/task/new?listId=0&dueDate=${DateFormat('yyyy-MM-dd').format(date)}');
                }
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/task/new?listId=0&dueDate=${DateFormat('yyyy-MM-dd').format(date)}');
              },
              child: const Text('更多选项...'),
            ),
          ],
        ),
      ),
    );
  }
}
