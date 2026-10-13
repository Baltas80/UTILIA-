import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilia/catalog.dart';
import 'package:utilia/category_page.dart';
import 'package:utilia/localization.dart';
import 'package:utilia/monetization.dart';
import 'package:utilia/models/tool.dart';
import 'package:utilia/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final tool in tools) {
    testWidgets('${tool.name} opens its functional screen', (tester) async {
      const strings = UtiliaStrings(UtiliaLanguage.es);
      final monetization = UtiliaMonetization();

      await tester.pumpWidget(
        MaterialApp(
          home: UtiliaCategoryPage(
            category: tool.category,
            tools: [tool],
            favorites: <ToolType>{},
            onFavorite: (_) async {},
            storage: UtiliaStorage(),
            onHistory: () async {},
            s: strings,
            monetization: monetization,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(tool.name));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(tool.name), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      monetization.dispose();
    });
  }

  testWidgets('percentage tool calculates and displays a result', (tester) async {
    const strings = UtiliaStrings(UtiliaLanguage.es);
    final monetization = UtiliaMonetization();

    await tester.pumpWidget(
      MaterialApp(
        home: UtiliaCategoryPage(
          category: 'Dinero',
          tools: tools.where((tool) => tool.type == ToolType.percentage).toList(),
          favorites: <ToolType>{},
          onFavorite: (_) async {},
          storage: UtiliaStorage(),
          onHistory: () async {},
          s: strings,
          monetization: monetization,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Porcentaje'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), '200');
    await tester.enterText(fields.at(1), '10');
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('20'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    monetization.dispose();
  });
}
