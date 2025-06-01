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
  if (!forceRefresh && !isFirstLoad && courses.isNotEmpty) return;

  isLoading(true);
  errorMessage('');
  try {
    final prefs = await SharedPreferences.getInstance();

    // Load cached data first
    _loadCachedCourses(prefs);

    // Show cached courses immediately if available
    if (!forceRefresh && courses.isNotEmpty) {
      isLoading(false);
      return;
    }

    // Check for internet
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      isOffline(true);
      if (courses.isEmpty) {
        errorMessage('No internet connection and no cached courses available');
        isLoading(false);
        return;
      }
      isLoading(false);
      return;
    }

    // Try fetching fresh data
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
          .get(const GetOptions(source: Source.serverAndCache));

      final freshCourses = coursesSnapshot.docs.map((doc) {
        var data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }).toList();

      if (freshCourses.isNotEmpty) {
        courses.value = freshCourses;
        isOffline(false);
        await prefs.setString('cachedCourses', jsonEncode(freshCourses));
        await prefs.setString('lastCourseFetch', DateTime.now().toIso8601String());
      }
    } catch (e) {
      // If fresh fetch fails but we have cached data, keep showing cached data
      if (courses.isEmpty) rethrow;
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

class TopicController extends GetxController {
  var topics = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isOffline = false.obs;
  var errorMessage = ''.obs;
  var lastFetchTime = DateTime(0).obs;
  String? currentCourseId;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  var isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
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
      if (!nowOffline && currentCourseId != null && (topics.isEmpty || isFirstLoad)) {
        fetchTopics(currentCourseId!, forceRefresh: true);
      }
    });
  }

  Future<void> fetchTopics(String courseId, {bool forceRefresh = false}) async {
    if (isLoading.value && currentCourseId == courseId && !forceRefresh) return;
    
    currentCourseId = courseId;
    isLoading(true);
    errorMessage('');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cached data first
      _loadCachedTopics(prefs, courseId);

      // Skip network fetch if not forced and we have cached data
      if (!forceRefresh && topics.isNotEmpty) {
        isLoading(false);
        return;
      }

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        isOffline(true);
        if (topics.isEmpty) {
          Get.snackbar(
            'Offline Mode',
            'No internet connection and no cached topics available',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        isLoading(false);
        return;
      }

      // Fetch fresh data
      await _fetchFreshTopics(prefs, courseId);
      isFirstLoad = false;
    } catch (e) {
      errorMessage('Failed to load topics: ${e.toString()}');
      print("Error fetching topics: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchFreshTopics(SharedPreferences prefs, String courseId) async {
    try {
      var topicsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .get(const GetOptions(source: Source.serverAndCache));

      final freshTopics = topicsSnapshot.docs.map((doc) {
        var data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }).toList();

      if (freshTopics.isNotEmpty) {
        topics.value = freshTopics;
        isOffline(false);
        await prefs.setString('cachedTopics_$courseId', jsonEncode(freshTopics));
        await prefs.setString('lastTopicsFetch_$courseId', DateTime.now().toIso8601String());
      }
    } catch (e) {
      if (topics.isEmpty) rethrow;
    }
  }

  void _loadCachedTopics(SharedPreferences prefs, String courseId) {
    try {
      final cachedTopics = prefs.getString('cachedTopics_$courseId');
      if (cachedTopics != null) {
        topics.value = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedTopics) as List).map((e) => Map<String, dynamic>.from(e)),
        );
        final lastFetch = prefs.getString('lastTopicsFetch_$courseId');
        if (lastFetch != null) {
          lastFetchTime.value = DateTime.parse(lastFetch);
        }
      }
    } catch (e) {
      print("Error loading cached topics: $e");
    }
  }
}

class QuestionController extends GetxController {
  var questions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isOffline = false.obs;
  var errorMessage = ''.obs;
  var lastFetchTime = DateTime(0).obs;
  String? currentCourseId;
  String? currentTopicId;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  var isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
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
      if (!nowOffline && currentCourseId != null && currentTopicId != null && (questions.isEmpty || isFirstLoad)) {
        fetchQuestions(currentCourseId!, currentTopicId!, forceRefresh: true);
      }
    });
  }

  Future<void> fetchQuestions(String courseId, String topicId, {bool forceRefresh = false}) async {
    if (isLoading.value && currentCourseId == courseId && currentTopicId == topicId && !forceRefresh) return;
    
    currentCourseId = courseId;
    currentTopicId = topicId;
    isLoading(true);
    errorMessage('');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cached data first
      _loadCachedQuestions(prefs, courseId, topicId);

      // Skip network fetch if not forced and we have cached data
      if (!forceRefresh && questions.isNotEmpty) {
        isLoading(false);
        return;
      }

      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        isOffline(true);
        if (questions.isEmpty) {
          errorMessage('No internet connection and no cached questions available');
        }
        isLoading(false);
        return;
      }

      // Fetch fresh data
      await _fetchFreshQuestions(prefs, courseId, topicId);
      isFirstLoad = false;
    } catch (e) {
      errorMessage('Failed to load questions: ${e.toString()}');
      print("Error fetching questions: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchFreshQuestions(SharedPreferences prefs, String courseId, String topicId) async {
    try {
      var questionsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .doc(topicId)
          .collection('questions')
          .get(const GetOptions(source: Source.serverAndCache));

      final freshQuestions = questionsSnapshot.docs.map((doc) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }).toList();

      if (freshQuestions.isNotEmpty) {
        questions.value = freshQuestions;
        isOffline(false);
        await prefs.setString('cachedQuestions_${courseId}_$topicId', jsonEncode(freshQuestions));
        await prefs.setString('lastQuestionsFetch_${courseId}_$topicId', DateTime.now().toIso8601String());
      }
    } catch (e) {
      if (questions.isEmpty) rethrow;
    }
  }

  void _loadCachedQuestions(SharedPreferences prefs, String courseId, String topicId) {
    try {
      final cachedQuestions = prefs.getString('cachedQuestions_${courseId}_$topicId');
      if (cachedQuestions != null) {
        questions.value = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedQuestions) as List).map((e) => Map<String, dynamic>.from(e)),
        );
        final lastFetch = prefs.getString('lastQuestionsFetch_${courseId}_$topicId');
        if (lastFetch != null) {
          lastFetchTime.value = DateTime.parse(lastFetch);
        }
      }
    } catch (e) {
      print("Error loading cached questions: $e");
    }
  }
}