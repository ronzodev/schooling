import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import '../widgets/safe_ad_widget.dart';

class GoogleAdsController {
  static GoogleAdsController? _instance;
  static GoogleAdsController get instance =>
      _instance ??= GoogleAdsController._internal();

  GoogleAdsController._internal();

  // Ad Unit IDs (Android - Real)
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-9049620363523701/1707308928';
  static const String _androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Test ID for now, replace if you have real one
  static const String _androidNativeAdUnitId =
      'ca-app-pub-9049620363523701/8454585993';

  // Ad Unit IDs (iOS - Test IDs)
  // TODO: Replace with your actual iOS Ad Unit IDs
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-9049620363523701/9845581606';
  static const String _iosBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _iosNativeAdUnitId =
      'ca-app-pub-9049620363523701/4424075409';

  // Getters for current platform
  String get _interstitialAdUnitId => Platform.isAndroid
      ? _androidInterstitialAdUnitId
      : _iosInterstitialAdUnitId;

  String get _bannerAdUnitId =>
      Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;

  String get _nativeAdUnitId =>
      Platform.isAndroid ? _androidNativeAdUnitId : _iosNativeAdUnitId;

  // Ad instances
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  final List<NativeAd?> _nativeAds = [];
  final int _maxNativeAds = 5; // Pre-load up to 5 native ads

  // Track which native ads are actually loaded successfully
  final Set<int> _loadedNativeAdIndices = {};

  // Observable to trigger UI updates when ads change
  final adUpdateTrigger = 0.obs;

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
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('⚠️ MobileAds initialization failed: $e');
      // Non-fatal — ads just won't work
    }

    // Pre-load all ads for better performance (non-blocking)
    try {
      await Future.wait([
        loadInterstitialAd(),
        loadBannerAd(),
        loadNativeAds(),
      ]);
    } catch (e) {
      debugPrint('⚠️ Ad preloading failed: $e');
    }

    // Listen for connectivity changes to reload/dispose ads
    try {
      Connectivity().onConnectivityChanged.listen((results) {
        if (!results.contains(ConnectivityResult.none)) {
          reloadAdsOnReconnect();
        } else {
          // Network lost — dispose all native ads to prevent
          // "web page not available" WebView errors
          _disposeAllNativeAds();
          // Also dispose banner since it can show WebView errors
          disposeBannerAd();
        }
      });
    } catch (e) {
      debugPrint('⚠️ Connectivity listener setup failed: $e');
    }
  }

  // ==================== INTERSTITIAL AD METHODS ====================

  /// Load interstitial ad with offline caching support
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialLoading) return;

    // Check network before attempting to load
    if (!await _hasNetwork()) {
      debugPrint('⚠️ No network - skipping interstitial ad load');
      return;
    }

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
        try {
          ad.dispose();
        } catch (e) {
          debugPrint('⚠️ Error disposing interstitial: $e');
        }
        _interstitialAd = null;
        _hasInterstitialCached = false;
        debugPrint('📱 Interstitial ad dismissed');
        onInterstitialClosed?.call();
        // Pre-load next ad
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        try {
          ad.dispose();
        } catch (e) {
          debugPrint('⚠️ Error disposing failed interstitial: $e');
        }
        _interstitialAd = null;
        _hasInterstitialCached = false;
        debugPrint('❌ Interstitial ad failed to show: $error');
        onInterstitialFailed?.call();
        // Pre-load next ad
        loadInterstitialAd();
      },
    );
  }

  /// Show interstitial ad — safe to call anytime, never throws
  void showInterstitialAd() {
    try {
      if (_interstitialAd != null && _hasInterstitialCached) {
        _interstitialAd!.show();
        debugPrint('🎯 Showing interstitial ad');
      } else {
        debugPrint('⚠️ Interstitial ad not ready - continuing app flow');
        // Call the closed callback so app flow continues uninterrupted
        onInterstitialClosed?.call();
        loadInterstitialAd();
      }
    } catch (e) {
      debugPrint('❌ Error showing interstitial ad: $e');
      // Ensure app flow continues even on error
      _interstitialAd = null;
      _hasInterstitialCached = false;
      onInterstitialClosed?.call();
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

    // Check network before attempting to load
    if (!await _hasNetwork()) {
      debugPrint('⚠️ No network - skipping banner ad load');
      return;
    }

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
            try {
              ad.dispose();
            } catch (e) {
              debugPrint('⚠️ Error disposing failed banner: $e');
            }
            _bannerAd = null;
            _isBannerLoading = false;
            debugPrint('❌ Banner ad failed to load: $error');
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
      _bannerAd = null;
      debugPrint('❌ Banner ad loading error: $e');
    }
  }

  /// Get banner ad widget — returns null if not ready
  Widget? getBannerAdWidget() {
    try {
      if (_bannerAd != null && _hasBannerCached) {
        return SafeAdWidget(
          ad: _bannerAd!,
          height: _bannerAd!.size.height.toDouble(),
          width: _bannerAd!.size.width.toDouble(),
        );
      }
    } catch (e) {
      debugPrint('❌ Error getting banner ad widget: $e');
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
    try {
      _bannerAd?.dispose();
    } catch (e) {
      debugPrint('⚠️ Error disposing banner ad: $e');
    }
    _bannerAd = null;
    _hasBannerCached = false;
  }

  // ==================== UTILITY METHODS ====================

  /// Preload all ads for better performance
  Future<void> preloadAllAds() async {
    debugPrint('🔄 Preloading all ads...');
    try {
      await Future.wait([
        if (!_hasInterstitialCached) loadInterstitialAd(),
        if (!_hasBannerCached) loadBannerAd(),
        if (_nativeAdsCached < _maxNativeAds) loadNativeAds(),
      ]);
    } catch (e) {
      debugPrint('⚠️ Error preloading ads: $e');
    }
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

    // Check network before attempting to load
    if (!await _hasNetwork()) {
      debugPrint('⚠️ No network - skipping native ad load');
      return;
    }

    _isNativeAdLoading = true;
    debugPrint('🔄 Loading native ads...');

    try {
      // Load up to max native ads
      for (int i = 0; i < _maxNativeAds; i++) {
        await _loadSingleNativeAd(i);
      }
    } catch (e) {
      debugPrint('❌ Error in native ad batch loading: $e');
    }

    _isNativeAdLoading = false;
  }

  /// Load a single native ad
  Future<void> _loadSingleNativeAd(int index) async {
    try {
      final nativeAd = NativeAd(
        adUnitId: _nativeAdUnitId,
        listener: NativeAdListener(
          onAdLoaded: (Ad ad) {
            _nativeAdsCached++;
            _loadedNativeAdIndices.add(index);
            debugPrint(
                '✅ Native ad loaded (${_nativeAdsCached}/$_maxNativeAds)');
            adUpdateTrigger.value++; // Notify UI
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            try {
              ad.dispose();
            } catch (e) {
              debugPrint('⚠️ Error disposing failed native ad: $e');
            }
            _loadedNativeAdIndices.remove(index);
            debugPrint('❌ Native ad failed to load: $error');
            adUpdateTrigger.value++; // Notify UI
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

      // Ensure list is big enough
      while (_nativeAds.length <= index) {
        _nativeAds.add(null);
      }
      _nativeAds[index] = nativeAd;
    } catch (e) {
      debugPrint('❌ Native ad loading error: $e');
    }
  }

  /// Get a native ad widget for list integration — safe, never throws
  Widget? getNativeAdWidget({
    required double width,
    double height = 320,
    required int adIndex, // Unique index for this ad position
  }) {
    try {
      // Safety check for empty list
      if (_nativeAds.isEmpty || _loadedNativeAdIndices.isEmpty) return null;

      // Calculate which ad to use based on index
      final adIndexToUse = adIndex % _nativeAds.length;

      // Safety check for bounds, null, and loaded state
      if (adIndexToUse >= _nativeAds.length) return null;
      if (!_loadedNativeAdIndices.contains(adIndexToUse)) return null;

      final ad = _nativeAds[adIndexToUse];
      if (ad == null) return null;

      // Return the ad widget wrapped in SafeAdWidget for error protection
      return SizedBox(
        key: ValueKey('native_container_$adIndex'),
        width: width,
        height: height,
        child: SafeAdWidget(
          key: ValueKey('native_ad_widget_$adIndex'),
          ad: ad,
          width: width,
          height: height,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error getting native ad widget: $e');
      return null;
    }
  }

  /// Check if native ads are available
  bool hasNativeAds() => _loadedNativeAdIndices.isNotEmpty;

  /// Get number of loaded native ads
  int getNativeAdCount() => _loadedNativeAdIndices.length;

  /// Dispose a specific native ad by index and load a new one
  Future<void> refreshNativeAdAtIndex(int index) async {
    try {
      if (index < _nativeAds.length && _nativeAds[index] != null) {
        try {
          _nativeAds[index]?.dispose();
        } catch (e) {
          debugPrint('⚠️ Error disposing native ad at index $index: $e');
        }
        _nativeAds[index] = null;
        _loadedNativeAdIndices.remove(index);
        _nativeAdsCached--;
        await _loadSingleNativeAd(index);
      }
    } catch (e) {
      debugPrint('❌ Error refreshing native ad: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Dispose all native ads (called when network drops to prevent WebView errors)
  void _disposeAllNativeAds() {
    debugPrint('🗑️ Disposing all native ads (network lost)');
    for (var ad in _nativeAds) {
      try {
        ad?.dispose();
      } catch (e) {
        debugPrint('⚠️ Error disposing native ad: $e');
      }
    }
    _nativeAds.clear();
    _loadedNativeAdIndices.clear();
    _nativeAdsCached = 0;
    _isNativeAdLoading = false;
    adUpdateTrigger.value++; // Notify UI
  }

  /// Dispose all ads and clean up resources
  void dispose() {
    try {
      _interstitialAd?.dispose();
    } catch (e) {
      debugPrint('⚠️ Error disposing interstitial: $e');
    }

    try {
      _bannerAd?.dispose();
    } catch (e) {
      debugPrint('⚠️ Error disposing banner: $e');
    }

    // Dispose all native ads
    for (var ad in _nativeAds) {
      try {
        ad?.dispose();
      } catch (e) {
        debugPrint('⚠️ Error disposing native ad: $e');
      }
    }
    _nativeAds.clear();
    _loadedNativeAdIndices.clear();

    _interstitialAd = null;
    _bannerAd = null;

    _hasInterstitialCached = false;
    _hasBannerCached = false;
    _nativeAdsCached = 0;

    debugPrint('🗑️ All ads disposed');
  }

  // ==================== NETWORK HELPER ====================

  /// Check if device has network connectivity
  Future<bool> _hasNetwork() async {
    try {
      final results = await Connectivity().checkConnectivity();
      return !results.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
      return false;
    }
  }

  /// Reload all ads (called when connectivity is restored)
  Future<void> reloadAdsOnReconnect() async {
    debugPrint('🔄 Network restored - reloading ads...');
    // Add small delay to ensure connection is stable
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Only reload what's missing
      if (!_hasInterstitialCached && !_isInterstitialLoading) {
        loadInterstitialAd();
      }
      if (!_hasBannerCached && !_isBannerLoading) loadBannerAd();
      if (_nativeAdsCached < _maxNativeAds && !_isNativeAdLoading) {
        loadNativeAds();
      }
    } catch (e) {
      debugPrint('⚠️ Error reloading ads on reconnect: $e');
    }
  }
}
