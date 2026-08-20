import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brokerhouse_app/core/widgets/splash_screen.dart';
import 'package:brokerhouse_app/main.dart';

void main() {
  testWidgets('App boots to the splash screen while the session check runs', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BrokerHouseApp()));

    // Before the async session check resolves, the router starts at /splash.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Exclusively for Certified Builders & Registered Brokers'), findsOneWidget);
  });
}
