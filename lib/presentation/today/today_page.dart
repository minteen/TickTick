import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/init_provider.dart';
import '../../providers/task_providers.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(initProvider);
    final tasksAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Today')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(todayTasksProvider.future),
        child: tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (tasks) {
            if (tasks.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.celebration,
                    title: 'All clear!',
                    subtitle: 'No tasks due today',
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskTile(
                task: tasks[index],
                onTap: () => context.push('/task/${tasks[index].id}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
