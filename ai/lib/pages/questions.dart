import 'package:ai/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/controllers.dart';
import 'view_question.dart';

class QuestionListScreen extends StatelessWidget {
  final String courseId;
  final String topicId;

  QuestionListScreen(
      {super.key, required this.courseId, required this.topicId});

  final QuestionController questionController = Get.put(QuestionController());

  final List<Color> lightCardColors = [
    const Color(0xFFE3F2FD), // Light blue
    const Color(0xFFE8F5E9), // Light green
    const Color(0xFFF3E5F5), // Light purple
    const Color(0xFFFFEBEE), // Light red
    const Color(0xFFFFF8E1), // Light orange
    const Color(0xFFE0F7FA), // Light cyan
  ];

  final List<Color> darkCardColors = [
    Colors.blueGrey.shade800,
    Colors.grey.shade800,
    Colors.indigo.shade800,
    Colors.deepPurple.shade800,
    Colors.teal.shade800,
    Colors.brown.shade800,
  ];

  Color getCardColor(int index, bool isDarkMode) {
    return isDarkMode
        ? darkCardColors[index % darkCardColors.length]
        : lightCardColors[index % lightCardColors.length];
  }

  Widget _buildQuestionCard({
    required String? imageUrl,
    required String? text,
    required bool isQuestion,
    required Color cardColor,
    required bool isDarkMode,
    required int index,
    double height = 200,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          GestureDetector(
            onTap: () {
              Get.to(
                () => ImageZoomScreen(
                  imageUrl: imageUrl,
                  index: isQuestion
                      ? index
                      : index + 1000, // Differentiate question/answer images
                ),
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Hero(
              tag: isQuestion ? 'image_$index' : 'image_${index + 1000}',
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Container(
                      color:
                          isDarkMode ? Colors.grey.shade800 : Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color:
                          isDarkMode ? Colors.grey.shade800 : Colors.grey[200],
                      child: Icon(
                        Icons.error,
                        color: Get.theme.colorScheme.error,
                      ),
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
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
                color: isQuestion
                    ? cardColor.withOpacity(isDarkMode ? 0.5 : 0.3)
                    : isDarkMode
                        ? Colors.grey.shade900
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                text,
                style: TextStyle(
                  fontSize: isQuestion ? 18 : 16,
                  fontWeight: isQuestion ? FontWeight.w600 : FontWeight.normal,
                  color: isDarkMode
                      ? (isQuestion ? Colors.white : Colors.grey.shade300)
                      : (isQuestion ? Colors.black87 : Colors.black54),
                ),
              ),
            ),
          ),
      ],
    );

    return content;
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.grey.shade300 : Colors.blueGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuestionController questionController =
        Get.find<QuestionController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (questionController.questions.isEmpty ||
          questionController.currentCourseId != courseId ||
          questionController.currentTopicId != topicId) {
        questionController.setupRealtimeQuestions(courseId, topicId);
      }
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Practice Questions",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
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
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Get.offAll(MainScreen());
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [Colors.grey.shade900, Colors.grey.shade800],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade50, Colors.grey.shade100],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Obx(() {
          if (questionController.isLoading.value &&
              questionController.questions.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Get.theme.colorScheme.primary,
              ),
            );
          }

          if (questionController.errorMessage.isNotEmpty &&
              questionController.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Get.theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    questionController.errorMessage.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => questionController.setupRealtimeQuestions(
                        courseId, topicId),
                    child: Text(
                      "Try Again",
                      style: TextStyle(color: Get.theme.colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            );
          }

          if (questionController.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 48,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No questions available yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Check back later or contact your instructor",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
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
              final color = getCardColor(index, isDarkMode);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
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
                      iconColor:
                          isDarkMode ? Colors.grey.shade300 : Colors.blueGrey,
                      collapsedIconColor:
                          isDarkMode ? Colors.grey.shade300 : Colors.blueGrey,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? Colors.grey.shade800 : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.shade500
                                : Colors.blueGrey,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                      title: _buildQuestionCard(
                        imageUrl: question['imageUrl'],
                        text: question['question'],
                        isQuestion: true,
                        cardColor: color,
                        isDarkMode: isDarkMode,
                        index: index,
                        height: 180,
                      ),
                      children: [
                        if (question['correctAnswer'] != null ||
                            question['correctAnswerImage'] != null)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                    "Correct Answer", isDarkMode),
                                _buildQuestionCard(
                                  imageUrl: question['correctAnswerImage'],
                                  text: question['correctAnswer'],
                                  isQuestion: false,
                                  cardColor: color,
                                  isDarkMode: isDarkMode,
                                  index: index,
                                  height: 150,
                                ),
                              ],
                            ),
                          ),
                        if (question['explanation'] != null &&
                            question['explanation'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Explanation", isDarkMode),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.grey.shade900
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    question['explanation'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDarkMode
                                          ? Colors.grey.shade300
                                          : Colors.black87,
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
