enum RecurringType {
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  yearly('yearly', 'Yearly');

  const RecurringType(this.value, this.label);
  final String value;
  final String label;

  static RecurringType fromValue(String value) {
    return RecurringType.values.firstWhere((t) => t.value == value, orElse: () => RecurringType.daily);
  }
}
