import 'package:flutter/material.dart' hide DateUtils;
import '../../core/utils.dart';

class DueDateChip extends StatelessWidget {
  final DateTime date;
  final String? time;
  const DueDateChip({super.key, required this.date, this.time});

  @override
  Widget build(BuildContext context) {
    final overdue = DateUtils.isOverdue(date, time);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today,
          size: 12,
          color: overdue ? Colors.red : Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '${DateUtils.formatDate(date)}${time != null ? ' ${DateUtils.formatTime(time!)}' : ''}',
          style: TextStyle(
            fontSize: 12,
            color: overdue ? Colors.red : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
