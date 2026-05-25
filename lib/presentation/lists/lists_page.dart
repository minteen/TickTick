import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/task_list.dart';
import '../../core/theme.dart';
import '../../providers/list_providers.dart';
import '../widgets/empty_state.dart';

class ListsPage extends ConsumerWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(allListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Lists')),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lists) {
          if (lists.isEmpty) {
            return const EmptyState(
              icon: Icons.list_alt,
              title: 'No lists yet',
              subtitle: 'Tap + to create your first list',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: lists.length,
            itemBuilder: (context, index) => _ListTileWidget(list: lists[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createList(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createList(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final lists = ref.read(allListsProvider).valueOrNull ?? [];
                final color = AppTheme.listColors[lists.length % AppTheme.listColors.length];
                ref.read(allListsProvider.notifier).createList(
                  controller.text.trim(),
                  '#${color.toARGB32().toRadixString(16).substring(2)}',
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _ListTileWidget extends StatelessWidget {
  final TaskList list;
  const _ListTileWidget({required this.list});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color(int.parse('0xFF${list.color.substring(1)}')),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.list, color: Colors.white, size: 18),
        ),
        title: Text(list.name),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/lists/${list.id}'),
      ),
    );
  }
}
