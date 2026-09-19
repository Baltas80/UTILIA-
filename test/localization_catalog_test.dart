import 'package:flutter_test/flutter_test.dart';
import 'package:utilia/catalog.dart';
import 'package:utilia/localization.dart';

void main() {
  test('every catalog tool has localized name and description', () {
    for (final language in UtiliaLanguage.values) {
      final s = UtiliaStrings(language);
      for (final tool in tools) {
        final id = tool.type.name;
        expect(s.toolName(id, tool.name).trim(), isNotEmpty);
        expect(s.toolDescription(id, tool.description).trim(), isNotEmpty);
      }
    }
  });

  test('every category has a localized label', () {
    for (final language in UtiliaLanguage.values) {
      final s = UtiliaStrings(language);
      for (final categoryId in categories) {
        expect(s.category(categoryId).trim(), isNotEmpty);
      }
    }
  });
}
