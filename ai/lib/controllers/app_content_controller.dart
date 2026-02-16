import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AppContentController extends GetxController {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'));

  // Observable text fields with default fallbacks
  var greeting = 'Hello, Student'.obs;
  var emoji = '👋'.obs;
  var subtitle = 'Ready to learn something new today?'.obs;
  var sectionTitle = 'Questions & Answers'.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContent();
  }

  Future<void> fetchContent() async {
    try {
      isLoading.value = true;

      final doc =
          await _firestore.collection('app_content').doc('home_screen').get();

      if (doc.exists) {
        final data = doc.data()!;
        greeting.value = data['greeting'] ?? greeting.value;
        emoji.value = data['emoji'] ?? emoji.value;
        subtitle.value = data['subtitle'] ?? subtitle.value;
        sectionTitle.value = data['sectionTitle'] ?? sectionTitle.value;
      }
    } catch (e) {
      print('Error fetching app content: $e');
      // Defaults remain in place
    } finally {
      isLoading.value = false;
    }
  }
}
