import 'package:flutter_test/flutter_test.dart';

import 'package:utilia/monetization.dart';

void main() {
  test('Premium catalog exposes monthly, annual and lifetime No Ads products', () {
    expect(UtiliaMonetization.monthlyProductId, 'utilia_premium_monthly');
    expect(UtiliaMonetization.annualProductId, 'utilia_premium_annual');
    expect(UtiliaMonetization.noAdsProductId, 'utilia_no_ads');
  });

  test('Legacy Premium product remains recognized', () {
    expect(UtiliaMonetization.legacyPremiumProductId, 'utilia_premium');
  });

  test('Lifetime No Ads fallback price remains 2.99 EUR', () {
    expect(UtiliaMonetization.noAdsPriceLabel, '2,99 €');
  });

  test('Production ad configuration exposes a test-safe fallback', () {
    expect(
      UtiliaMonetization.testAndroidBannerAdUnitId,
      'ca-app-pub-3940256099942544/6300978111',
    );
  });
}
