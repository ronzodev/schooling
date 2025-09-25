import 'dart:math' as math;
import 'dart:ui';

import 'package:ai/pages/questions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/topic_controller.dart';

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

  final List<List<Color>> gradientPalette = [
    [const Color(0xFF667eea),const Color(0xFF764ba2)],
    [const Color(0xFFf093fb),const  Color(0xFFf5576c)],
    [const Color(0xFF4facfe),const Color(0xFF00f2fe)],
    [const Color(0xFF43e97b),const Color(0xFF38f9d7)],
    [const Color(0xFFfa709a),const Color(0xFFfee140)],
    [const Color(0xFF30cfd0),const Color(0xFFa8edea)],
    [const Color(0xFF667eea),const Color(0xFF764ba2)],
    [const Color(0xFFffeaa7),const Color(0xFFfab1a0)],
  ];

  @override
  void initState() {
    super.initState();

    topicController.setupRealtimeTopics(widget.courseId);

    const initialPage = 2;
    _controller = PageController(
      viewportFraction: 0.24,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Topics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
      ),
      body: Obx(() {
        if (topicController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (topicController.topics.isEmpty) {
          return const Center(
              child: Text(
                  "No internet connection and no cached topics available"));
        }

        return PageView.builder(
          itemCount: topicController.topics.length,
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
                    : 0;

            const maxScale = 1.15;
            final double scaleValue = isCurrentPageAnimating
                ? 1 + (maxScale - 1) * (1 - progress)
                : isNextPageAnimating
                    ? 1 + (maxScale - 1) * progress
                    : 1;

            bool showFront = rotateXAngle > -90 && rotateXAngle < 90;

            final gradientColors = gradientPalette[index % gradientPalette.length];

            return GestureDetector(
              onTap: () {
                if (isCurrentPageAnimating || isNextPageAnimating) {
                  final topic = topicController.topics[index];
                  Get.to(() => QuestionListScreen(
                      courseId: widget.courseId, topicId: topic['id']));
                }
              },
              child: Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .001)
                    ..rotateZ(rotateZAngle * math.pi / 180)
                    ..rotateX(rotateXAngle * math.pi / 180)
                    ..scale(scaleValue, scaleValue),
                  child: _TopicCard(
                    topic: topicController.topics[index],
                    showFront: showFront,
                    isFocused: isCurrentPageAnimating || isNextPageAnimating,
                    gradientColors: gradientColors,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.isFocused,
    required this.showFront,
    required this.gradientColors,
  });

  final bool showFront;
  final bool isFocused;
  final Map<String, dynamic> topic;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    // Fixed card dimensions for consistency
    const cardWidth = 320.0; // Fixed width instead of responsive
    const cardHeight = 220.0; // Fixed height instead of responsive

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: showFront
            ? _buildFrontCard(context, cardWidth, cardHeight)
            : Transform.flip(
                flipY: true,
                child: _buildBackCard(context, cardWidth, cardHeight),
              ),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFocused
              ? gradientColors
              : gradientColors.map((c) => c.withOpacity(0.7)).toList(),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content with guaranteed centering
          SizedBox(
            width: width,
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Icon container - fixed size
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Fixed spacing
                  
                  // Text with explicit centering and constraints
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center, // Force center alignment
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: width - 40, // Account for padding
                            maxHeight: height - 130, // Account for icon + spacing + padding
                          ),
                          child: Text(
                            topic['title'] ?? 'Topic',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isFocused ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            maxLines: 4,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action hint overlay - positioned at top-left corner
          if (isFocused)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackCard(BuildContext context, double width, double height) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)]
                    : [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.05)],
              ),
            ),
            child: SizedBox(
              width: width,
              height: height,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      Icons.flip_to_front_rounded,
                      size: 50, // Fixed size matching front card
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                    
                    const SizedBox(height: 16), // Fixed spacing matching front
                    
                    // Text with explicit centering - same approach as front
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center, // Force center alignment
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: width - 40, // Account for padding
                              maxHeight: height - 130, // Account for icon + spacing + padding
                            ),
                            child: Text(
                              topic['title'] ?? 'Topic',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black.withOpacity(0.9),
                                height: 1.3,
                              ),
                              maxLines: 4,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}