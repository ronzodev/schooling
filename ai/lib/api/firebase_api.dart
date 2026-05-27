import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../pages/notifications_screen.dart'; // The in-app inbox screen we created earlier
import '../controllers/notifications_controller.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    // Requesting permission from the user (Required for iOS and Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        'User granted push notification permission: ${settings.authorizationStatus}');

    // Fetch the FCM token
    try {
      final fCMToken = await _firebaseMessaging.getToken();
      if (fCMToken != null) {
        debugPrint('====================================');
        debugPrint('FCM Token: $fCMToken');
        debugPrint('====================================');
        // You can copy this token from the debug console to test sending
        // a message directly to this specific device from the Firebase Console.
      }
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token Refreshed: $newToken');
      // Update the token on your server if necessary
    });
  }

  // The user just wants the notification to open the app, no automatic navigation.
  // We completely removed handleMessage to prevent any contextless navigation issues.

  Future<void> initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Safely get or inject the controller to prevent "not found" crashes on app startup
        final controller = Get.isRegistered<NotificationsController>() 
            ? NotificationsController.instance 
            : Get.put(NotificationsController(), permanent: true);
        controller.saveIncomingMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final controller = Get.isRegistered<NotificationsController>() 
            ? NotificationsController.instance 
            : Get.put(NotificationsController(), permanent: true);
      controller.saveIncomingMessage(message);
    });

    FirebaseMessaging.onMessage.listen((message) {
      final controller = Get.isRegistered<NotificationsController>() 
            ? NotificationsController.instance 
            : Get.put(NotificationsController(), permanent: true);
      controller.saveIncomingMessage(message);
    });
  }
}
