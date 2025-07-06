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