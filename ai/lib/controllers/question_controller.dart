import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class QuestionController extends GetxController {
  var questions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isOffline = false.obs;
  var errorMessage = ''.obs;
  var lastFetchTime = DateTime(0).obs;
  String? currentCourseId;
  String? currentTopicId;
  
  // Pagination variables
  var hasMore = true.obs;
  var isLoadingMore = false.obs;
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 10; // Number of questions per page
  
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
    
    // Reset pagination state
    _resetPagination();
    
    currentCourseId = courseId;
    currentTopicId = topicId;
    isLoading(true);
    errorMessage('');

    // Load cached data first
    _loadCachedQuestions(courseId, topicId);

    try {
      // Initialize the questions subscription with pagination
      _questionsSubscription = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .doc(topicId)
          .collection('questions')
          .orderBy('createdAt', descending: true) // Add ordering for consistent pagination
          .limit(_pageSize)
          .snapshots()
          .listen(
            (querySnapshot) => _handleQuestionsUpdate(querySnapshot, courseId, topicId),
            onError: (error) => _handleQuestionsError(error),
          );
    } catch (e) {
      _handleQuestionsError(e);
    }
  }

  Future<void> loadMoreQuestions() async {
    if (isLoadingMore.value || !hasMore.value || currentCourseId == null || currentTopicId == null) return;
    
    isLoadingMore(true);
    
    try {
      Query query = FirebaseFirestore.instance
          .collection('courses')
          .doc(currentCourseId!)
          .collection('topics')
          .doc(currentTopicId!)
          .collection('questions')
          .orderBy('createdAt', descending: true);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      query = query.limit(_pageSize);

      final querySnapshot = await query.get();
      
      if (querySnapshot.docs.isEmpty) {
        hasMore.value = false;
        return;
      }

      final newQuestions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();

      questions.addAll(newQuestions);
      
      if (querySnapshot.docs.length < _pageSize) {
        hasMore.value = false;
      } else {
        _lastDocument = querySnapshot.docs.last;
      }

      // Update cache with new data
      await _updateCache();

    } catch (e) {
      errorMessage('Failed to load more questions: ${e.toString()}');
    } finally {
      isLoadingMore(false);
    }
  }

  Future<void> _handleQuestionsUpdate(QuerySnapshot querySnapshot, String courseId, String topicId) async {
    try {
      final freshQuestions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {...data, 'id': doc.id};
      }).toList();

      questions.value = freshQuestions;
      
      // Update pagination state
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        hasMore.value = querySnapshot.docs.length == _pageSize;
      } else {
        hasMore.value = false;
      }

      isOffline(false);
      
      // Update cache
      await _updateCache();
      
      lastFetchTime.value = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastQuestionsFetch_${courseId}_$topicId', lastFetchTime.value.toIso8601String());
      
      isLoading(false);
      isFirstLoad = false;
      
    } catch (e) {
      _handleQuestionsError(e);
    }
  }


// collapse the answer
// Add this to your QuestionController class
var collapsedStates = <String, bool>{}.obs;

void toggleQuestionCollapse(String questionId) {
  if (collapsedStates.containsKey(questionId)) {
    collapsedStates[questionId] = !collapsedStates[questionId]!;
  } else {
    collapsedStates[questionId] = true; // Start collapsed by default
  }
  collapsedStates.refresh();
}

bool isQuestionCollapsed(String questionId) {
  return collapsedStates[questionId] ?? true; // Default to collapsed
}

  Future<void> _updateCache() async {
    if (currentCourseId != null && currentTopicId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cachedQuestions_${currentCourseId}_$currentTopicId', 
        jsonEncode(questions)
      );
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
      _resetPagination();
      
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .doc(currentCourseId!)
            .collection('topics')
            .doc(currentTopicId!)
            .collection('questions')
            .orderBy('createdAt', descending: true)
            .limit(_pageSize)
            .get(const GetOptions(source: Source.server));

        await _handleQuestionsUpdate(querySnapshot, currentCourseId!, currentTopicId!);
      } catch (e) {
        errorMessage('Failed to refresh: ${e.toString()}');
      } finally {
        isLoading(false);
      }
    }
  }

  void _resetPagination() {
    _lastDocument = null;
    hasMore.value = true;
    isLoadingMore.value = false;
  }

  void clearQuestions() {
    questions.clear();
    _resetPagination();
  }
}