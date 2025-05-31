import 'package:ai/pages/course.dart';
import 'package:ai/videos/video_screen_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      
      appBar: AppBar(title: Text(subjectTitle),
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
            .orderBy('title')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No topics found'));
          }
          
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var topic = snapshot.data!.docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(topic['title']),
                  trailing: const Icon(Icons.chevron_right),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}