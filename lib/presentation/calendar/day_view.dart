import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DayView extends ConsumerWidget {
  final DateTime focusedDay;
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime day) onPageChanged;

  const DayView({
    super.key,
    required this.focusedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(child: Text('Day View'));
  }
}
