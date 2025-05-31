import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

class CourseController extends GetxController {
  var courses = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    fetchCourses();
    super.onInit();
  }

  Future<void> fetchCourses() async {
    if (courses.isNotEmpty) return; // If data is already cached, return.

    isLoading(true);
    try {
      // Check for cached data
      final prefs = await SharedPreferences.getInstance();
      final cachedCourses = prefs.getString('cachedCourses');
      if (cachedCourses != null) {
        courses.value = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedCourses) as List).map((e) => Map<String, dynamic>.from(e)),
        );
        isLoading(false);
        return;
      }

      // Fetch from Firestore
      var coursesSnapshot = await FirebaseFirestore.instance.collection('courses').get();
      courses.value = coursesSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Include Firestore document ID
        return data;
      }).toList();

      // Cache the data
      prefs.setString('cachedCourses', jsonEncode(courses));
    } catch (e) {
      if (await _isOffline()) {
        print("You are offline. Unable to fetch courses.");
      } else {
        print("Error fetching courses: $e");
      }
    } finally {
      isLoading(false);
    Future<bool> _isOffline() async {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.none;
    }
  }
  }

  Future<bool> _isOffline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }
}

class TopicController extends GetxController {
  var topics = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;



  Future<bool> _isOffline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }
  Future<void> fetchTopics(String courseId) async {
    if (topics.isNotEmpty) return; // If data is already cached, return.

    isLoading(true);
    try {
      // Check for cached data
      final prefs = await SharedPreferences.getInstance();
      final cachedTopics = prefs.getString('cachedTopics_$courseId');
      if (cachedTopics != null) {
        topics.value = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedTopics) as List).map((e) => Map<String, dynamic>.from(e)),
        );
        isLoading(false);
        return;
      }

      // Fetch from Firestore
      var topicsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .get();
      topics.value = topicsSnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Include Firestore document ID
        return data;
      }).toList();

      // Cache the data
      prefs.setString('cachedTopics_$courseId', jsonEncode(topics));
    } catch (e) {
      if (await _isOffline()) {
        print("You are offline. Unable to fetch topics.");
      } else {
        print("Error fetching topics: $e");
      }
    } finally {
      isLoading(false);
    }
  }
}

class QuestionController extends GetxController {
  var questions = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;


  Future<bool> _isOffline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.none;
  }
  Future<void> fetchQuestions(String courseId, String topicId) async {
    if (questions.isNotEmpty) return;

    isLoading(true);
    try {
      // Check for cached data
      final prefs = await SharedPreferences.getInstance();
      final cachedQuestions = prefs.getString('cachedQuestions_${courseId}_$topicId');
      if (cachedQuestions != null) {
        questions.value = List<Map<String, dynamic>>.from(
          (jsonDecode(cachedQuestions) as List).map((e) => Map<String, dynamic>.from(e)),
        );
        isLoading(false);
        return;
      }

      // Fetch from Firestore
      var questionsSnapshot = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .doc(topicId)
          .collection('questions')
          .get();

      questions.value = questionsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include the question ID
        return data;
      }).toList();

      // Cache the data
      prefs.setString('cachedQuestions_${courseId}_$topicId', jsonEncode(questions));
    } catch (e) {
      if (await _isOffline()) {
        print("You are offline. Unable to fetch questions.");
      } else {
        print("Error fetching questions: $e");
      }
    } finally {
      isLoading(false);
    }
  }
}
