import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/enums/priority.dart';
import '../../core/utils.dart' as date_utils;
import '../../providers/task_providers.dart';
import '../widgets/priority_badge.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final int taskId;
  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  final _subtaskController = TextEditingController();

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.push('/task/new?taskId=${widget.taskId}&listId=${taskAsync.valueOrNull?.listId ?? 0}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteTask(),
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (task) {
          if (task == null) return const Center(child: Text('Task not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => ref.read(taskActionsProvider).toggleTask(task.id, task.listId),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        border: Border.all(
                          color: task.isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: task.isCompleted ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.priority != Priority.none || task.dueDate != null || task.recurringRuleId != null) ...[
                const SizedBox(height: 16),
                Wrap(spacing: 8, children: [
                  if (task.priority != Priority.none)
                    Chip(
                      avatar: PriorityBadge(priority: task.priority),
                      label: Text('${task.priority.label} Priority'),
                    ),
                  if (task.dueDate != null)
                    Chip(
                      avatar: Icon(Icons.calendar_today, size: 16,
                        color: date_utils.DateUtils.isOverdue(task.dueDate!, task.dueTime) ? Colors.red : null),
                      label: Text('${date_utils.DateUtils.formatDate(task.dueDate!)}${task.dueTime != null ? ' ${date_utils.DateUtils.formatTime(task.dueTime!)}' : ''}'),
                    ),
                  if (task.recurringRuleId != null)
                    const Chip(avatar: Icon(Icons.repeat, size: 16), label: Text('Recurring')),
                ]),
              ],
              if (task.note != null && task.note!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Note', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(task.note!),
                ),
              ],
              const SizedBox(height: 24),
              Text('Subtasks', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              _SubtaskList(taskId: widget.taskId),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(children: [
                  const Icon(Icons.add, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(hintText: 'Add subtask', border: InputBorder.none, isDense: true),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          ref.read(taskActionsProvider).createSubtask(task.id, value.trim());
                          _subtaskController.clear();
                        }
                      },
                    ),
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final task = ref.read(taskDetailProvider(widget.taskId)).valueOrNull;
      if (task != null) {
        await ref.read(taskActionsProvider).deleteTask(task.id, task.listId);
        if (mounted) context.pop();
      }
    }
  }
}

class _SubtaskList extends ConsumerWidget {
  final int taskId;
  const _SubtaskList({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtasksAsync = ref.watch(subtasksProvider(taskId));
    return subtasksAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (subtasks) => Column(
        children: subtasks.map((st) => ListTile(
          dense: true,
          leading: GestureDetector(
            onTap: () => ref.read(taskActionsProvider).toggleTask(st.id, st.listId),
            child: Icon(
              st.isCompleted ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: st.isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ),
          title: Text(
            st.title,
            style: TextStyle(decoration: st.isCompleted ? TextDecoration.lineThrough : null),
          ),
        )).toList(),
      ),
    );
  }
}
