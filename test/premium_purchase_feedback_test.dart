import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilia/main_premium.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Premium purchase button gives feedback when Google Play cannot start a purchase',
    (tester) async {
      SharedPreferences.setMockInitialValues({'language': 'es'});

      await tester.pumpWidget(const UtiliaPremiumApp());
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(
          of: navigationBar,
          matching: find.text('Más'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('UTILIA Premium'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Suscribirme').first);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No se ha podido iniciar la compra. Comprueba tu conexión y vuelve a intentarlo.',
        ),
        findsOneWidget,
      );
    },
  );
}
