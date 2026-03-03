import 'package:ai/controllers/ads_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show MobileAds;

import 'controllers/openAd_controller.dart';
import 'controllers/network_controller.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'scripts/seed_app_content.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock app to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize default Firebase app (ECZ - the google-services.json is for ECZ)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: EczFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase default app already initialized or failed: $e");
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
