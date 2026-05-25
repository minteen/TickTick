import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/task_providers.dart';
import 'task_card.dart';

class AllDaySection extends ConsumerWidget {
  final DateTime date;

  const AllDaySection({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(calendarDateTasksProvider(date));

    return tasksAsync.when(
      loading: () => const SizedBox(
        height: 24,
        child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
      ),
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
