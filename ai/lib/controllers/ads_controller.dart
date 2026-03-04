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
      'ca-app-pub-3940256099942544/6300978111';

  // Ad Unit IDs (iOS)
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-9049620363523701/9845581606';
  static const String _iosBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  // Getters for current platform
  String get _interstitialAdUnitId => Platform.isAndroid
      ? _androidInterstitialAdUnitId
      : _iosInterstitialAdUnitId;

  String get _bannerAdUnitId =>
      Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;

  // Ad instances
  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;

  // Observable to trigger UI updates when ads change
  final adUpdateTrigger = 0.obs;

  // Loading states
  bool _isInterstitialLoading = false;
  bool _isBannerLoading = false;

  // Cached states for offline usage
  bool _hasInterstitialCached = false;
  bool _hasBannerCached = false;

  // Callbacks
  VoidCallback? onInterstitialClosed;
  VoidCallback? onInterstitialFailed;

  /// Initialize the ads controller
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('⚠️ MobileAds initialization failed: $e');
    }

    // Pre-load ads for better performance (non-blocking)
    try {
      await Future.wait([
        loadInterstitialAd(),
        loadBannerAd(),
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
          // Network lost — dispose banner since it can show WebView errors
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
        onInterstitialClosed?.call();
        loadInterstitialAd();
      }
    } catch (e) {
      debugPrint('❌ Error showing interstitial ad: $e');
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
    };
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

    _interstitialAd = null;
    _bannerAd = null;

    _hasInterstitialCached = false;
    _hasBannerCached = false;

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
    await Future.delayed(const Duration(seconds: 2));

    try {
      if (!_hasInterstitialCached && !_isInterstitialLoading) {
        loadInterstitialAd();
      }
      if (!_hasBannerCached && !_isBannerLoading) loadBannerAd();
    } catch (e) {
      debugPrint('⚠️ Error reloading ads on reconnect: $e');
    }
  }
}
