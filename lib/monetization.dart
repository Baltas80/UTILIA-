import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UtiliaMonetization extends ChangeNotifier {
  static const premiumProductId = 'utilia_premium';
  static const premiumPriceLabel = '2,99 €';

  static const testAndroidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _androidBannerId = String.fromEnvironment(
    'UTILIA_ADMOB_ANDROID_BANNER_ID',
  );
  static const _androidInterstitialId = String.fromEnvironment(
    'UTILIA_ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _interstitialCooldown = Duration(minutes: 10);

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _premiumProduct;
  InterstitialAd? _interstitialAd;

  bool _initialized = false;
  bool _storeAvailable = false;
  bool _premium = false;
  bool _adsReady = false;
  bool _privacyOptionsRequired = false;
  bool _interstitialLoading = false;
  DateTime? _lastInterstitialShownAt;

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
        _disposeInterstitial();
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
        ConsentRequestParameters(),
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
              _loadInterstitial();
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

  void _loadInterstitial() {
    if (_premium ||
        !_adsReady ||
        _androidInterstitialId.isEmpty ||
        _interstitialAd != null ||
        _interstitialLoading) {
      return;
    }

    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: _androidInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitialAd = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (_) {
          _interstitialLoading = false;
        },
      ),
    );
  }

  Future<void> showInterstitialIfEligible() async {
    if (_premium ||
        !_adsReady ||
        defaultTargetPlatform != TargetPlatform.android ||
        _androidInterstitialId.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final lastShown = _lastInterstitialShownAt;
    if (lastShown != null &&
        now.difference(lastShown) < _interstitialCooldown) {
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial();
      return;
    }

    _interstitialAd = null;
    _lastInterstitialShownAt = now;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  void _disposeInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialLoading = false;
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
    _disposeInterstitial();
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
  AdSize? _bannerSize;
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

  Future<void> _sync() async {
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

    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0) return;

    _loading = true;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) {
      _loading = false;
      return;
    }

    final ad = BannerAd(
      adUnitId: widget.monetization.androidBannerAdUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _bannerSize = size;
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
    _bannerSize = null;
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
    if (widget.monetization.isPremium ||
        _bannerAd == null ||
        _bannerSize == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _bannerSize!.height.toDouble(),
      width: double.infinity,
      child: Center(child: AdWidget(ad: _bannerAd!)),
    );
  }
}
