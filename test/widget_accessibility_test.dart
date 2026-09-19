import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilia/main_premium.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home remains usable with enlarged text', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const UtiliaPremiumApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('UTILIA'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
