package com.ronzodev.solveit

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    
    companion object {
        private const val TAG = "MainActivity"
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d(TAG, "Configuring Flutter Engine")
        
        // Register the native ad factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, 
            "listTile", 
            ListTileNativeAdFactory(context)
        )
        
        Log.d(TAG, "Native ad factory 'listTile' registered")
        
        // Optional: Initialize Facebook Audience Network SDK
        // This is done automatically by the mediation adapter, but you can do it manually too
        try {
            val fbAdsClass = Class.forName("com.facebook.ads.AudienceNetworkAds")
            val initializeMethod = fbAdsClass.getMethod("initialize", android.content.Context::class.java)
            initializeMethod.invoke(null, context)
            Log.d(TAG, "✅ Facebook Audience Network initialized")
        } catch (e: Exception) {
            Log.e(TAG, "Facebook SDK not found or initialization failed: ${e.message}")
            // This is okay - the adapter will initialize it when needed
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        
        // Unregister the native ad factory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
        
        Log.d(TAG, "Native ad factory 'listTile' unregistered")
    }
}