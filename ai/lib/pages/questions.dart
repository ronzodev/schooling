import 'package:ai/pages/course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/controllers.dart';

class QuestionListScreen extends StatelessWidget {
  final String courseId;
  final String topicId;

  QuestionListScreen({super.key, required this.courseId, required this.topicId});

  final QuestionController questionController = Get.put(QuestionController());

  final List<Color> cardColors = [
    const Color(0xFFE3F2FD), // Light blue
    const Color(0xFFE8F5E9), // Light green
    const Color(0xFFF3E5F5), // Light purple
    const Color(0xFFFFEBEE), // Light red
    const Color(0xFFFFF8E1), // Light orange
    const Color(0xFFE0F7FA), // Light cyan
  ];

  Color getCardColor(int index) {
    return cardColors[index % cardColors.length];
  }

  Widget _buildQuestionCard({
    required String? imageUrl,
    required String? text,
    required bool isQuestion,
    required Color cardColor,
    double height = 200,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
  Container(
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        fit: BoxFit.contain,
      ),
    ),
  ),
        if (text != null && text.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: (imageUrl != null && imageUrl.isNotEmpty) ? 12.0 : 0,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isQuestion ? cardColor.withOpacity(0.3) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                text,
                style: TextStyle(
                  fontSize: isQuestion ? 18 : 16,
                  fontWeight: isQuestion ? FontWeight.w600 : FontWeight.normal,
                  color: isQuestion ? Colors.black87 : Colors.black54,
                ),
              ),
            ),
          ),
      ],
    );

    return content;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuestionController questionController = Get.find<QuestionController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (questionController.questions.isEmpty ||
          questionController.currentCourseId != courseId ||
          questionController.currentTopicId != topicId) {
        questionController.fetchQuestions(courseId, topicId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Practice Questions"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.lightBlue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.offAll(CourseListScreen());
            },
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.grey.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (questionController.isLoading.value && questionController.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (questionController.errorMessage.isNotEmpty && questionController.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    questionController.errorMessage.value,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => questionController.fetchQuestions(courseId, topicId),
                    child: const Text("Try Again", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          if (questionController.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.quiz_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No questions available yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Check back later or contact your instructor",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questionController.questions.length,
            itemBuilder: (context, index) {
              final question = questionController.questions[index];
              final color = getCardColor(index);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: color,
                    child: ExpansionTile(
                      iconColor: Colors.blueGrey,
                      collapsedIconColor: Colors.blueGrey,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueGrey, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                      title: _buildQuestionCard(
                        imageUrl: question['imageUrl'],
                        text: question['question'],
                        isQuestion: true,
                        cardColor: color,
                        height: 180,
                      ),
                      children: [
                        if (question['correctAnswer'] != null || question['correctAnswerImage'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Correct Answer"),
                                _buildQuestionCard(
                                  imageUrl: question['correctAnswerImage'],
                                  text: question['correctAnswer'],
                                  isQuestion: false,
                                  cardColor: color,
                                  height: 150,
                                ),
                              ],
                            ),
                          ),
                        if (question['explanation'] != null && question['explanation'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Explanation"),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    question['explanation'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}