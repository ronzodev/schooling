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

  const QuestionListScreen(
      {super.key, required this.courseId, required this.topicId});

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final QuestionController questionController = Get.put(QuestionController());
  final ScrollController _scrollController = ScrollController();
  
  // Add these variables for answer visibility control
  final RxBool showAllAnswers = false.obs;
  final RxSet<int> visibleAnswers = <int>{}.obs;

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

  // Toggle individual answer visibility
  void _toggleAnswerVisibility(int index) {
    if (visibleAnswers.contains(index)) {
      visibleAnswers.remove(index);
    } else {
      visibleAnswers.add(index);
    }
  }

  // Toggle all answers visibility
  void _toggleAllAnswers() {
    showAllAnswers.value = !showAllAnswers.value;
    if (showAllAnswers.value) {
      // Show all answers
      visibleAnswers.clear();
      for (int i = 0; i < questionController.questions.length; i++) {
        visibleAnswers.add(i);
      }
    } else {
      // Hide all answers
      visibleAnswers.clear();
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
          
          // Add toggle all answers button
          Obx(() => IconButton(
            icon: Icon(
              showAllAnswers.value ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            tooltip: showAllAnswers.value ? 'Hide All Answers' : 'Show All Answers',
            onPressed: _toggleAllAnswers,
          )),
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
        child: Column(
          children: [
            // Questions list
            Expanded(
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
          ],
        ),
      ),
    );
  }

  // zoom help function
  void _showZoomHelpDialog() {
    Get.defaultDialog(
      title: 'Study Tips',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
      middleText: 'Study Mode Features:\n\n'
           '👁️ Toggle answers visibility to test yourself\n'
           '🔍 Tap images to zoom for better viewing\n'
           '📝 Text questions cannot be zoomed (fixed text)\n'
           '💡 Use the eye icon to show/hide all answers\n'
           '🎯 Individual answers can be toggled by tapping the reveal button',
      middleTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
      textConfirm: 'Got it!',
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
                    "No more questions, more coming soon sit tight",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
      ),
    );
  }

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
    // Check if question has an image
    final hasQuestionImage = question['imageUrl'] != null && question['imageUrl'].isNotEmpty;

    return Stack(
      children: [
        Card(
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

                // Question image - IMPROVED VERSION
                if (hasQuestionImage)
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
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 400, // Allow images to be taller if needed
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDarkMode
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: question['imageUrl'],
                              fit: BoxFit.contain, // Show full image without cropping
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: primaryColor),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Loading image...',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      color: Get.theme.colorScheme.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Get.theme.colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Answer reveal section with toggle
                Obx(() => _buildAnswerSection(
                  index: index,
                  question: question,
                  isDarkMode: isDarkMode,
                  primaryColor: primaryColor,
                )),
              ],
            ),
          ),
        ),
        
        // Enhanced zoom icon overlay (only show if question has image)
        if (hasQuestionImage)
          Positioned(
            top: 8,
            right: 8, // Changed from left to right for better visibility
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Tap to zoom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnswerSection({
    required int index,
    required Map<String, dynamic> question,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    final hasAnswer = (question['correctAnswer'] != null && 
                      question['correctAnswer'].isNotEmpty) ||
                     (question['correctAnswerImage'] != null && 
                      question['correctAnswerImage'].isNotEmpty);
    
    final hasExplanation = question['explanation'] != null && 
                          question['explanation'].isNotEmpty;
    
    if (!hasAnswer && !hasExplanation) return const SizedBox.shrink();
    
    final isVisible = visibleAnswers.contains(index);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Answer reveal button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton.icon(
            onPressed: () => _toggleAnswerVisibility(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: isVisible 
                  ? primaryColor.withOpacity(0.8) 
                  : isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              foregroundColor: isVisible 
                  ? Colors.white 
                  : isDarkMode ? Colors.white : Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              size: 20,
            ),
            label: Text(
              isVisible ? 'Hide Answer' : 'Reveal Answer',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        
        // Answer content (shown when visible)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isVisible ? null : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isVisible ? 1.0 : 0.0,
            child: isVisible ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Correct answer
                if (hasAnswer) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text(
                      "Correct Answer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 89, 172, 240),
                      ),
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
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              minHeight: 150,
                              maxHeight: 300, // Improved constraints for answer images
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isDarkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: question['correctAnswerImage'],
                                fit: BoxFit.contain, // Keep as contain for answer images
                                width: double.infinity,
                                placeholder: (context, url) => Container(
                                  height: 150,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(color: primaryColor),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Loading answer image...',
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        color: Get.theme.colorScheme.error,
                                        size: 36,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load answer image',
                                        style: TextStyle(
                                          color: Get.theme.colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],

                // Explanation
                if (hasExplanation) ...[
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
              ],
            ) : const SizedBox.shrink(),
          ),
        ),
      ],
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