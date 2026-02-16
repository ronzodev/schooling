import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Simplified NetworkController — only tracks connectivity state.
/// No snackbars, no overlays. The UI is handled by [NetworkBannerWrapper].
class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;

  /// Brief "back online" flag — true for 3 seconds after reconnecting
  final RxBool showBackOnline = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      isConnected.value = !results.contains(ConnectivityResult.none);
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final connected = !results.contains(ConnectivityResult.none);
    final wasConnected = isConnected.value;
    isConnected.value = connected;

    if (connected && !wasConnected) {
      // Show "Back Online" briefly
      showBackOnline.value = true;
      Future.delayed(const Duration(seconds: 3), () {
        showBackOnline.value = false;
      });
    }
  }

  /// Check if device is currently online
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    final connected = !results.contains(ConnectivityResult.none);
    isConnected.value = connected;
    return connected;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

/// A wrapper widget that shows a network status banner at the top of ANY screen.
/// Place this in GetMaterialApp.builder so it wraps the entire app.
class NetworkBannerWrapper extends StatelessWidget {
  final Widget child;
  const NetworkBannerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Lazily register the controller so it lives for the entire app lifetime
    final controller = Get.put(NetworkController(), permanent: true);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // The actual app content
          child,

          // Offline banner
          Obx(() {
            if (!controller.isConnected.value) {
              return Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: _OfflineBanner(),
              );
            }
            return const SizedBox.shrink();
          }),

          // "Back Online" banner
          Obx(() {
            if (controller.showBackOnline.value) {
              return Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: _OnlineBanner(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Please check your network settings',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF43A047).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_rounded, color: Colors.white, size: 22),
          SizedBox(width: 12),
          Text(
            'Back Online',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
