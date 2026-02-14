import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class NotesController extends GetxController {
  // Notes are now a list of Course documents, each containing a list of files
  var courses = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isSeeding = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      isLoading(true);
      final pamphletFirestore =
          FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'));

      final snapshot = await pamphletFirestore.collection('notes').get();

      if (snapshot.docs.isEmpty) {
        // Automatically seed if empty
        await seedNotes();
        // Fetch again after seeding
        fetchNotes();
        return;
      }

      courses.value = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] =
            doc.id; // The doc ID is the course name (e.g., 'Mathematics')
        data['courseName'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching notes: $e");
      Get.snackbar('Error', 'Failed to load notes: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> seedNotes() async {
    try {
      isSeeding(true);
      final pamphletFirestore =
          FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'));

      // 5 Specific Courses
      final coursesToSeed = [
        'Mathematics',
        'Biology',
        'English',
        'Chemistry',
        'Physics'
      ];

      final batch = pamphletFirestore.batch();

      for (var courseName in coursesToSeed) {
        final docRef = pamphletFirestore.collection('notes').doc(courseName);

        // Sample PDF links (using placeholders or reliable test PDFs)
        // In a real scenario, these would be actual Firebase Storage links
        final sampleFiles = [
          {
            'index': 1,
            'title': 'Chapter 1: Introduction',
            'link':
                'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
          },
          {
            'index': 2,
            'title': 'Chapter 2: Advanced Topics',
            'link': 'https://www.africau.edu/images/default/sample.pdf'
          },
        ];

        batch.set(docRef, {
          'courseName': courseName,
          'files': sampleFiles,
          'icon': _getIconForCourse(courseName),
          'color': _getColorForCourse(courseName),
        });
      }

      await batch.commit();
      print("Seeding complete!");
    } catch (e) {
      print("Error seeding notes: $e");
    } finally {
      isSeeding(false);
    }
  }

  String _getIconForCourse(String course) {
    switch (course) {
      case 'Mathematics':
        return 'functions_rounded';
      case 'Biology':
        return 'eco_rounded';
      case 'English':
        return 'menu_book_rounded';
      case 'Chemistry':
        return 'science_rounded'; // Flask icon
      case 'Physics':
        return 'bolt_rounded'; // Example for Physics
      default:
        return 'folder_rounded';
    }
  }

  String _getColorForCourse(String course) {
    switch (course) {
      case 'Mathematics':
        return 'accentBlue';
      case 'Biology':
        return 'accentGreen';
      case 'English':
        return 'accentPink';
      case 'Chemistry':
        return 'accentPurple';
      case 'Physics':
        return 'accentOrange';
      default:
        return 'accentBlue';
    }
  }
}
