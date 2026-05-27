import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Enhanced NetworkController — tracks both interface connectivity AND real
/// internet reachability by probing a known host.
///
/// `isConnected`        → network interface is active (from connectivity_plus)
/// `isInternetReachable` → a real HTTP probe succeeded (confirms actual internet)
/// `isOnline`           → true only when BOTH are true
///
/// Use [isOnline] for any decision that requires confirmed internet access
/// (e.g. loading ads, fetching data). The [NetworkBannerWrapper] shows the
/// offline banner whenever [isOnline] is false.
class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  /// True when a network interface is active (Wi-Fi, mobile, etc.)
  final RxBool isConnected = true.obs;

  /// True when a real internet probe confirms actual internet access.
  /// This catches captive portals, weak signals, and offline-while-"connected"
  /// scenarios that connectivity_plus misses.
  final RxBool isInternetReachable = true.obs;

  /// Combined: interface active AND internet reachable.
  bool get isOnline => isConnected.value && isInternetReachable.value;

  /// Brief "back online" flag — true for 3 seconds after reconnecting
  final RxBool showBackOnline = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicProbeTimer;

  /// Probe target — lightweight, reliable hosts.
  static const List<String> _probeHosts = [
    'clients3.google.com',
    '1.1.1.1',
    '8.8.8.8',
  ];

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    // Periodically probe every 30 seconds to catch captive portals / signal
    // drops that connectivity_plus won't detect.
    _periodicProbeTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _probeInternet(),
    );
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInterface = !results.contains(ConnectivityResult.none);
      isConnected.value = hasInterface;
      if (hasInterface) {
        await _probeInternet();
      } else {
        isInternetReachable.value = false;
      }
    } catch (e) {
      debugPrint('⚠️ Initial connectivity check failed: $e');
      // Be optimistic on error so we don't block the UI unnecessarily
      isConnected.value = true;
      await _probeInternet();
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasInterface = !results.contains(ConnectivityResult.none);
    final wasOnline = isOnline;
    isConnected.value = hasInterface;

    if (!hasInterface) {
      // No interface → definitely no internet
      isInternetReachable.value = false;
    } else {
      // Interface is up — probe to confirm real internet
      await _probeInternet();
    }

    final nowOnline = isOnline;

    if (nowOnline && !wasOnline) {
      // Show "Back Online" briefly
      showBackOnline.value = true;
      Future.delayed(const Duration(seconds: 3), () {
        showBackOnline.value = false;
      });
    }
  }

  /// Attempt a real internet probe by doing a socket connection to known hosts.
  /// Uses a 5-second timeout and tries multiple hosts for reliability.
  Future<void> _probeInternet() async {
    bool reachable = false;
    for (final host in _probeHosts) {
      try {
        final socket = await Socket.connect(
          host,
          80,
          timeout: const Duration(seconds: 5),
        );
        socket.destroy();
        reachable = true;
        break; // One success is enough
      } on SocketException {
        // Try next host
      } catch (_) {
        // Try next host
      }
    }

    final wasOnline = isOnline;
    isInternetReachable.value = reachable;

    if (reachable && !wasOnline && isConnected.value) {
      // We just confirmed internet is reachable after being offline
      showBackOnline.value = true;
      Future.delayed(const Duration(seconds: 3), () {
        showBackOnline.value = false;
      });
    }

    debugPrint(
        '🌐 Internet probe: ${reachable ? "✅ reachable" : "❌ unreachable"}');
  }

  /// Manual check — call this to get the current online status (also updates
  /// the observable values).
  Future<bool> checkConnection() async {
    final results = await _connectivity.checkConnectivity();
    final hasInterface = !results.contains(ConnectivityResult.none);
    isConnected.value = hasInterface;
    if (hasInterface) {
      await _probeInternet();
    } else {
      isInternetReachable.value = false;
    }
    return isOnline;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _periodicProbeTimer?.cancel();
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

          // Offline banner — shown when truly offline (interface OR internet check)
          Obx(() {
            if (!controller.isConnected.value ||
                !controller.isInternetReachable.value) {
              return Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: Center(
                  child: _OfflineBanner(
                    noInterface: !controller.isConnected.value,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // "Back Online" banner
          Obx(() {
            if (controller.showBackOnline.value) {
              return Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 0,
                right: 0,
                child: Center(child: _OnlineBanner()),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatefulWidget {
  final bool noInterface;
  const _OfflineBanner({this.noInterface = true});

  @override
  State<_OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<_OfflineBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE53935).withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _OnlineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF43A047).withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF43A047).withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
