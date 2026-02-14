package com.ronzodev.solveit

import android.content.Context
import android.view.LayoutInflater
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class ListTileNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.list_tile_native_ad, null) as NativeAdView

        // Set the headline
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        // Set the body text
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = android.view.View.VISIBLE
            adView.bodyView = bodyView
        } else {
            bodyView.visibility = android.view.View.GONE
        }

        // Set the app icon
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = android.view.View.VISIBLE
            adView.iconView = iconView
        } else {
            iconView.visibility = android.view.View.GONE
        }

        // Set the call to action button
        val ctaView = adView.findViewById<Button>(R.id.ad_call_to_action)
        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = android.view.View.VISIBLE
            adView.callToActionView = ctaView
        } else {
            ctaView.visibility = android.view.View.GONE
        }

        // Set the advertiser (optional)
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        if (advertiserView != null) {
            if (nativeAd.advertiser != null) {
                advertiserView.text = nativeAd.advertiser
                advertiserView.visibility = android.view.View.VISIBLE
                adView.advertiserView = advertiserView
            } else {
                advertiserView.visibility = android.view.View.GONE
            }
        }

        // Register the native ad with the view
        adView.setNativeAd(nativeAd)

        return adView
    }
}