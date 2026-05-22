import 'package:flutter/material.dart';
import '../../domain/enums/priority.dart';
import '../../core/theme.dart';

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    if (priority == Priority.none) return const SizedBox.shrink();
    final color = AppTheme.priorityColors[priority.value] ?? Colors.grey;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
