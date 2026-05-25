import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/task_providers.dart';
import '../../providers/list_providers.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';

class ListDetailPage extends ConsumerWidget {
  final int listId;
  const ListDetailPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByListProvider(listId));
    final listsAsync = ref.watch(allListsProvider);
    final list = listsAsync.valueOrNull?.where((l) => l.id == listId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(list?.name ?? 'List')),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final incomplete = tasks.where((t) => !t.isCompleted).toList();
          final completed = tasks.where((t) => t.isCompleted).toList();

          if (tasks.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox,
              title: 'No tasks yet',
              subtitle: 'Tap + to add a task',
            );
          }

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            children: [
              ...incomplete.map((task) => TaskTile(
                task: task,
                onTap: () => context.push('/task/${task.id}'),
              )),
              if (completed.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 16, 8),
                  child: Text(
                    'Completed (${completed.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
                  ),
                ),
                ...completed.map((task) => TaskTile(
                  task: task,
                  onTap: () => context.push('/task/${task.id}'),
                )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/task/new?listId=$listId'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
