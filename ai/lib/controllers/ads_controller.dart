import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAdsController {
  static GoogleAdsController? _instance;
  static GoogleAdsController get instance =>
      _instance ??= GoogleAdsController._internal();

  GoogleAdsController._internal();

  // Ad Unit IDs - Replace with your actual ad unit IDs
  // Ad Unit IDs - Replace with your actual ad unit IDs
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _nativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110'; // Test ID

// real ads
  // static const String _interstitialAdUnitId = 'ca-app-pub-9049620363523701/1707308928';

  // Ad instances
  // Ad instances
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  final List<NativeAd?> _nativeAds = [];
  final int _maxNativeAds = 5; // Pre-load up to 5 native ads

  // Loading states
  bool _isInterstitialLoading = false;
  bool _isBannerLoading = false;
  bool _isNativeAdLoading = false;

  // Cached states for offline usage
  bool _hasInterstitialCached = false;
  bool _hasBannerCached = false;
  int _nativeAdsCached = 0;

  // Callbacks
  VoidCallback? onInterstitialClosed;
  VoidCallback? onInterstitialFailed;

  /// Initialize the ads controller
  /// Initialize the ads controller
  Future<void> initialize() async {
    await MobileAds.instance.initialize();

    // Pre-load all ads for better performance
    await Future.wait([
      loadInterstitialAd(),
      loadBannerAd(),
      loadNativeAds(),
    ]);
  }

  // ==================== INTERSTITIAL AD METHODS ====================

  /// Load interstitial ad with offline caching support
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialLoading) return;

    _isInterstitialLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _hasInterstitialCached = true;
            _isInterstitialLoading = false;
            _setInterstitialCallbacks();
            debugPrint('✅ Interstitial ad loaded and cached');
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isInterstitialLoading = false;
            debugPrint('❌ Interstitial ad failed to load: $error');
            // Retry loading after a delay
            Future.delayed(const Duration(seconds: 30), () {
              loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      _isInterstitialLoading = false;
      debugPrint('❌ Interstitial ad loading error: $e');
    }
  }

  /// Set interstitial ad callbacks
  void _setInterstitialCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('🎯 Interstitial ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        _hasInterstitialCached = false;
        debugPrint('📱 Interstitial ad dismissed');
        onInterstitialClosed?.call();
        // Pre-load next ad
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        _hasInterstitialCached = false;
        debugPrint('❌ Interstitial ad failed to show: $error');
        onInterstitialFailed?.call();
        // Pre-load next ad
        loadInterstitialAd();
      },
    );
  }

  /// Show interstitial ad
  void showInterstitialAd() {
    if (_interstitialAd != null && _hasInterstitialCached) {
      _interstitialAd!.show();
      debugPrint('🎯 Showing interstitial ad');
    } else {
      debugPrint('⚠️ Interstitial ad not ready. Loading new ad...');
      loadInterstitialAd();
    }
  }

  /// Check if interstitial ad is ready to show
  bool isInterstitialReady() =>
      _interstitialAd != null && _hasInterstitialCached;

  // ==================== BANNER AD METHODS ====================

  /// Load banner ad with offline caching support
  Future<void> loadBannerAd() async {
    if (_isBannerLoading) return;

    _isBannerLoading = true;

    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            _hasBannerCached = true;
            _isBannerLoading = false;
            debugPrint('✅ Banner ad loaded and cached');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            _bannerAd = null;
            _isBannerLoading = false;
            debugPrint('❌ Banner ad failed to load: $error');
            // Retry loading after a delay
            Future.delayed(const Duration(seconds: 30), () {
              loadBannerAd();
            });
          },
          onAdOpened: (Ad ad) {
            debugPrint('🎯 Banner ad opened');
          },
          onAdClosed: (Ad ad) {
            debugPrint('📱 Banner ad closed');
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      _isBannerLoading = false;
      debugPrint('❌ Banner ad loading error: $e');
    }
  }

  /// Get banner ad widget
  Widget? getBannerAdWidget() {
    if (_bannerAd != null && _hasBannerCached) {
      return SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return null;
  }

  /// Check if banner ad is ready
  bool isBannerReady() => _bannerAd != null && _hasBannerCached;

  /// Refresh banner ad
  Future<void> refreshBannerAd() async {
    disposeBannerAd();
    await loadBannerAd();
  }

  /// Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _hasBannerCached = false;
  }

  // ==================== UTILITY METHODS ====================

  /// Preload all ads for better performance
  Future<void> preloadAllAds() async {
    debugPrint('🔄 Preloading all ads...');
    await Future.wait([
      if (!_hasInterstitialCached) loadInterstitialAd(),
      if (!_hasBannerCached) loadBannerAd(),
      if (_nativeAdsCached < _maxNativeAds) loadNativeAds(),
    ]);
  }

  /// Check if any ads are cached (useful for offline scenarios)
  bool hasAnyCachedAds() {
    return _hasInterstitialCached || _hasBannerCached;
  }

  /// Get ad status summary
  Map<String, dynamic> getAdStatus() {
    return {
      'interstitial': {
        'loaded': _hasInterstitialCached,
        'loading': _isInterstitialLoading,
      },
      'banner': {
        'loaded': _hasBannerCached,
        'loading': _isBannerLoading,
      },
      'native': {
        'loaded': _nativeAdsCached,
        'loading': _isNativeAdLoading,
        'available': hasNativeAds(),
      },
    };
  }

  // ==================== NATIVE AD METHODS ====================

  /// Load multiple native ads for list integration
  Future<void> loadNativeAds() async {
    if (_isNativeAdLoading) return;

    _isNativeAdLoading = true;
    debugPrint('🔄 Loading native ads...');

    // Load up to max native ads
    for (int i = 0; i < _maxNativeAds; i++) {
      await _loadSingleNativeAd();
    }

    _isNativeAdLoading = false;
  }

  /// Load a single native ad
  Future<void> _loadSingleNativeAd() async {
    try {
      final nativeAd = NativeAd(
        adUnitId: _nativeAdUnitId,
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            _nativeAdsCached++;
            debugPrint(
                '✅ Native ad loaded (${_nativeAdsCached}/$_maxNativeAds)');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            debugPrint('❌ Native ad failed to load: $error');
          },
          onAdOpened: (Ad ad) {
            debugPrint('🎯 Native ad opened');
          },
          onAdClosed: (Ad ad) {
            debugPrint('📱 Native ad closed');
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType:
              TemplateType.medium, // Switched to medium to fill topic container
          mainBackgroundColor: const Color(0xFF1E1E2E),
          cornerRadius: 16.0,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: const Color(0xFF5E81AC),
            style: NativeTemplateFontStyle.bold,
            size: 13.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFFECEFF4),
            style: NativeTemplateFontStyle.bold,
            size: 14.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFFD8DEE9),
            style: NativeTemplateFontStyle.normal,
            size: 13.0,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: const Color(0xFF88C0D0),
            style: NativeTemplateFontStyle.normal,
            size: 11.0,
          ),
        ),
      );

      await nativeAd.load();
      _nativeAds.add(nativeAd);
    } catch (e) {
      debugPrint('❌ Native ad loading error: $e');
    }
  }

  /// Get a native ad widget for list integration
  Widget? getNativeAdWidget({
    required double width,
    double height = 320,
    required int adIndex, // Unique index for this ad position
  }) {
    // Safety check for empty list
    if (_nativeAds.isEmpty) return null;

    // Calculate which ad to use based on index
    final adIndexToUse = adIndex % _nativeAds.length;

    // Safety check for bounds and null
    if (adIndexToUse >= _nativeAds.length) return null;

    final ad = _nativeAds[adIndexToUse];
    if (ad == null) return null;

    // Return just the ad widget - caller handles all styling
    // The key ensures Flutter treats this as a distinct widget position
    return SizedBox(
      key: ValueKey('native_container_$adIndex'),
      width: width,
      height: height,
      child: AdWidget(
        key: ValueKey('native_ad_widget_$adIndex'),
        ad: ad,
      ),
    );
  }

  /// Check if native ads are available
  bool hasNativeAds() => _nativeAds.any((ad) => ad != null);

  /// Get number of loaded native ads
  int getNativeAdCount() => _nativeAds.where((ad) => ad != null).length;

  /// Dispose a specific native ad by index and load a new one
  Future<void> refreshNativeAdAtIndex(int index) async {
    if (index < _nativeAds.length && _nativeAds[index] != null) {
      _nativeAds[index]?.dispose();
      _nativeAds[index] = null;
      _nativeAdsCached--;
      await _loadSingleNativeAd();
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Dispose all ads and clean up resources
  void dispose() {
    _interstitialAd?.dispose();
    _bannerAd?.dispose();

    // Dispose all native ads
    for (var ad in _nativeAds) {
      ad?.dispose();
    }
    _nativeAds.clear();

    _interstitialAd = null;
    _bannerAd = null;

    _hasInterstitialCached = false;
    _hasBannerCached = false;
    _nativeAdsCached = 0;

    debugPrint('🗑️ All ads disposed');
  }
}
