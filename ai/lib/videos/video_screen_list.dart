import 'package:ai/pages/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'videoList.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(topicTitle),
      actions: [
         IconButton(onPressed: (){
            Get.off(CourseListScreen());

          }, icon: const Icon(Icons.home) )
      ],),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No videos found'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final video = snapshot.data!.docs[index];
              return VideoListItem(video: video);
            },
          );
        },
      ),
    );
  }
}