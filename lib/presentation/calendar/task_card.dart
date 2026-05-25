import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart' as domain;
import '../../../domain/enums/priority.dart';
import '../../../core/utils.dart' as date_utils;

class TaskCard extends StatelessWidget {
  final domain.Task task;
  final VoidCallback? onTap;
  final bool compact;

  const TaskCard({super.key, required this.task, this.onTap, this.compact = false});

  static const _priorityColors = {
    Priority.high: Color(0xFFE74C3C),
    Priority.medium: Color(0xFFF5A623),
    Priority.low: Color(0xFF4A90D9),
    Priority.none: Color(0xFFCCCCCC),
  };

  Color get _borderColor => _priorityColors[task.priority] ?? _priorityColors[Priority.none]!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8, vertical: compact ? 2 : 4),
        decoration: BoxDecoration(
          color: _borderColor.withAlpha(25),
          border: Border(left: BorderSide(color: _borderColor, width: 3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontWeight: FontWeight.w500,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            if (!compact && task.dueTime != null)
              Text(
                date_utils.DateUtils.formatTime(task.dueTime!),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }
}
