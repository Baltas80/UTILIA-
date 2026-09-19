import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilia/catalog.dart';
import 'package:utilia/category_page.dart';
import 'package:utilia/localization.dart';
import 'package:utilia/main_premium.dart';
import 'package:utilia/models/tool.dart';
import 'package:utilia/storage.dart';

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
    'category page exposes the real tool list',
    (tester) async {
      final categoryTools = tools
          .where((tool) => tool.category == 'Dinero')
          .toList();
      const strings = UtiliaStrings(UtiliaLanguage.es);

      await tester.pumpWidget(
        MaterialApp(
          home: UtiliaCategoryPage(
            category: 'Dinero',
            tools: categoryTools,
            favorites: <ToolType>{},
            onFavorite: (_) async {},
            storage: UtiliaStorage(),
            onHistory: () async {},
            s: strings,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Porcentaje'), findsOneWidget);
      expect(find.text('Descuentos'), findsOneWidget);
      expect(find.text('Préstamos'), findsOneWidget);
      expect(find.text('Interés compuesto'), findsOneWidget);
    },
  );
}
