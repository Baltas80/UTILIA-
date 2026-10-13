import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class UtiliaMonetization extends ChangeNotifier {
  static const noAdsProductId = 'utilia_no_ads';
  static const monthlyProductId = 'utilia_premium_monthly';
  static const annualProductId = 'utilia_premium_annual';

  // Kept for users who bought the old one-time Premium product.
  static const legacyPremiumProductId = 'utilia_premium';

  static const noAdsPriceLabel = '2,99 €';
  static const testAndroidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const _androidBannerId = String.fromEnvironment(
    'UTILIA_ADMOB_ANDROID_BANNER_ID',
  );
  static const _androidInterstitialId = String.fromEnvironment(
    'UTILIA_ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _interstitialCooldown = Duration(minutes: 10);

  static const _productIds = <String>{
    noAdsProductId,
    monthlyProductId,
    annualProductId,
    legacyPremiumProductId,
  };

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  ProductDetails? _noAdsProduct;
  ProductDetails? _monthlyProduct;
  ProductDetails? _annualProduct;

  InterstitialAd? _interstitialAd;
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _noAdsOwned = false;
  bool _monthlyOwned = false;
  bool _annualOwned = false;
  bool _legacyPremiumOwned = false;
  bool _adsReady = false;
  bool _privacyOptionsRequired = false;
  bool _interstitialLoading = false;
  DateTime? _lastInterstitialShownAt;

  bool get isPremium =>
      _noAdsOwned ||
      _monthlyOwned ||
      _annualOwned ||
      _legacyPremiumOwned;

  bool get isNoAds => _noAdsOwned || _legacyPremiumOwned;
  bool get isMonthly => _monthlyOwned;
  bool get isAnnual => _annualOwned;
  bool get hasSubscription => _monthlyOwned || _annualOwned;
  bool get storeAvailable => _storeAvailable;
  bool get adsReady => _adsReady && !isPremium;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  ProductDetails? get noAdsProduct => _noAdsProduct;
  ProductDetails? get monthlyProduct => _monthlyProduct;
  ProductDetails? get annualProduct => _annualProduct;

  String get noAdsPrice => _noAdsProduct?.price ?? noAdsPriceLabel;
  String get monthlyPrice => _monthlyProduct?.price ?? '—';
  String get annualPrice => _annualProduct?.price ?? '—';

  String get premiumSummary {
    if (isNoAds) return 'Sin anuncios para siempre · 2,99 €';
    if (isMonthly) return 'Premium mensual · activo';
    if (isAnnual) return 'Premium anual · activo';
    return 'Premium mensual · anual · No Ads';
  }

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
        await _refreshProducts();
        await _iap.restorePurchases();
      }
    } catch (_) {
      _storeAvailable = false;
    }

    notifyListeners();

    if (!isPremium) {
      await _prepareAds();
    }
  }

  Future<void> _refreshProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'UTILIA IAP: Google Play did not return product IDs: ${response.notFoundIDs.join(', ')}',
      );
    }
    if (response.error != null) {
      debugPrint('UTILIA IAP: product query failed: ${response.error!.code}');
    }
    for (final product in response.productDetails) {
      switch (product.id) {
        case noAdsProductId:
          _noAdsProduct = product;
          break;
        case monthlyProductId:
          _monthlyProduct = product;
          break;
        case annualProductId:
          _annualProduct = product;
          break;
      }
    }
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.productID) {
        case noAdsProductId:
          _noAdsOwned = _isEntitled(purchase);
          break;
        case monthlyProductId:
          _monthlyOwned = _isEntitled(purchase);
          break;
        case annualProductId:
          _annualOwned = _isEntitled(purchase);
          break;
        case legacyPremiumProductId:
          _legacyPremiumOwned = _isEntitled(purchase);
          break;
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (_) {}
      }
    }

    if (isPremium) {
      _disposeInterstitial();
    }
    notifyListeners();

    if (!isPremium && _initialized) {
      await _prepareAds();
    }
  }

  bool _isEntitled(PurchaseDetails purchase) =>
      purchase.status == PurchaseStatus.purchased ||
      purchase.status == PurchaseStatus.restored;

  Future<bool> buyNoAds() => _buy(noAdsProductId, () => _noAdsProduct);
  Future<bool> buyMonthly() => _buy(monthlyProductId, () => _monthlyProduct);
  Future<bool> buyAnnual() => _buy(annualProductId, () => _annualProduct);

  Future<bool> _buy(
    String productId,
    ProductDetails? Function() getter,
  ) async {
    if (!_storeAvailable || getter() == null) {
      await _refreshStore();
    }

    final selected = getter();
    if (selected == null) {
      debugPrint(
        'UTILIA IAP: cannot start purchase; Google Play did not return "$productId". Store available: $_storeAvailable.',
      );
      return false;
    }

    try {
      final started = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: selected),
      );
      if (!started) {
        debugPrint('UTILIA IAP: Google Play did not start purchase "$productId".');
      }
      return started;
    } catch (error) {
      debugPrint('UTILIA IAP: failed to launch "$productId": $error');
      return false;
    }
  }

  Future<void> _refreshStore() async {
    try {
      _storeAvailable = await _iap.isAvailable();
      if (_storeAvailable) {
        await _refreshProducts();
      }
    } catch (_) {}
    notifyListeners();
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
            if (canRequestAds && !isPremium) {
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
        (_) async {
          // A consent-info refresh can fail transiently. UMP may still have a
          // valid prior consent state, so check whether ads can legally be
          // requested before disabling ads for the whole session.
          try {
            final canRequestAds =
                await ConsentInformation.instance.canRequestAds();
            if (canRequestAds && !isPremium) {
              await MobileAds.instance.initialize();
              _adsReady = true;
              _loadInterstitial();
            } else {
              _adsReady = false;
            }
          } catch (_) {
            _adsReady = false;
          }
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
    if (isPremium ||
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
    if (isPremium ||
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
  int _retryAttempt = 0;
  Timer? _retryTimer;

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
      _retryTimer?.cancel();
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
      _scheduleBannerRetry();
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
            _retryAttempt = 0;
            _retryTimer?.cancel();
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() => _loading = false);
          }
          debugPrint('UTILIA banner load failed: ${error.code} ${error.message}');
          _scheduleBannerRetry();
        },
      ),
    );
    ad.load();
  }

  void _scheduleBannerRetry() {
    if (!mounted || widget.monetization.isPremium || !widget.monetization.adsReady) {
      return;
    }
    _retryTimer?.cancel();
    final seconds = [5, 15, 30, 60][_retryAttempt.clamp(0, 3)];
    _retryAttempt++;
    _retryTimer = Timer(Duration(seconds: seconds), () {
      if (mounted && _bannerAd == null && !_loading) _sync();
    });
  }

  void _disposeAd() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerSize = null;
    _loading = false;
  }

  @override
  void dispose() {
    widget.monetization.removeListener(_sync);
    _retryTimer?.cancel();
    _disposeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monetization.isPremium ||
        defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }

    // Keep a stable bottom slot while the banner loads or retries. The slot
    // is not an ad and collapses for Premium users.
    final height = _bannerSize?.height.toDouble() ?? 60.0;
    final ad = _bannerAd;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ad == null ? const SizedBox.shrink() : Center(child: AdWidget(ad: ad)),
    );
  }
}
