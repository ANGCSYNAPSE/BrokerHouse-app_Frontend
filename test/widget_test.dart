import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brokerhouse_app/main.dart';

void main() {
  testWidgets('App boots to the splash screen while the session check runs', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BrokerHouseApp()));

    // Before the async session check resolves, the router starts at /splash.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
