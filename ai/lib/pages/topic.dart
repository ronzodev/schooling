import 'dart:math' as math;

import 'package:ai/pages/questions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ads_controller.dart';
import '../controllers/topic_controller.dart';
import '../theme/app_theme.dart';
import '../utils/icon_helper.dart';
import '../widgets/no_connection_widget.dart';

class TopicListScreen extends StatefulWidget {
  final String courseId;

  const TopicListScreen({super.key, required this.courseId});

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  late final PageController _controller;
  late double _currentPage;
  final TopicController topicController = Get.put(TopicController());

  // Playful gradient palette
  final List<LinearGradient> gradientPalette = [
    AppTheme.blueGradient,
    AppTheme.pinkGradient,
    AppTheme.purpleGradient,
    AppTheme.greenGradient,
    AppTheme.orangeGradient,
  ];

  @override
  void initState() {
    super.initState();
    // Load cached topics immediately for instant display
    topicController.loadCachedTopicsImmediately(widget.courseId);
    // Then setup realtime updates
    topicController.setupRealtimeTopics(widget.courseId);

    const initialPage = 2;
    _controller = PageController(
      viewportFraction: 0.35, // Increased from 0.28 to fit larger cards
      initialPage: initialPage,
    );
    _currentPage = initialPage.toDouble();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

              // Header
              _buildHeader(),

              // Topics carousel
              Expanded(
                child: Obx(() => _buildTopicsCarousel()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
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
            'Topics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const Spacer(),

          // Placeholder for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          const Text(
            'Choose a Topic',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe up or down to explore topics',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsCarousel() {
    if (topicController.isLoading.value) {
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
              'Loading topics...',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    if (topicController.topics.isEmpty) {
      if (topicController.errorMessage.isNotEmpty) {
        return NoConnectionWidget(
          onRetry: () => topicController.refreshTopics(),
          message: topicController.errorMessage.value,
        );
      }
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
                Icons.topic_rounded,
                size: 48,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No topics available',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textPrimary,
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

    // Calculate total items including ads
    // We insert an ad after every 3 topics
    // Pattern: T T T A T T T A ...
    final int topicCount = topicController.topics.length;
    final int adCount = topicCount ~/ 3;
    final int totalItems = topicCount + adCount;

    return PageView.builder(
      itemCount: totalItems,
      controller: _controller,
      scrollDirection: Axis.vertical,
      itemBuilder: (context, index) {
        final progress = _currentPage % 1;
        final currentPageInt = _currentPage.toInt();
        final isCurrentPageAnimating = currentPageInt == index;
        final isNextPageAnimating = currentPageInt + 1 == index;
        final indexSmallerThanCurrentPage = currentPageInt >= index;

        const rotationsAngle = [0, 110, 187, 280, 360];
        final maxRotations = rotationsAngle.length;
        final lastRotationsAngleIndex = maxRotations - 1;

        final rotateXStartIndex = math.min(
          (currentPageInt - index).abs(),
          lastRotationsAngleIndex,
        );

        final rotateXEndIndex = switch (indexSmallerThanCurrentPage) {
          true => math.min(rotateXStartIndex + 1, lastRotationsAngleIndex),
          false => math.min(rotateXStartIndex - 1, lastRotationsAngleIndex),
        };

        final rotateXStartAngle = rotationsAngle[rotateXStartIndex];
        final rotateXEndAngle = rotationsAngle[rotateXEndIndex];

        final rotateXAngle = switch (indexSmallerThanCurrentPage) {
          true => -(rotateXStartAngle +
              ((rotateXEndAngle - rotateXStartAngle) * progress)),
          false => (rotateXStartAngle +
              ((rotateXEndAngle - rotateXStartAngle) * progress)),
        };

        const maxRotateZAngle = -7.5;
        final rotateZAngle = isCurrentPageAnimating
            ? maxRotateZAngle * (1 - progress)
            : isNextPageAnimating
                ? maxRotateZAngle * progress
                : 0.0;

        const maxScale = 1.15;
        final double scaleValue = isCurrentPageAnimating
            ? 1 + (maxScale - 1) * (1 - progress)
            : isNextPageAnimating
                ? 1 + (maxScale - 1) * progress
                : 1;

        // Check if this index is an ad
        // Indices: 0, 1, 2, 3(Ad), 4, 5, 6, 7(Ad)...
        // (index + 1) % 4 == 0 means it's an ad
        final isAd = (index + 1) % 4 == 0;

        // Dampen rotation for ads, especially when focused or near focus
        double finalRotateZ = rotateZAngle.toDouble();
        double finalRotateX = rotateXAngle.toDouble();

        if (isAd) {
          // If it's an ad and it's becomes the primary focus, flatten it
          // This ensures the AdMob validator doesn't trigger for skewed content
          final double focusFactor = (isCurrentPageAnimating
              ? progress
              : (isNextPageAnimating ? (1 - progress) : 1.0));
          // If focusFactor is 0, it means it's perfectly centered
          finalRotateZ = rotateZAngle * (1 - (1 - focusFactor).clamp(0, 1));
          finalRotateX = rotateXAngle * (1 - (1 - focusFactor).clamp(0, 1));

          // Even simpler approach: if it's anywhere near focused, just flatten it
          if (focusFactor < 0.2) {
            finalRotateZ = 0;
            finalRotateX = 0;
          }
        }

        bool showFront = finalRotateX > -90 && finalRotateX < 90;

        // Calculate the actual topic index
        // If index is 3 (ad), topics before it are 0, 1, 2.
        // If index is 4 (topic), effective topic index is 3.
        // Ad count before this index = index ~/ 4
        final topicIndex = index - (index ~/ 4);

        // Gradient for topic cards
        final gradient = isAd
            ? AppTheme.blueGradient
            : gradientPalette[topicIndex % gradientPalette.length];

        final icon = isAd
            ? Icons.topic // Placeholder
            : IconHelper.getIconForTopic(
                topicController.topics[topicIndex]['title'] ?? '');

        return GestureDetector(
          onTap: () {
            if (!isAd && (isCurrentPageAnimating || isNextPageAnimating)) {
              final topic = topicController.topics[topicIndex];
              Get.to(
                () => QuestionListScreen(
                  courseId: widget.courseId,
                  topicId: topic['id'],
                ),
                transition: Transition.rightToLeft,
              );
            }
          },
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, .001)
                ..rotateZ(finalRotateZ * math.pi / 180)
                ..rotateX(finalRotateX * math.pi / 180)
                ..scale(scaleValue, scaleValue),
              child: isAd
                  ? _buildNativeAdCard(index ~/ 4) // Pass ad index
                  : _TopicCard(
                      topic: topicController.topics[topicIndex],
                      showFront: showFront,
                      isFocused: isCurrentPageAnimating || isNextPageAnimating,
                      gradient: gradient,
                      icon: icon,
                      index: topicIndex,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNativeAdCard(int index) {
    final adsController = GoogleAdsController.instance;

    // Use Obx to rebuild when ads are loaded/disposed
    return Obx(() {
      // Access the trigger to ensure rebuild
      // ignore: unused_local_variable
      final _ = adsController.adUpdateTrigger.value;

      final adWidget = adsController.getNativeAdWidget(
        width: 320,
        height: 320, // Increased from 250 to 320
        adIndex: index,
      );

      if (adWidget == null) return const SizedBox.shrink();

      return Container(
        width: 320,
        height: 320, // Increased from 250 to 320
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E), // Match native ad background
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: adWidget,
        ),
      );
    });
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.isFocused,
    required this.showFront,
    required this.gradient,
    required this.icon,
    required this.index,
  });

  final bool showFront;
  final bool isFocused;
  final Map<String, dynamic> topic;
  final LinearGradient gradient;
  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    const cardWidth = 320.0;
    const cardHeight = 320.0; // Increased to 320 for consistency with ad cards

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: showFront
            ? _buildFrontCard(cardWidth, cardHeight)
            : Transform.flip(
                flipY: true,
                child: _buildBackCard(cardWidth, cardHeight),
              ),
      ),
    );
  }

  Widget _buildFrontCard(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackground.withOpacity(0.95),
            AppTheme.cardBackgroundLight.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFocused
              ? gradient.colors.first.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: isFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? gradient.colors.first.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            blurRadius: isFocused ? 20 : 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                // Topic info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic['title'] ?? 'Topic',
                        style: TextStyle(
                          fontSize: isFocused ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 2, // Reduced from 3 to prevent overflow
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: gradient.colors.first.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Topic ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: gradient.colors.first,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                if (isFocused)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: gradient.colors.first,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),

          // Tap indicator
          if (isFocused)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: gradient.colors.first.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: gradient.colors.first,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap',
                      style: TextStyle(
                        fontSize: 10,
                        color: gradient.colors.first,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackCard(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flip_to_front_rounded,
              size: 40,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              topic['title'] ?? 'Topic',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
