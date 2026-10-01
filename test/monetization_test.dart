import 'package:flutter_test/flutter_test.dart';

import 'package:utilia/monetization.dart';

void main() {
  test('Premium product configuration is stable', () {
    expect(UtiliaMonetization.premiumProductId, 'utilia_premium');
    expect(UtiliaMonetization.premiumPriceLabel, '2,99 €');
  });

  test('Ads are not ready before initialization', () {
    final monetization = UtiliaMonetization();
    addTearDown(monetization.dispose);

    expect(monetization.adsReady, isFalse);
  });
}
