// import 'dart:async';
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TopicController extends GetxController {
//   var topics = <Map<String, dynamic>>[].obs;
//   var isLoading = true.obs;
//   var isOffline = false.obs;
//   var errorMessage = ''.obs;
//   var lastFetchTime = DateTime(0).obs;
//   String? currentCourseId;

//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;
//   var isFirstLoad = true;

//   @override
//   void onInit() {
//     super.onInit();
//     _setupConnectivityListener();
//   }

//   @override
//   void onClose() {
//     _connectivitySubscription.cancel();
//     super.onClose();
//   }

//   void _setupConnectivityListener() {
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
//       final nowOffline = result == ConnectivityResult.none;
//       if (isOffline.value && !nowOffline && currentCourseId != null) {
//         fetchTopics(currentCourseId!, forceRefresh: true);
//       }
//       isOffline.value = nowOffline;
//     });
//   }

//   Future<void> fetchTopics(String courseId, {bool forceRefresh = false}) async {
//     if (isLoading.value && currentCourseId == courseId && !forceRefresh) return;
    
//     currentCourseId = courseId;
//     isLoading(true);
//     errorMessage('');
//     try {
//       final prefs = await SharedPreferences.getInstance();
      
//       if (isFirstLoad || forceRefresh) {
//         isFirstLoad = false;
        
//         final connectivityResult = await _connectivity.checkConnectivity();
//         if (connectivityResult == ConnectivityResult.none) {
//           isOffline(true);
//           _loadCachedTopics(prefs, courseId);
//           return;
//         }

//         await _fetchFreshTopics(prefs, courseId);
//         lastFetchTime.value = DateTime.now();
//         return;
//       }

//       _loadCachedTopics(prefs, courseId);
      
//     } catch (e) {
//       errorMessage('Failed to load topics: ${e.toString()}');
//       print("Error fetching topics: $e");
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> _fetchFreshTopics(SharedPreferences prefs, String courseId) async {
//     try {
//       var topicsSnapshot = await FirebaseFirestore.instance
//           .collection('courses')
//           .doc(courseId)
//           .collection('topics')
//           .get();
          
//       final freshTopics = topicsSnapshot.docs.map((doc) {
//         var data = doc.data();
//         data['id'] = doc.id;
//         return data;
//       }).toList();

//       topics.value = freshTopics;
//       isOffline(false);
      
//       await prefs.setString('cachedTopics_$courseId', jsonEncode(freshTopics));
//       await prefs.setString('lastTopicsFetch_$courseId', DateTime.now().toIso8601String());
//     } catch (e) {
//       _loadCachedTopics(prefs, courseId);
//       rethrow;
//     }
//   }

//   void _loadCachedTopics(SharedPreferences prefs, String courseId) {
//     final cachedTopics = prefs.getString('cachedTopics_$courseId');
//     if (cachedTopics != null) {
//       topics.value = List<Map<String, dynamic>>.from(
//         (jsonDecode(cachedTopics) as List).map((e) => Map<String, dynamic>.from(e)),
//       );
//       final lastFetch = prefs.getString('lastTopicsFetch_$courseId');
//       if (lastFetch != null) {
//         lastFetchTime.value = DateTime.parse(lastFetch);
//       }
//     } else {
//       errorMessage('No cached topics available');
//     }
//   }
// }
