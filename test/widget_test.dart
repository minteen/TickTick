import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticktick/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TickTickApp());
    expect(find.text('Today'), findsOneWidget);
  });
}
