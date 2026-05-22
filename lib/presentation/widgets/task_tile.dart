import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../providers/task_providers.dart';
import 'priority_badge.dart';
import 'due_date_chip.dart';

class TaskTile extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskTile({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  ref.read(taskActionsProvider).toggleTask(task.id, task.listId);
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted ? theme.colorScheme.primary : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              if (task.priority.value > 0) ...[
                const SizedBox(width: 8),
                PriorityBadge(priority: task.priority),
              ],
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      DueDateChip(date: task.dueDate!, time: task.dueTime),
                    ],
                  ],
                ),
              ),
              if (task.recurringRuleId != null)
                Icon(Icons.repeat, size: 18, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
