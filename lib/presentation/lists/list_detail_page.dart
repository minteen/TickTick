import 'package:flutter/material.dart';

class ListDetailPage extends StatelessWidget {
  final int listId;
  const ListDetailPage({super.key, required this.listId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List')),
      body: Center(child: Text('List $listId')),
    );
  }
}
