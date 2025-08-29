import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CourseController extends GetxController {
  var courses = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
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
    fetchCourses();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final nowOffline = results.isEmpty || results.contains(ConnectivityResult.none);
      isOffline.value = nowOffline;
      if (!nowOffline && (courses.isEmpty || isFirstLoad)) {
        fetchCourses(forceRefresh: true);
      }
    });
  }

  Future<void> fetchCourses({bool forceRefresh = false}) async {
    if (!forceRefresh && !isFirstLoad && courses.isNotEmpty) {
      // Already loaded, don’t fetch again
      return;
    }

    isLoading(true);
    errorMessage('');
    try {
      final prefs = await SharedPreferences.getInstance();

      // Step 1: Load cached data
      _loadCachedCourses(prefs);

      // Step 2: If cache exists and not forcing refresh, stop here
      if (!forceRefresh && courses.isNotEmpty) {
        isLoading(false);
        isFirstLoad = false;
        return;
      }

      // Step 3: Check for internet
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        isOffline(true);
        if (courses.isEmpty) {
          errorMessage('No internet connection and no cached courses available');
        }
        isLoading(false);
        return;
      }

      // Step 4: Fetch fresh from Firestore
      await _fetchFreshCourses(prefs);
      isFirstLoad = false;
    } catch (e) {
      if (courses.isEmpty) {
        errorMessage('Failed to load courses: ${e.toString()}');
      }
      print("Error fetching courses: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchFreshCourses(SharedPreferences prefs) async {
    try {
      var coursesSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .get(const GetOptions(source: Source.server));

      final freshCourses = coursesSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      if (freshCourses.isNotEmpty) {
        courses.value = freshCourses;
        isOffline(false);

        // Save to cache
        await prefs.setString('cachedCourses', jsonEncode(freshCourses));
        await prefs.setString('lastCourseFetch', DateTime.now().toIso8601String());
      }
    } catch (e) {
      if (courses.isEmpty) rethrow; // only throw if nothing cached
    }
  }

  void _loadCachedCourses(SharedPreferences prefs) {
    try {
      final cachedCourses = prefs.getString('cachedCourses');
      if (cachedCourses != null) {
        courses.value = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedCourses) as List).map((e) => Map<String, dynamic>.from(e)),
        );
        final lastFetch = prefs.getString('lastCourseFetch');
        if (lastFetch != null) {
          lastFetchTime.value = DateTime.parse(lastFetch);
        }
      }
    } catch (e) {
      print("Error loading cached courses: $e");
    }
  }
}
