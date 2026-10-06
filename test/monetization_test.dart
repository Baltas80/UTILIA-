import 'package:flutter_test/flutter_test.dart';

import 'package:utilia/monetization.dart';

void main() {
  test('Premium product configuration is stable', () {
    expect(UtiliaMonetization.premiumProductId, 'utilia_premium');
    expect(UtiliaMonetization.premiumPriceLabel, '2,99 €');
  });

  test('Production ad configuration exposes a test-safe fallback', () {
    expect(
      UtiliaMonetization.testAndroidBannerAdUnitId,
      'ca-app-pub-3940256099942544/6300978111',
    );
  });
}
