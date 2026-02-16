import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A safe wrapper for [AdWidget].
/// It relies on the [AdsController] to only provide valid ads.
/// If an error occurs during build, it catches it and hides the widget.
class SafeAdWidget extends StatefulWidget {
  final AdWithView ad;
  final double? width;
  final double? height;

  const SafeAdWidget({
    super.key,
    required this.ad,
    this.width,
    this.height,
  });

  @override
  State<SafeAdWidget> createState() => _SafeAdWidgetState();
}

class _SafeAdWidgetState extends State<SafeAdWidget> {
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const SizedBox.shrink();
    }

    // Double-check ad validity (though controller should handle this)
    // We cannot easily check if ad is disposed, but we trust the controller.

    try {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: AdWidget(ad: widget.ad),
      );
    } catch (e) {
      debugPrint('🛡️ SafeAdWidget caught build error: $e');
      // If immediate build fails
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _hasError = true);
      });
      return const SizedBox.shrink();
    }
  }
}
