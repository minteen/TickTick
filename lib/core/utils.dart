import 'package:intl/intl.dart';

class DateUtils {
  static final _dateFormatter = DateFormat('MMM d');
  static final _dateFormatterWithYear = DateFormat('MMM d, yyyy');
  static final _timeFormatter = DateFormat('h:mm a');

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) return 'Today';
    if (dateDay == tomorrow) return 'Tomorrow';
    if (dateDay.difference(today).inDays < 7 && dateDay.isAfter(today)) {
      return DateFormat('EEEE').format(date); // Day name
    }
    if (date.year == now.year) return _dateFormatter.format(date);
    return _dateFormatterWithYear.format(date);
  }

  static String formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final dt = DateTime(2024, 1, 1, hour, minute);
    return _timeFormatter.format(dt);
  }

  static bool isOverdue(DateTime date, [String? time]) {
    final now = DateTime.now();
    if (time != null) {
      final parts = time.split(':');
      final dt = DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
      return dt.isBefore(now);
    }
    final dateDay = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return dateDay.isBefore(today);
  }

  static String formatRelative(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dateTime);
  }
}
