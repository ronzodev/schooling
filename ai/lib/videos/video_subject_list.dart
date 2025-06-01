
import 'package:ai/pages/course.dart';
import 'package:ai/videos/video_topic_screeen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../pages/main_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Future<void> _populateSampleData() async {
  //   setState(() => _isLoading = true);
    
  //   try {
  //     // Clear existing data first
  //     final collections = await _firestore.collection('videos').get();
  //     for (var doc in collections.docs) {
  //       await doc.reference.delete();
  //     }

  //     // Biology data
  //     await _firestore.collection('videos').doc('biology').set({
  //       'title': 'Biology',
  //       'icon': '🧬',
  //     });
      
  //     // Cell Structure topic
  //     await _firestore
  //         .collection('videos')
  //         .doc('biology')
  //         .collection('topics')
  //         .doc('cell_structure')
  //         .set({
  //       'title': 'Cell Structure',
  //     });
      
  //     // Cell videos
  //     await _firestore
  //         .collection('videos')
  //         .doc('biology')
  //         .collection('topics')
  //         .doc('cell_structure')
  //         .collection('videos')
  //         .add({
  //       'title': 'Introduction to Cells',
  //       'youtubeId': '8IlzKri08kk',
  //       'description': 'Learn about basic cell components',
  //       'duration': '9:15',
  //     });

  //     await _firestore
  //         .collection('videos')
  //         .doc('biology')
  //         .collection('topics')
  //         .doc('cell_structure')
  //         .collection('videos')
  //         .add({
  //       'title': 'Cell Membrane Structure',
  //       'youtubeId': 'moPJkCbKjBs',
  //       'description': 'Understanding the cell membrane',
  //       'duration': '7:42',
  //     });

  //     // Genetics topic
  //     await _firestore
  //         .collection('videos')
  //         .doc('biology')
  //         .collection('topics')
  //         .doc('genetics')
  //         .set({
  //       'title': 'Genetics',
  //     });
      
  //     // Genetics videos
  //     await _firestore
  //         .collection('videos')
  //         .doc('biology')
  //         .collection('topics')
  //         .doc('genetics')
  //         .collection('videos')
  //         .add({
  //       'title': 'DNA Structure and Function',
  //       'youtubeId': '8kK2zwjRV0M',
  //       'description': 'Learn about DNA',
  //       'duration': '10:54',
  //     });

  //     // Mathematics data
  //     await _firestore.collection('videos').doc('mathematics').set({
  //       'title': 'Mathematics',
  //       'icon': '🧮',
  //     });
      
  //     // Algebra topic
  //     await _firestore
  //         .collection('videos')
  //         .doc('mathematics')
  //         .collection('topics')
  //         .doc('algebra')
  //         .set({
  //       'title': 'Algebra Basics',
  //     });
      
  //     // Algebra videos
  //     await _firestore
  //         .collection('videos')
  //         .doc('mathematics')
  //         .collection('topics')
  //         .doc('algebra')
  //         .collection('videos')
  //         .add({
  //       'title': 'Solving Linear Equations',
  //       'youtubeId': 'Z-ZkmpQBIFo',
  //       'description': 'Step-by-step guide to solving equations',
  //       'duration': '11:20',
  //     });

  //     // Geometry topic
  //     await _firestore
  //         .collection('videos')
  //         .doc('mathematics')
  //         .collection('topics')
  //         .doc('geometry')
  //         .set({
  //       'title': 'Geometry',
  //     });
      
  //     // Geometry videos
  //     await _firestore
  //         .collection('videos')
  //         .doc('mathematics')
  //         .collection('topics')
  //         .doc('geometry')
  //         .collection('videos')
  //         .add({
  //       'title': 'Pythagorean Theorem',
  //       'youtubeId': 'AA6RfgP-AHU',
  //       'description': 'Understanding the Pythagorean theorem',
  //       'duration': '12:34',
  //     });

  //     // Science data
  //     await _firestore.collection('videos').doc('science').set({
  //       'title': 'Science',
  //       'icon': '🔬',
  //     });
      
  //     // Chemistry topic
  //     await _firestore
  //         .collection('videos')
  //         .doc('science')
  //         .collection('topics')
  //         .doc('chemistry')
  //         .set({
  //       'title': 'Basic Chemistry',
  //     });
      
  //     // Chemistry videos
  //     await _firestore
  //         .collection('videos')
  //         .doc('science')
  //         .collection('topics')
  //         .doc('chemistry')
  //         .collection('videos')
  //         .add({
  //       'title': 'Periodic Table Explained',
  //       'youtubeId': 'fPnwBITSmgU',
  //       'description': 'Learn how to read the periodic table',
  //       'duration': '14:13',
  //     });

  //     // Physics topic
  //     await _firestore
  //         .collection('videos')
  //         .doc('science')
  //         .collection('topics')
  //         .doc('physics')
  //         .set({
  //       'title': 'Physics Fundamentals',
  //     });
      
  //     // Physics videos
  //     await _firestore
  //         .collection('videos')
  //         .doc('science')
  //         .collection('topics')
  //         .doc('physics')
  //         .collection('videos')
  //         .add({
  //       'title': 'Newton\'s Laws of Motion',
  //       'youtubeId': 'kKKM8Y-u7ds',
  //       'description': 'Understanding Newton\'s three laws',
  //       'duration': '16:45',
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Sample data populated successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Get.off(MainScreen());
        }, icon:const  Icon(Icons.arrow_back)),
        title: const Text('Educational Videos'),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: _populateSampleData,
          //   tooltip: 'Populate Sample Data',
          // ),
         
        ],

        
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('videos').orderBy('title').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No subjects found'),
                        SizedBox(height: 20),
                        // ElevatedButton(
                        //   onPressed: _populateSampleData,
                        //   child: const Text('Populate Sample Data'),
                        // ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var subject = snapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Text(
                          subject['icon'] ?? '📚',
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(subject['title']),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopicListScreenVideo(
                                subjectId: subject.id,
                                subjectTitle: subject['title'], 
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
