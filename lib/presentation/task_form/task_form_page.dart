import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/priority.dart';
import '../../providers/task_providers.dart';
import '../../providers/list_providers.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  final int? listId;
  final int? taskId;

  const TaskFormPage({super.key, this.listId, this.taskId});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  int _listId = 0;
  Priority _priority = Priority.none;
  DateTime? _dueDate;
  String? _dueTime;
  bool _isEditing = false;
  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
    _listId = widget.listId ?? 0;
    _isEditing = widget.taskId != null;
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadTask());
    }
  }

  Future<void> _loadTask() async {
    final task = await ref.read(taskDetailProvider(widget.taskId!).future);
    if (task != null && mounted) {
      setState(() {
        _existingTask = task;
        _titleController.text = task.title;
        _noteController.text = task.note ?? '';
        _listId = task.listId;
        _priority = task.priority;
        _dueDate = task.dueDate;
        _dueTime = task.dueTime;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      id: _existingTask?.id ?? 0,
      listId: _listId > 0 ? _listId : 1,
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      dueTime: _dueTime,
      createdAt: _existingTask?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      isCompleted: _existingTask?.isCompleted ?? false,
      completedAt: _existingTask?.completedAt,
      parentId: _existingTask?.parentId,
      recurringRuleId: _existingTask?.recurringRuleId,
    );

    final actions = ref.read(taskActionsProvider);
    if (_isEditing) {
      await actions.updateTask(task);
    } else {
      await actions.createTask(task);
    }
    if (mounted) context.pop();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _dueTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listsAsync = ref.watch(allListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            autofocus: !_isEditing,
            decoration: const InputDecoration(hintText: 'Task title', border: InputBorder.none),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(hintText: 'Add note...', border: InputBorder.none),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Text('List', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          listsAsync.when(
            data: (lists) => DropdownButtonFormField<int>(
              initialValue: _listId > 0 ? _listId : null,
              items: lists.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name))).toList(),
              onChanged: (v) => setState(() => _listId = v ?? 0),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 16),
          Text('Priority', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<Priority>(
            segments: Priority.values.map((p) => ButtonSegment<Priority>(
              value: p,
              label: Text(p.label),
            )).toList(),
            selected: {_priority},
            onSelectionChanged: (v) => setState(() => _priority = v.first),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_dueDate != null
                ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                : 'Set due date'),
            trailing: _dueDate != null
                ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _dueDate = null))
                : null,
            onTap: _pickDate,
          ),
          if (_dueDate != null)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(_dueTime != null ? _dueTime! : 'Set time'),
              trailing: _dueTime != null
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _dueTime = null))
                  : null,
              onTap: _pickTime,
            ),
        ],
      ),
    );
  }
}
