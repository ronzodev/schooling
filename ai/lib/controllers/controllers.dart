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
  StreamSubscription<QuerySnapshot>? _questionsSubscription;
  var isFirstLoad = true;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {});
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    _questionsSubscription?.cancel();
    super.onClose();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final nowOffline = results.isEmpty || results.contains(ConnectivityResult.none);
      isOffline.value = nowOffline;
      if (!nowOffline && currentCourseId != null && currentTopicId != null && (questions.isEmpty || isFirstLoad)) {
        setupRealtimeQuestions(currentCourseId!, currentTopicId!);
      }
    });
  }

  void setupRealtimeQuestions(String courseId, String topicId) {
    // Cancel any existing subscription
    _questionsSubscription?.cancel();
    
    currentCourseId = courseId;
    currentTopicId = topicId;
    isLoading(true);
    errorMessage('');

    // Load cached data first
    _loadCachedQuestions(courseId, topicId);

    try {
      // Initialize the questions subscription
      _questionsSubscription = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .doc(topicId)
          .collection('questions')
          .snapshots()
          .listen(
            (querySnapshot) => _handleQuestionsUpdate(querySnapshot, courseId, topicId),
            onError: (error) => _handleQuestionsError(error),
          );
    } catch (e) {
      _handleQuestionsError(e);
    }
  }

  Future<void> _handleQuestionsUpdate(QuerySnapshot querySnapshot, String courseId, String topicId) async {
    try {
      final freshQuestions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();

      questions.value = freshQuestions;
      isOffline(false);
      
      // Update cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cachedQuestions_${courseId}_$topicId', jsonEncode(freshQuestions));
      lastFetchTime.value = DateTime.now();
      await prefs.setString('lastQuestionsFetch_${courseId}_$topicId', lastFetchTime.value.toIso8601String());
      
      isLoading(false);
      isFirstLoad = false;
    } catch (e) {
      _handleQuestionsError(e);
    }
  }

  void _handleQuestionsError(dynamic error) {
    errorMessage('Failed to load questions: ${error.toString()}');
    if (questions.isEmpty) {
      isLoading(false);
    }
  }

  Future<void> _loadCachedQuestions(String courseId, String topicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedQuestions = prefs.getString('cachedQuestions_${courseId}_$topicId');
      if (cachedQuestions != null) {
        questions.value = (jsonDecode(cachedQuestions) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final lastFetch = prefs.getString('lastQuestionsFetch_${courseId}_$topicId');
        if (lastFetch != null) {
          lastFetchTime.value = DateTime.parse(lastFetch);
        }
      }
    } catch (e) {
      print("Error loading cached questions: $e");
    }
  }

  Future<void> refreshQuestions() async {
    if (currentCourseId != null && currentTopicId != null) {
      isLoading(true);
      errorMessage('');
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(currentCourseId!)
            .collection('topics')
            .doc(currentTopicId!)
            .collection('questions')
            .get(const GetOptions(source: Source.server));
        
        await _handleQuestionsUpdate(querySnapshot, currentCourseId!, currentTopicId!);
      } catch (e) {
        errorMessage('Failed to refresh: ${e.toString()}');
      } finally {
        isLoading(false);
      }
    }
  }
}