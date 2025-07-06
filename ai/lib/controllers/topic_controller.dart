import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TopicController extends GetxController {
  var topics = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isOffline = false.obs;
  var errorMessage = ''.obs;
  var lastFetchTime = DateTime(0).obs;
  String? currentCourseId;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  StreamSubscription<QuerySnapshot>? _topicsSubscription;
  var isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _topicsSubscription?.cancel();
    super.onClose();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final nowOffline = results.isEmpty || results.contains(ConnectivityResult.none);
      isOffline.value = nowOffline;
      if (!nowOffline && currentCourseId != null && (topics.isEmpty || isFirstLoad)) {
        setupRealtimeTopics(currentCourseId!);
      }
    });
  }

  void setupRealtimeTopics(String courseId) {
    // Cancel any existing subscription
    _topicsSubscription?.cancel();
    
    currentCourseId = courseId;
    isLoading(true);
    errorMessage('');

    // Load cached data first
    _loadCachedTopics(courseId);

    try {
      // Initialize the topics subscription
      _topicsSubscription = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .snapshots()
          .listen(
            (querySnapshot) => _handleTopicsUpdate(querySnapshot, courseId),
            onError: (error) => _handleTopicsError(error),
          );
    } catch (e) {
      _handleTopicsError(e);
    }
  }

  Future<void> _handleTopicsUpdate(QuerySnapshot querySnapshot, String courseId) async {
    try {
      final freshTopics = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();

      topics.value = freshTopics;
      isOffline(false);
      
      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedTopics_$courseId', jsonEncode(freshTopics));
      lastFetchTime.value = DateTime.now();
      await prefs.setString('lastTopicsFetch_$courseId', lastFetchTime.value.toIso8601String());
      
      isLoading(false);
      isFirstLoad = false;
    } catch (e) {
      _handleTopicsError(e);
    }
  }

  void _handleTopicsError(dynamic error) {
    errorMessage('Failed to load topics: ${error.toString()}');
    Get.snackbar(
      'Error',
      'Failed to load topics: ${error.toString()}',
      snackPosition: SnackPosition.BOTTOM,
    );
    if (topics.isEmpty) {
      isLoading(false);
    }
  }

  Future<void> _loadCachedTopics(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedTopics = prefs.getString('cachedTopics_$courseId');
      if (cachedTopics != null) {
        topics.value = (jsonDecode(cachedTopics) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final lastFetch = prefs.getString('lastTopicsFetch_$courseId');
        if (lastFetch != null) {
          lastFetchTime.value = DateTime.parse(lastFetch);
        }
      }
    } catch (e) {
      print("Error loading cached topics: $e");
    }
  }

  Future<void> refreshTopics() async {
    if (currentCourseId != null) {
      isLoading(true);
      errorMessage('');
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(currentCourseId!)
            .collection('topics')
            .get(const GetOptions(source: Source.server));
        
        await _handleTopicsUpdate(querySnapshot, currentCourseId!);
      } catch (e) {
        errorMessage('Failed to refresh: ${e.toString()}');
        Get.snackbar(
          'Error',
          'Failed to refresh topics: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        isLoading(false);
      }
    }
  }
}