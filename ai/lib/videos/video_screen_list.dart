import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai/videos/videoList.dart';

import '../pages/main_screen.dart';

class VideoListScreen extends StatelessWidget {
  final String subjectId;
  final String topicId;
  final String topicTitle;

  const VideoListScreen({
    super.key,
    required this.subjectId,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          topicTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Colors.deepPurple.shade900,
                      Colors.indigo.shade900,
                    ]
                  : [
                      Colors.deepPurple.shade700,
                      Colors.indigo.shade700,
                    ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Get.off(MainScreen()),
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Home',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .doc(subjectId)
            .collection('topics')
            .doc(topicId)
            .collection('videos')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          
          if (snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final video = snapshot.data!.docs[index];
              return VideoListItem(
                video: video,
                index: index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Get.theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error loading videos\n$error',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Get.theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Get.theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 64,
            color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No videos available',
            style: TextStyle(
              fontSize: 18,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new content',
            style: TextStyle(
              fontSize: 14,
              color: Get.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}