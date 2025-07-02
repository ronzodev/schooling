import 'package:ai/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ai/pages/course.dart';
import 'package:ai/videos/video_screen_list.dart';

class TopicListScreenVideo extends StatelessWidget {
  final String subjectId;
  final String subjectTitle;

  const TopicListScreenVideo({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          subjectTitle,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: Get.isDarkMode
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8EAF6),
                    Color(0xFFC5CAE9),
                  ],
                ),
          color: Get.isDarkMode ? Get.theme.colorScheme.background : null,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('videos')
              .doc(subjectId)
              .collection('topics')
              .orderBy('title')
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
                var topic = snapshot.data!.docs[index];
                return Card(
                  color: Get.theme.cardColor,
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoListScreen(
                            subjectId: subjectId,
                            topicId: topic.id,
                            topicTitle: topic['title'],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.video_library,
                            color: Get.theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              topic['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Get.theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
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
            'Error loading topics\n$error',
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
            'No topics available',
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