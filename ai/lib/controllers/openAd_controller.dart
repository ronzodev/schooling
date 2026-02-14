// ignore: file_names
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppOpenController extends GetxController {
  // reall ad
  //  String adUnitId = 'ca-app-pub-9049620363523701/1731728226';

  //test ad

  String adUnitId = 'ca-app-pub-3940256099942544/9257395921';

  int _adCounter = 0;
  bool _isAdLoaded = false;
  AppOpenAd? _appOpenAd;

  // Initialize the controller, load ad, and check ad counter.
  @override
  void onInit() {
    super.onInit();
    _loadAd();
    _checkAdCounter();
  }

  // Load App Open Ad
  Future<void> _loadAd() async {
    const AdRequest request = AdRequest();
    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: request,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdLoaded = true;
          _checkAdCounter();
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
        },
      ),
    );
  }

  // Check and update ad counter
  Future<void> _checkAdCounter() async {
    final prefs = await SharedPreferences.getInstance();
    _adCounter = prefs.getInt('ad_counter') ?? 0;

    _adCounter++;
    // print('Addddddddddddddd counter$_adCounter');
    if (_adCounter >= 1 && _isAdLoaded) {
      // print('IS THE AD LOADED????? $_isAdLoaded');
      _showAd();
      _adCounter = 2;
    }

    await prefs.setInt('ad_counter', _adCounter);
  }

  // Show App Open Ad
  void _showAd() {
    _appOpenAd?.show();
  }

  @override
  void onClose() {
    _appOpenAd
        ?.dispose(); // Dispose the App Open Ad when the controller is closed.
    super.onClose();
  }
}
