import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilia/localization.dart';
import 'package:utilia/main_premium.dart';
import 'package:utilia/monetization.dart';
import 'package:utilia/storage.dart';

class _UnavailableMonetization extends UtiliaMonetization {
  @override
  Future<bool> buyMonthly() async => false;

  @override
  Future<bool> buyAnnual() async => false;

  @override
  Future<bool> buyNoAds() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Premium purchase button gives feedback when Google Play cannot start a purchase',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final monetization = _UnavailableMonetization();

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          home: UtiliaHomePage(
            storage: UtiliaStorage(),
            darkMode: false,
            language: UtiliaLanguage.es,
            monetization: monetization,
            onTheme: (_) async {},
            onLanguage: (_) async {},
          ),
        ),
      );
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

      final purchaseButton = find.text('Suscribirme').first;
      await tester.ensureVisible(purchaseButton);
      await tester.pumpAndSettle();
      await tester.tap(purchaseButton);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No se ha podido iniciar la compra. Comprueba tu conexión y vuelve a intentarlo.',
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      monetization.dispose();
    },
  );
}
