import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playx_version_update/playx_version_update.dart';
import 'dart:io';

class UpdateController extends GetxController with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onReady() {
    super.onReady();
    // Delay slightly to ensure Get.context is stable and any navigation is finished
    Future.delayed(const Duration(seconds: 3), () {
      checkForUpdate();
    });
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfPendingFlexibleUpdate();
    }
  }

  /// Checks for app updates and shows the appropriate dialog
  Future<void> checkForUpdate() async {
    // playx_version_update currently supports Android and iOS only
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint(
          'UpdateController: Platform not supported for in-app updates.');
      return;
    }

    final context = Get.context;
    if (context == null) {
      debugPrint(
          'UpdateController: Context is null, cannot show update dialog.');
      return;
    }

    debugPrint('UpdateController: Checking for app updates...');

    try {
      // We use showInAppUpdateDialog for a more integrated experience.
      // On Android, it uses Google Play In-App Updates (Immediate or Flexible).
      // On iOS, it shows a customizable Flutter UI.
      final result = await PlayxVersionUpdate.showInAppUpdateDialog(
        context: context,
        // Using flexible for non-critical updates by default.
        type: PlayxAppUpdateType.flexible,
        iosOptions: const PlayxUpdateOptions(),
        iosUiOptions: PlayxUpdateUIOptions(
          showReleaseNotes: true,
          title: (info) => 'A New Update is Available!',
          description: (info) =>
              'Version ${info.newVersion} is now available. Please update to get the latest features.',
          updateButtonText: 'Update Now',
          dismissButtonText: 'Later',
        ),
      );

      result.when(
        success: (isShown) {
          if (isShown) {
            debugPrint('UpdateController: Update dialog/flow initiated.');
          } else {
            debugPrint(
                'UpdateController: No update needed or dialog not shown.');
          }
        },
        error: (error) {
          debugPrint(
              'UpdateController: Error during update check: ${error.message}');
        },
      );
    } catch (e) {
      debugPrint('UpdateController: Unexpected error checking for update: $e');
    }
  }

  /// Checks if a flexible update has been downloaded and is waiting to be installed.
  Future<void> _checkIfPendingFlexibleUpdate() async {
    if (Platform.isAndroid) {
      final result =
          await PlayxVersionUpdate.isFlexibleUpdateNeedToBeInstalled();
      result.when(
        success: (isNeeded) {
          if (isNeeded) {
            debugPrint(
                'UpdateController: A flexible update is ready to install on app resume!');
            // We could show a Snackbar or a dialog here to complete the update.
            // For now, we'll re-trigger the main update check which should handle the state.
            checkForUpdate();
          }
        },
        error: (error) => debugPrint(
            'UpdateController: Error checking for pending flexible update: ${error.message}'),
      );
    }
  }
}
