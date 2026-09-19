import 'package:flutter_test/flutter_test.dart';
import 'package:utilia/localization.dart';

void main() {
  test('all supported languages provide core translations', () {
    for (final language in UtiliaLanguage.values) {
      final s = UtiliaStrings(language);
      expect(s.languageName, isNotEmpty);
      expect(s.search, isNotEmpty);
      expect(s.categories, isNotEmpty);
      expect(s.calculate, isNotEmpty);
      expect(s.noResults, isNotEmpty);
      expect(s.privacyLink, isNotEmpty);
      expect(s.toolName('percentage', 'Percentage'), isNotEmpty);
      expect(
          s.toolDescription('percentage', 'Calculate percentage'), isNotEmpty);
    }
  });

  test('language codes round-trip', () {
    for (final language in UtiliaLanguage.values) {
      expect(UtiliaStrings.fromCode(UtiliaStrings.code(language)), language);
    }
  });
}
