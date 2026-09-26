import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UtiliaMonetization extends ChangeNotifier {
  static const premiumProductId = 'utilia_premium';
  static const premiumPriceLabel = '2,99 €';

  static const _testAndroidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _androidBannerId = String.fromEnvironment(
    'UTILIA_ADMOB_ANDROID_BANNER_ID',
    defaultValue: _testAndroidBannerId,
  );

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _premiumProduct;

  bool _initialized = false;
  bool _storeAvailable = false;
  bool _premium = false;
  bool _adsReady = false;
  bool _privacyOptionsRequired = false;

  bool get isPremium => _premium;
  bool get storeAvailable => _storeAvailable;
  bool get adsReady => _adsReady && !_premium;
  bool get privacyOptionsRequired => _privacyOptionsRequired;
  ProductDetails? get premiumProduct => _premiumProduct;
  String get premiumPrice => _premiumProduct?.price ?? premiumPriceLabel;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );

    try {
      _storeAvailable = await _iap.isAvailable();

      if (_storeAvailable) {
        final response =
            await _iap.queryProductDetails(<String>{premiumProductId});
        for (final product in response.productDetails) {
          if (product.id == premiumProductId) {
            _premiumProduct = product;
            break;
          }
        }

        await _iap.restorePurchases();
      }
    } catch (_) {
      _storeAvailable = false;
    }

    notifyListeners();

    if (!_premium) {
      await _prepareAds();
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      if (purchase.productID != premiumProductId) continue;

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _premium = true;
        _adsReady = false;
        notifyListeners();
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (_) {}
      }
    }
  }

  Future<bool> buyPremium() async {
    if (!_storeAvailable || _premiumProduct == null) {
      await _refreshProduct();
    }

    final product = _premiumProduct;
    if (product == null) return false;

    try {
      return await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> restorePremium() async {
    try {
      _storeAvailable = await _iap.isAvailable();
      if (_storeAvailable) {
        await _iap.restorePurchases();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _refreshProduct() async {
    try {
      _storeAvailable = await _iap.isAvailable();
      if (!_storeAvailable) return;

      final response =
          await _iap.queryProductDetails(<String>{premiumProductId});
      for (final product in response.productDetails) {
        if (product.id == premiumProductId) {
          _premiumProduct = product;
          break;
        }
      }
    } catch (_) {}
  }

  Future<void> _prepareAds() async {
    final completer = Completer<void>();

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        const ConsentRequestParameters(),
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});

            final privacyStatus = await ConsentInformation.instance
                .getPrivacyOptionsRequirementStatus();
            _privacyOptionsRequired =
                privacyStatus == PrivacyOptionsRequirementStatus.required;

            final canRequestAds =
                await ConsentInformation.instance.canRequestAds();
            if (canRequestAds && !_premium) {
              await MobileAds.instance.initialize();
              _adsReady = true;
            }
          } catch (_) {
            _adsReady = false;
          }

          notifyListeners();
          if (!completer.isCompleted) completer.complete();
        },
        (_) {
          _adsReady = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (_) {
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
  }

  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (_) {}
  }

  String get androidBannerAdUnitId => _androidBannerId;

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}

class UtiliaBannerAd extends StatefulWidget {
  const UtiliaBannerAd({
    super.key,
    required this.monetization,
  });

  final UtiliaMonetization monetization;

  @override
  State<UtiliaBannerAd> createState() => _UtiliaBannerAdState();
}

class _UtiliaBannerAdState extends State<UtiliaBannerAd> {
  BannerAd? _bannerAd;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    widget.monetization.addListener(_sync);
    _sync();
  }

  @override
  void didUpdateWidget(covariant UtiliaBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monetization == widget.monetization) return;

    oldWidget.monetization.removeListener(_sync);
    widget.monetization.addListener(_sync);
    _disposeAd();
    _sync();
  }

  void _sync() {
    if (!mounted) return;

    if (widget.monetization.isPremium) {
      _disposeAd();
      setState(() {});
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android ||
        !widget.monetization.adsReady ||
        _bannerAd != null ||
        _loading) {
      return;
    }

    _loading = true;
    final ad = BannerAd(
      adUnitId: widget.monetization.androidBannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _loading = false;
          });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) {
            setState(() => _loading = false);
          }
        },
      ),
    );
    ad.load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _loading = false;
  }

  @override
  void dispose() {
    widget.monetization.removeListener(_sync);
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monetization.isPremium || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: AdSize.banner.height.toDouble(),
      width: double.infinity,
      child: Center(child: AdWidget(ad: _bannerAd!)),
    );
  }
}
