/// Auto-seeds the app_content collection on first launch.
/// Only creates the document if it doesn't already exist.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> seedAppContent() async {
  try {
    final firestore =
        FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'));

    final doc =
        await firestore.collection('app_content').doc('home_screen').get();

    if (!doc.exists) {
      await firestore.collection('app_content').doc('home_screen').set({
        'greeting': 'Hello, Student',
        'emoji': '👋',
        'subtitle': 'Ready to learn something new today?',
        'sectionTitle': 'Questions & Answers',
      });
      print('✅ app_content/home_screen seeded successfully');
    }
  } catch (e) {
    print('⚠️ Could not seed app_content: $e');
  }
}
