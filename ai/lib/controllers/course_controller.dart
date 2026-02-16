import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CourseController extends GetxController {
  var courses = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var isOffline = false.obs;
  var errorMessage = ''.obs;
  var lastFetchTime = DateTime(0).obs;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  var isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
    _loadCachedCoursesImmediately();
    fetchCourses();
  }

  /// Load cached courses immediately on app start for instant availability
  Future<void> _loadCachedCoursesImmediately() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedCourses = prefs.getString('cachedCourses');

      if (cachedCourses != null && cachedCourses.isNotEmpty) {
        courses.value = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedCourses) as List)
              .map((e) => Map<String, dynamic>.from(e)),
        );

        final lastFetch = prefs.getString('lastCourseFetch');
        if (lastFetch != null) {
          lastFetchTime.value = DateTime.parse(lastFetch);
        }

        // If we have cached courses, don't show loading state
        isLoading.value = false;

        print(
            "CourseController: Loaded ${courses.length} cached courses immediately");
      }
    } catch (e) {
      print("Error loading cached courses on init: $e");
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final nowOffline =
          results.isEmpty || results.contains(ConnectivityResult.none);
      isOffline.value = nowOffline;
      if (!nowOffline && (courses.isEmpty || isFirstLoad)) {
        fetchCourses(forceRefresh: true);
      }
    });
  }

  Future<void> fetchCourses({bool forceRefresh = false}) async {
    // If we already have cached courses loaded, perform a background refresh
    if (courses.isNotEmpty && !forceRefresh) {
      isLoading(false);
      _fetchFreshCoursesInBackground(); // Silent background update
      return;
    }

    // Track manual refresh state for UI feedback
    if (forceRefresh) {
      isRefreshing(true);
    }

    // Show loading only if we don't have cached data
    if (courses.isEmpty) {
      isLoading(true);
    }

    errorMessage('');

    try {
      // Check for internet connection
      final connectivityResult = await _connectivity.checkConnectivity();
      print("CourseController: Connectivity result: $connectivityResult");

      if (connectivityResult.contains(ConnectivityResult.none)) {
        isOffline(true);
        if (courses.isEmpty) {
          errorMessage(
              'No internet connection and no cached courses available');
        }
        isLoading(false);
        isRefreshing(false);
        return;
      }

      // Fetch fresh data from Firestore
      print("CourseController: Fetching fresh courses from Firestore...");
      final prefs = await SharedPreferences.getInstance();
      await _fetchFreshCourses(prefs);
      print("CourseController: Now have ${courses.length} courses");
      isFirstLoad = false;
    } catch (e) {
      print("CourseController: Error fetching courses: $e");
      if (courses.isEmpty) {
        errorMessage('Failed to load courses: ${e.toString()}');
      }
    } finally {
      isLoading(false);
      isRefreshing(false);
    }
  }

  /// Fetch fresh courses in the background without showing loading state
  Future<void> _fetchFreshCoursesInBackground() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        final prefs = await SharedPreferences.getInstance();
        await _fetchFreshCourses(prefs);
      }
    } catch (e) {
      print("CourseController: Background refresh error: $e");
      // Silently fail, cached data is still available
    }
  }

  Future<void> _fetchFreshCourses(SharedPreferences prefs) async {
    try {
      print("CourseController: Querying 'courses' collection...");
      // Use Pamphlet Firebase app for courses
      final pamphletFirestore =
          FirebaseFirestore.instanceFor(app: Firebase.app('pamphlet'));
      var coursesSnapshot = await pamphletFirestore
          .collection('courses')
          .get(const GetOptions(source: Source.server));

      print(
          "CourseController: Got ${coursesSnapshot.docs.length} documents from Firestore");

      final freshCourses = coursesSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        print(
            "CourseController: Found course: ${data['title']} (id: ${doc.id})");
        return data;
      }).toList();

      if (freshCourses.isNotEmpty) {
        courses.value = freshCourses;
        isOffline(false);

        // Save to cache
        await prefs.setString('cachedCourses', jsonEncode(freshCourses));
        await prefs.setString(
            'lastCourseFetch', DateTime.now().toIso8601String());
        print(
            "CourseController: Saved ${freshCourses.length} courses to cache");
      } else {
        print("CourseController: No courses found in 'courses' collection!");
      }
    } catch (e) {
      print("CourseController: _fetchFreshCourses error: $e");
      if (courses.isEmpty) rethrow; // only throw if nothing cached
    }
  }
}
