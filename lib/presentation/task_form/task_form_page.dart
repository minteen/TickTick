import 'package:flutter/material.dart';

class TaskFormPage extends StatelessWidget {
  final int? listId;
  final int? taskId;
  const TaskFormPage({super.key, this.listId, this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: const Center(child: Text('Task Form')),
    );
  }
}
