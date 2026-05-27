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

  /// Deep-copies a value from Firestore so all maps/lists are mutable.
  dynamic _deepCopy(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key as String, _deepCopy(val)));
    } else if (value is List) {
      return value.map((item) => _deepCopy(item)).toList();
    }
    return value;
  }

  Future<void> fetchNotes() async {
    try {
      isLoading(true);
      errorMessage(''); // Clear previous error

      // Check connectivity first to fail fast if offline
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        try {
          final cacheSnapshot =
              await FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'))
                  .collection('notes')
                  .get(const GetOptions(source: Source.cache));
          if (cacheSnapshot.docs.isNotEmpty) {
            courses.value = cacheSnapshot.docs.map((doc) {
              var data = Map<String, dynamic>.from(
                  _deepCopy(doc.data()) as Map<String, dynamic>);
              data['id'] = doc.id;
              data['courseName'] = doc.id;
              return data;
            }).toList();
            return; // Done
          }
        } catch (_) {
          throw 'No internet connection and no cached notes.';
        }
      }

      final pamphletFirestore =
          FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'));

      final snapshot = await pamphletFirestore.collection('notes').get();

      if (snapshot.docs.isEmpty) {
        courses.clear();
        errorMessage('No notes found.');
        return;
      }

      courses.value = snapshot.docs.map((doc) {
        var data = Map<String, dynamic>.from(
            _deepCopy(doc.data()) as Map<String, dynamic>);
        data['id'] = doc.id;
        data['courseName'] = doc.id;
        return data;
      }).toList();
    } catch (e, stackTrace) {
      print("Error fetching notes: $e");
      print("Stack trace: $stackTrace");
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
