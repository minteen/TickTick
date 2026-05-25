// Redirect: the old Today tab now lives under /calendar
import 'package:flutter/material.dart';
import '../calendar/calendar_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const CalendarPage();
  }
}
