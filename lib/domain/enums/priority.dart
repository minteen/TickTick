enum Priority {
  none(0, 'None'),
  low(1, 'Low'),
  medium(2, 'Medium'),
  high(3, 'High');

  const Priority(this.value, this.label);
  final int value;
  final String label;

  static Priority fromValue(int value) {
    return Priority.values.firstWhere((p) => p.value == value, orElse: () => Priority.none);
  }
}
