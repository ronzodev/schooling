import 'package:ai/controllers/ads_controller.dart';

import 'package:ai/widgets/lined_paper_painter.dart';
import 'package:ai/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_tex/flutter_tex.dart';
import '../controllers/question_controller.dart';
import '../theme/app_theme.dart';
import 'view_question.dart';
import '../widgets/no_connection_widget.dart';

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

  // Answer visibility control
  final RxBool showAllAnswers = false.obs;
  final RxSet<int> visibleAnswers = <int>{}.obs;

  // Global answer reveal counter
  int _globalAnswerRevealCount = 0;
  final GoogleAdsController _adsController = GoogleAdsController.instance;

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
      _initializeAds();
    });
  }

  Future<void> _initializeAds() async {
    await _adsController.initialize();
    _adsController.onInterstitialClosed = () {
      debugPrint('📱 Interstitial ad closed');
    };
    _adsController.onInterstitialFailed = () {
      debugPrint('❌ Interstitial ad failed');
    };
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

  void _toggleAnswerVisibility(int index) {
    if (visibleAnswers.contains(index)) {
      visibleAnswers.remove(index);
    } else {
      _globalAnswerRevealCount++;
      if (_globalAnswerRevealCount == 2) {
        _showInterstitialAdThenReveal(index);
        _globalAnswerRevealCount = 0;
      } else {
        visibleAnswers.add(index);
      }
    }
  }

  void _showInterstitialAdThenReveal(int index) {
    if (_adsController.isInterstitialReady()) {
      _adsController.onInterstitialClosed = () {
        visibleAnswers.add(index);
        _adsController.onInterstitialClosed = () {};
      };
      _adsController.showInterstitialAd();
    } else {
      visibleAnswers.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildAppBar(),

              // Questions list
              Expanded(
                child: Obx(() => _buildQuestionsList()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),

          const Spacer(),

          // Title
          const Text(
            'Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const Spacer(),

          // Home button
          GestureDetector(
            onTap: () => Get.offAll(MainScreen()),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: AppTheme.accentBlue,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Help button
          GestureDetector(
            onTap: _showZoomHelpDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: AppTheme.accentPink,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    // Loading state
    if (questionController.isLoading.value &&
        questionController.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: AppTheme.accentBlue,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading questions...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (questionController.errorMessage.isNotEmpty &&
        questionController.questions.isEmpty) {
      return Center(
        child: NoConnectionWidget(
          onRetry: () => questionController.setupRealtimeQuestions(
            widget.courseId,
            widget.topicId,
          ),
          message: questionController.errorMessage.value,
        ),
      );
    }

    // Empty state
    if (questionController.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_rounded,
                size: 48,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No questions available yet',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for new content',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Questions list
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: questionController.questions.length +
          (questionController.hasMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == questionController.questions.length) {
          return _buildLoadMoreIndicator();
        }
        return _buildQuestionCard(
          index: index,
          question: questionController.questions[index],
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: questionController.isLoadingMore.value
            ? const CircularProgressIndicator(
                color: AppTheme.accentBlue,
                strokeWidth: 3,
              )
            : Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'More questions coming soon! 🎉',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildQuestionCard({
    required int index,
    required Map<String, dynamic> question,
  }) {
    final hasQuestionImage = question['imageUrl'] != null &&
        question['imageUrl'].toString().isNotEmpty;
    final gradient =
        AppTheme.colorfulGradients[index % AppTheme.colorfulGradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration:
                AppTheme.paperDecoration, // switched to paper decoration
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add top padding for question number
                const SizedBox(height: 8),

                // Question text content
                if (question['question'] != null &&
                    question['question'].toString().isNotEmpty)
                  _buildContentSection(
                    text: question['question'],
                    isQuestion: true,
                  ),

                // Question image - MUCH LARGER
                if (hasQuestionImage)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildQuestionImage(question, index),
                  ),

                // Answer section
                Obx(() => _buildAnswerSection(
                      index: index,
                      question: question,
                      gradient: gradient,
                    )),
              ],
            ),
          ),

          // Question number badge
          Positioned(
            top: -12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Q${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Question Image Zoom Badge (Top Right)
          if (hasQuestionImage)
            Positioned(
              top: -12,
              right: 16,
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
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Zoom',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionImage(Map<String, dynamic> question, int index) {
    return GestureDetector(
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
      child: Stack(
        children: [
          Hero(
            tag: 'image_$index',
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent, // Changed to transparent
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: question['imageUrl'],
                  fit: BoxFit.fitWidth, // fitWidth to show full content
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 200, // Default height for loader
                    color: Colors.black.withOpacity(0.03),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.accentBlue,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading image...',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
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
                          Icons.broken_image_rounded,
                          color: AppTheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: AppTheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection({
    required int index,
    required Map<String, dynamic> question,
    required LinearGradient gradient,
  }) {
    final hasAnswer = (question['correctAnswer'] != null &&
            question['correctAnswer'].toString().isNotEmpty) ||
        (question['correctAnswerImage'] != null &&
            question['correctAnswerImage'].toString().isNotEmpty);
    final hasExplanation = question['explanation'] != null &&
        question['explanation'].toString().isNotEmpty;

    if (!hasAnswer && !hasExplanation) return const SizedBox.shrink();

    final isVisible = visibleAnswers.contains(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // Reveal Answer Button - Large and prominent
        GestureDetector(
          onTap: () => _toggleAnswerVisibility(index),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: isVisible
                  ? LinearGradient(
                      colors: [
                        AppTheme.accentGreen.withOpacity(0.3),
                        AppTheme.accentGreen.withOpacity(0.1),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        gradient.colors.first.withOpacity(0.2),
                        gradient.colors.last.withOpacity(0.1),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isVisible
                    ? AppTheme.accentGreen.withOpacity(0.3)
                    : gradient.colors.first.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color:
                      isVisible ? AppTheme.accentGreen : gradient.colors.first,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isVisible ? 'Hide Answer' : 'Reveal Answer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isVisible
                        ? AppTheme.accentGreen
                        : gradient.colors.first,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Answer content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isVisible
              ? Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildAnswerContent(question, index),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAnswerContent(Map<String, dynamic> question, int index) {
    final hasTextAnswer = question['correctAnswer'] != null &&
        question['correctAnswer'].toString().isNotEmpty;
    final hasImageAnswer = question['correctAnswerImage'] != null &&
        question['correctAnswerImage'].toString().isNotEmpty;
    final hasExplanation = question['explanation'] != null &&
        question['explanation'].toString().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Answer header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.accentGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Solutions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGreen,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ),
              if (hasImageAnswer) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => ImageZoomScreen(
                        imageUrl: question['correctAnswerImage'],
                        index: index + 1000,
                      ),
                      transition: Transition.fadeIn,
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.zoom_in_rounded,
                          color: AppTheme.accentGreen,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Zoom',
                          style: TextStyle(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Text answer
          if (hasTextAnswer)
            _buildContentSection(
              text: question['correctAnswer'],
              isQuestion: false,
            ),

          // Image answer
          if (hasImageAnswer)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildAnswerImage(question['correctAnswerImage'], index),
            ),

          // Explanation
          if (hasExplanation) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentBlue.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: AppTheme.accentYellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Explanation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildContentSection(
                    text: question['explanation'],
                    isQuestion: false,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerImage(String imageUrl, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => ImageZoomScreen(
            imageUrl: imageUrl,
            index: index + 1000,
          ),
          transition: Transition.fadeIn,
        );
      },
      child: Hero(
        tag: 'image_${index + 1000}',
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.transparent, // Paper design: transparent
                border: Border.all(
                  color: AppTheme.accentGreen.withOpacity(0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit:
                      BoxFit.fitWidth, // Paper design: fitWidth to show content
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.black.withOpacity(0.03), // Light placeholder
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentGreen,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          color: AppTheme.error,
                          size: 36,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: AppTheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required String text,
    required bool isQuestion,
  }) {
    final containsLatex = text.trim().contains(r'$');

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: CustomPaint(
        painter: LinedPaperPainter(
          lineHeight: 40, // Match text height
          lineColor: AppTheme.accentBlue.withOpacity(0.3),
          midlineColor: Colors.transparent, // Simple lines for readability
          redLineColor: Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: containsLatex
              ? TeXView(
                  child: TeXViewDocument(
                    '''
                    <p style="font-family: 'Patrick Hand', cursive; font-size:${isQuestion ? 24 : 20}px; color: black; line-height: 2.0; padding: 10px;">${text.replaceAll(r'$', '')}</p>
                    ''',
                    style: const TeXViewStyle(
                      textAlign: TeXViewTextAlign.left,
                      padding: TeXViewPadding.all(6),
                    ),
                  ),
                  style: TeXViewStyle(
                    backgroundColor: Colors.transparent,
                    borderRadius: const TeXViewBorderRadius.all(10),
                    elevation: 0,
                  ),
                  loadingWidgetBuilder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentBlue,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : SelectableText(
                  text,
                  style: TextStyle(
                    fontFamily: 'Patrick Hand',
                    fontSize: isQuestion ? 24 : 20, // Larger handwritten text
                    height: 2.0, // Match line height (20 * 2.0 = 40)
                    fontWeight:
                        isQuestion ? FontWeight.w600 : FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }

  void _showZoomHelpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: AppTheme.accentBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Study Tips',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _buildHelpItem(
                  Icons.visibility_rounded, 'Toggle answers to test yourself'),
              _buildHelpItem(Icons.zoom_in_rounded,
                  'Tap images to zoom for better viewing'),
              _buildHelpItem(
                  Icons.touch_app_rounded, 'Individual answers can be toggled'),
              _buildHelpItem(Icons.lightbulb_rounded,
                  'Read explanations to understand better'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: AppTheme.primaryButtonStyle,
                child: const Text('Got it!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
