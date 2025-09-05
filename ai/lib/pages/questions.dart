import 'package:ai/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../controllers/question_controller.dart';
import 'view_question.dart';

class QuestionListScreen extends StatefulWidget {
  final String courseId;
  final String topicId;

  QuestionListScreen(
      {super.key, required this.courseId, required this.topicId});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final QuestionController questionController = Get.put(QuestionController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (questionController.questions.isEmpty ||
          questionController.currentCourseId != widget.courseId ||
          questionController.currentTopicId != widget.topicId) {
        questionController.setupRealtimeQuestions(
            widget.courseId, widget.topicId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !questionController.isLoadingMore.value &&
        questionController.hasMore.value) {
      questionController.loadMoreQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.deepPurple : Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Questions",
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
                  ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                  : [Colors.deepPurple.shade700, Colors.indigo.shade700],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Get.offAll(MainScreen()),
          ),
          
        IconButton(
    icon: const Icon(Icons.help_outline, color: Colors.white),
    onPressed: () => _showZoomHelpDialog(),
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
              child: CircularProgressIndicator(color: primaryColor),
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
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => questionController.setupRealtimeQuestions(
                        widget.courseId, widget.topicId),
                    child: const Text(
                      "Try Again",
                      style: TextStyle(color: Colors.white),
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
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: questionController.questions.length +
                (questionController.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == questionController.questions.length) {
                return _buildLoadMoreIndicator(primaryColor);
              }

              return _buildTimelineCard(
                context,
                index,
                questionController.questions[index],
                isDarkMode,
                primaryColor,
                questionController.questions.length,
              );
            },
          );
        }),
      ),
    );
  }

  // zoom help function

  void _showZoomHelpDialog() {
    Get.defaultDialog(
      title: 'Zoom Help',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: 'If you can\'t see the questions or answers clearly:\n\n'
           '👉 Tap to zoom\n'
           '📝 For text questions: These cannot be zoomed (fixed text)\n\n'
           
          ,
      middleTextStyle:const TextStyle(fontSize: 14, color: Colors.white),
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
      buttonColor: Colors.blue,
      backgroundColor: Colors.grey[900]!,
      titlePadding: const EdgeInsets.all(20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  Widget _buildLoadMoreIndicator(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: questionController.isLoadingMore.value
            ? CircularProgressIndicator(
                color: Colors.indigo.shade900,
              )
            : questionController.hasMore.value
                ? ElevatedButton(
                    onPressed: () => questionController.loadMoreQuestions(),
                    child: const Text("Load More"),
                  )
                : Text(
                    "No no more questions, more coming soon sit tight",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
      ),
    );
  }

  // Keep all your existing methods exactly as they were...
  Widget _buildTimelineCard(
    BuildContext context,
    int index,
    Map<String, dynamic> question,
    bool isDarkMode,
    Color primaryColor,
    int totalCount,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              // Top line (only for items after the first)
              if (index > 0)
                Container(
                  width: 2,
                  height: 24,
                  color: primaryColor.withOpacity(0.4),
                ),
              // Number indicator
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              // Bottom line (only for items before the last)
              if (index < totalCount - 1)
                Container(
                  width: 2,
                  height: 24,
                  color: primaryColor.withOpacity(0.4),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Question card
          Expanded(
            child: _buildQuestionCard(
              context: context,
              index: index,
              question: question,
              isDarkMode: isDarkMode,
              primaryColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required BuildContext context,
    required int index,
    required Map<String, dynamic> question,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question content
            if (question['question'] != null && question['question'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildContentSection(
                  text: question['question'],
                  isQuestion: true,
                  isDarkMode: isDarkMode,
                  primaryColor: primaryColor,
                ),
              ),

            // Question image
            if (question['imageUrl'] != null && question['imageUrl'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => ImageZoomScreen(
                        imageUrl: question['imageUrl'],
                        index: index,
                      ),
                      transition: Transition.fadeIn,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                  child: Hero(
                    tag: 'image_$index',
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade100,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: question['imageUrl'],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child:
                                CircularProgressIndicator(color: primaryColor),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.error,
                            color: Get.theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Correct answer
            if (question['correctAnswer'] != null ||
                question['correctAnswerImage'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Correct Answer",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 89, 172, 240),
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                  if (question['correctAnswer'] != null &&
                      question['correctAnswer'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildContentSection(
                        text: question['correctAnswer'],
                        isQuestion: false,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                  if (question['correctAnswerImage'] != null &&
                      question['correctAnswerImage'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            () => ImageZoomScreen(
                              imageUrl: question['correctAnswerImage'],
                              index: index + 1000,
                            ),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                        child: Hero(
                          tag: 'image_${index + 1000}',
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: question['correctAnswerImage'],
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                      color: primaryColor),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  color: Get.theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            // Explanation
            if (question['explanation'] != null &&
                question['explanation'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "Explanation",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  _buildContentSection(
                    text: question['explanation'],
                    isQuestion: false,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required String text,
    required bool isQuestion,
    required bool isDarkMode,
    Color? primaryColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isQuestion
            ? (primaryColor ?? Colors.blue).withOpacity(isDarkMode ? 0.2 : 0.1)
            : isDarkMode
                ? Colors.grey.shade900
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: text.trim().contains(r'$$')
          ? TeXView(
              child: TeXViewDocument(
                '''
                <p style="font-size:16px; color: ${isDarkMode ? 'white' : 'black'};">${text.replaceAll(r'$$', '')}</p>
                ''',
                style: const TeXViewStyle(
                  textAlign: TeXViewTextAlign.left,
                  padding: TeXViewPadding.all(6),
                ),
              ),
              style: TeXViewStyle(
                backgroundColor:
                    isDarkMode ? Colors.grey.shade900 : Colors.white,
                borderRadius: const TeXViewBorderRadius.all(10),
                elevation: 0,
                border: const TeXViewBorder.all(TeXViewBorderDecoration(
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                )),
              ),
              loadingWidgetBuilder: (context) => Center(
                child: CircularProgressIndicator(
                  color: primaryColor ?? Colors.blue,
                ),
              ),
            )
          : SelectableText(
              text,
              style: TextStyle(
                fontSize: isQuestion ? 18 : 16,
                fontWeight: isQuestion ? FontWeight.w600 : FontWeight.normal,
                color: isDarkMode
                    ? (isQuestion ? Colors.white : Colors.grey.shade300)
                    : (isQuestion ? Colors.black87 : Colors.black54),
              ),
            ),
    );
  }
}
