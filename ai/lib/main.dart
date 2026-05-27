import 'package:ai/controllers/ads_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show MobileAds;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'api/firebase_api.dart';

import 'controllers/openAd_controller.dart';
import 'controllers/update_controller.dart';
import 'controllers/network_controller.dart';
import 'controllers/saved_documents_controller.dart';
import 'controllers/notifications_controller.dart';
import 'controllers/review_contr.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'scripts/seed_app_content.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: EczFirebaseOptions.currentPlatform,
  );

  // Initialize GetStorage for the background isolate
  await GetStorage.init();

  // Save the incoming message to local storage
  final controller = Get.put(NotificationsController());
  await controller.saveIncomingMessage(message);

  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Lock app to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize default Firebase app (ECZ - the google-services.json is for ECZ)
  // This app is auto-initialized by google-services.json, so just ensure it exists
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: EczFirebaseOptions.currentPlatform,
    );
  }

  // Initialize secondary Firebase app (Pamphlet - for courses, topics, questions)
  // Check if 'pamphlet' app already exists
  try {
    Firebase.app('pamphlet');
  } catch (e) {
    // App doesn't exist, so initialize it
    await Firebase.initializeApp(
      name: 'pamphlet',
      options: PamphletFirebaseOptions.currentPlatform,
    );
  }

  // Set up Firebase Cloud Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final firebaseApi = FirebaseApi();
  await firebaseApi.initNotification();
  await firebaseApi.initPushNotifications();

  // Initialize ads controller
  final adsController = GoogleAdsController.instance;
  await adsController.initialize();
  // Seed app content collection (creates doc if it doesn't exist)
  await seedAppContent();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MobileAds.instance.initialize();
    Get.put(AppOpenController());
    Get.put(UpdateController(), permanent: true);
    Get.put(SavedDocumentsController(), permanent: true);
    Get.put(NotificationsController(), permanent: true);
    Get.put(NotificationsController());
    Get.put(AppReviewController(), permanent: true);
    // Check session-based review trigger for returning engaged users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppReviewController.instance.onAppSession();
      } catch (_) {}
    });

    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Past Paper Solutions',
        theme: ThemeData(primarySwatch: Colors.blue),
        // NetworkBannerWrapper sits ABOVE every screen — no overlays needed
        builder: (context, child) {
          return NetworkBannerWrapper(child: child ?? const SizedBox.shrink());
        },
        home: SplashScreen());
  }
}

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('S')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             await populateFirestore(); // Call the function to populate Firestore
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Firestore database populated!'))
//             );
//           },
//           child: const Text("Populate Firestore"),
//         ),
//       ),
//     );
//   }
// }
