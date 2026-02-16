import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Safely show a GetX snackbar, catching the "No Overlay widget found" error
/// that can occur during widget tree transitions or early initialization.
void showSafeSnackbar({
  required String title,
  required String message,
  SnackPosition snackPosition = SnackPosition.BOTTOM,
  Duration duration = const Duration(seconds: 3),
}) {
  // Defer to next frame to ensure overlay is ready
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Check if GetX's context/overlay is ready
    if (Get.context == null) {
      debugPrint('⚠️ Skipping snackbar (no context): $title - $message');
      return;
    }

    // Extra safety: check if overlay actually exists
    final overlayState = Overlay.maybeOf(Get.context!);
    if (overlayState == null) {
      debugPrint('⚠️ Skipping snackbar (no overlay): $title - $message');
      return;
    }

    try {
      // Close any existing snackbar first
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      Get.snackbar(
        title,
        message,
        snackPosition: snackPosition,
        duration: duration,
        backgroundColor: const Color(0xFF1E1E2E).withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        icon: Icon(
          title.toLowerCase().contains('internet') ||
                  title.toLowerCase().contains('offline')
              ? Icons.wifi_off_rounded
              : Icons.info_outline_rounded,
          color: Colors.white70,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Could not show snackbar: $e');
    }
  });
}
