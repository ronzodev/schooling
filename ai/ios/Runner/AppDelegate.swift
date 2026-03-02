import Flutter
import UIKit
import GoogleMobileAds

@objc class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
    let nativeAdView = Bundle.main.loadNibNamed(
            "NativeAdView",
            owner: nil,
            options: nil)?.first as! GADNativeAdView

    nativeAdView.nativeAd = nativeAd;

    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
    
    if let bodyView = nativeAdView.bodyView as? UILabel {
      bodyView.text = nativeAd.body
      bodyView.isHidden = nativeAd.body == nil
    }

    if let iconView = nativeAdView.iconView as? UIImageView {
        iconView.image = nativeAd.icon?.image
        iconView.isHidden = nativeAd.icon == nil
    }

    if let advertiserView = nativeAdView.advertiserView as? UILabel {
        advertiserView.text = nativeAd.advertiser
        advertiserView.isHidden = nativeAd.advertiser == nil
    }

    if let callToActionView = nativeAdView.callToActionView as? UIButton {
        callToActionView.setTitle(nativeAd.callToAction, for: .normal)
        callToActionView.isHidden = nativeAd.callToAction == nil
        callToActionView.isUserInteractionEnabled = false
    }

    nativeAdView.callToActionView?.isUserInteractionEnabled = false
    nativeAdView.nativeAd = nativeAd

    return nativeAdView
  }
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(self, factoryId: "listTile", nativeAdFactory: ListTileNativeAdFactory())
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
