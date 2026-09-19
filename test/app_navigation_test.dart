import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilia/main_premium.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'home navigation exposes all primary destinations',
    (tester) async {
      SharedPreferences.setMockInitialValues({'language': 'es'});
      await tester.pumpWidget(const UtiliaPremiumApp());
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      final homeItems = find.descendant(
        of: navigationBar,
        matching: find.byType(NavigationDestination),
      );
      expect(homeItems, findsNWidgets(4));
    },
  );

  testWidgets(
    'quick access and categories open real lists',
    (tester) async {
      SharedPreferences.setMockInitialValues({'language': 'es'});
      await tester.pumpWidget(const UtiliaPremiumApp());
      await tester.pumpAndSettle();

      final seeAllButtons = find.text('Ver todas');
      expect(seeAllButtons, findsNWidgets(2));

      await tester.tap(seeAllButtons.first);
      await tester.pumpAndSettle();
      expect(find.text('Calculadora'), findsOneWidget);
      expect(find.text('Calculadora científica'), findsOneWidget);

      await tester.tap(find.text('Calculadora').first);
      await tester.pumpAndSettle();
      expect(find.text('Científica'), findsNothing);
      expect(find.text('Calculadora'), findsWidgets);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver todas').last);
      await tester.pumpAndSettle();
      expect(find.text('Dinero'), findsOneWidget);
      expect(find.text('Conversores'), findsOneWidget);
    },
  );
}
