import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeekView extends ConsumerStatefulWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final void Function(DateTime day) onDaySelected;
  final void Function(DateTime day) onPageChanged;

  const WeekView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Week View'));
  }
}
