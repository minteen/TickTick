import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'month_view.dart';
import 'week_view.dart';
import 'day_view.dart';

enum CalendarView { month, week, day }

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  final _pageController = PageController(initialPage: 0);
  CalendarView _currentView = CalendarView.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  String get _title {
    switch (_currentView) {
      case CalendarView.month:
        return DateFormat.yMMMM('zh_CN').format(_focusedDay);
      case CalendarView.week:
        final weekStart = _focusedDay.subtract(Duration(days: _focusedDay.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final fmt = DateFormat('M月d日', 'zh_CN');
        return '${fmt.format(weekStart)} - ${fmt.format(weekEnd)}';
      case CalendarView.day:
        return DateFormat('M月d日 EEEE', 'zh_CN').format(_focusedDay);
    }
  }

  void _goToToday() {
    setState(() {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _pageController.jumpToPage(_currentView.index);
    });
  }

  void _onViewChanged(CalendarView view) {
    setState(() {
      _currentView = view;
      _focusedDay = _selectedDay;
    });
    _pageController.animateToPage(
      view.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(icon: const Icon(Icons.today), onPressed: _goToToday),
        ],
      ),
      body: Column(
        children: [
          SegmentedButton<CalendarView>(
            segments: const [
              ButtonSegment(value: CalendarView.month, label: Text('月')),
              ButtonSegment(value: CalendarView.week, label: Text('周')),
              ButtonSegment(value: CalendarView.day, label: Text('日')),
            ],
            selected: {_currentView},
            onSelectionChanged: (v) => _onViewChanged(v.first),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentView = CalendarView.values[index]);
              },
              children: [
                MonthView(
                  selectedDay: _selectedDay,
                  focusedDay: _focusedDay,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                ),
                WeekView(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: (day) {
                    setState(() {
                      _selectedDay = day;
                      _focusedDay = day;
                    });
                  },
                  onPageChanged: (day) {
                    setState(() => _focusedDay = day);
                  },
                ),
                DayView(
                  focusedDay: _focusedDay,
                  onDaySelected: (day) {
                    setState(() => _selectedDay = day);
                  },
                  onPageChanged: (day) {
                    setState(() => _focusedDay = day);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
