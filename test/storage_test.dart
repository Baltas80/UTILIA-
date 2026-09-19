import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilia/storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('favorites persist and round-trip', () async {
    final storage = UtiliaStorage();
    await storage.saveFavorites({'percentage', 'bmi'});
    expect(await storage.loadFavorites(), {'percentage', 'bmi'});
  });

  test('dark mode and language persist', () async {
    final storage = UtiliaStorage();
    await storage.saveDarkMode(true);
    await storage.saveLanguage('fr');
    expect(await storage.loadDarkMode(), isTrue);
    expect(await storage.loadLanguage(), 'fr');
  });

  test('history is newest first and capped at 50 entries', () async {
    final storage = UtiliaStorage();
    for (var i = 0; i < 55; i++) {
      await storage.addHistory({'tool': 'test', 'result': '$i'});
    }
    final history = await storage.loadHistory();
    expect(history, hasLength(50));
    expect(history.first['result'], '54');
    expect(history.last['result'], '5');
  });

  test('corrupt history entries are ignored safely', () async {
    SharedPreferences.setMockInitialValues({
      'history': ['not-json', '{"tool":"ok","result":"1"}'],
    });
    final storage = UtiliaStorage();
    final history = await storage.loadHistory();
    expect(history, hasLength(1));
    expect(history.single['tool'], 'ok');
  });

  test('clear history removes persisted entries', () async {
    final storage = UtiliaStorage();
    await storage.addHistory({'tool': 'test'});
    await storage.clearHistory();
    expect(await storage.loadHistory(), isEmpty);
  });
}
