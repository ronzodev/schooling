import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:ai/utils/safe_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NotesController extends GetxController {
  // Notes are now a list of Course documents, each containing a list of files
  var courses = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    try {
      isLoading(true);
      errorMessage(''); // Clear previous error

      // Check connectivity first to fail fast if offline
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        // If strict offline (and assuming no persistence for initial fetch or if we want to show error)
        // Actually, if we want to rely on persistence, we should let Firestore try.
        // But the user complains about "rotating".
        // If we throw here, we show error.
        // But we should ONLY throw if we don't have cache?
        // Firestore persistence is opaque.
        // But usually: if offline, Firestore returns cache immediately if available.
        // If it hangs, it means it's trying to connect.
        // Let's set a timeout? Or just show error if offline?
        // User asked for "no connection screen".
        // Let's throw error if offline, but only if we plan to block UI.
        // Wait, if I throw error, UI shows NoConnectionWidget (per my previous fix).
        // If we have cache, we WANT to show data.
        // So we should try to get data from cache explicitly?
        try {
          final cacheSnapshot =
              await FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'))
                  .collection('notes')
                  .get(const GetOptions(source: Source.cache));
          if (cacheSnapshot.docs.isNotEmpty) {
            // We have cache! Use it.
            // Proceed to map data
            courses.value = cacheSnapshot.docs.map((doc) {
              var data = doc.data();
              data['id'] = doc.id;
              data['courseName'] = doc.id;
              return data;
            }).toList();
            return; // Done
          }
        } catch (_) {
          // No cache available.
          throw 'No internet connection and no cached notes.';
        }
      }

      final pamphletFirestore =
          FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'));

      final snapshot = await pamphletFirestore.collection('notes').get();

      if (snapshot.docs.isEmpty) {
        courses.clear(); // Ensure list is empty
        errorMessage('No notes found.');
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
      errorMessage(
          'Unable to load notes. Please check your internet connection.');
      showSafeSnackbar(
          title: 'Offline',
          message:
              'Unable to load notes. Please check your internet connection.');
    } finally {
      isLoading(false);
    }
  }
}
