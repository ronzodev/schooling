import 'package:ai/pages/course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controllers.dart';

class QuestionListScreen extends StatelessWidget {
  final String courseId;
  final String topicId;

  QuestionListScreen({super.key, required this.courseId, required this.topicId});

  final List<Color> backgroundColors = [
  const Color(0xFF3B82F6), // Blue
  const Color(0xFFEF4444), // Red
  const Color(0xFFF97316), // Orange
  const Color(0xFF10B981), // Green
  const Color(0xFF8B5CF6), // Purple
  const Color(0xFFF59E0B), // Amber
  ];

  Color getRandomColor(int index) {
    return backgroundColors[index % backgroundColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final QuestionController questionController = Get.put(QuestionController());

    questionController.fetchQuestions(courseId, topicId);

    return Scaffold(
      appBar: AppBar(title: const Text("Questions"),
      centerTitle: true,
    
      elevation: 0,
      actions: [
        IconButton(
        icon: const Icon(Icons.home,),
        onPressed: () {
          Get.off(CourseListScreen());
        },
      ),
     const SizedBox( width: 17.0,) ],
      ),
      body: Obx(() {
        if (questionController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
      
        return ListView.builder(
          itemCount: questionController.questions.length,
          itemBuilder: (context, index) {
            var question = questionController.questions[index];
            Color color = getRandomColor(index);
      
            return Card(
              margin: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  question['question'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                children: [
                  ListTile(
                    title: const Text("Answer:"),
                    subtitle: Text(question['correctAnswer']),
                  ),
                  ListTile(
                    title: const Text("Explanation:"),
                    subtitle: Text(question['explanation']),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}