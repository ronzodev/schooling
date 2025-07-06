import 'dart:math' as math;

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

  final List<Color> colorPalette = [
    Colors.teal,
    Colors.deepPurple,
    Colors.green.shade700,
    Colors.indigo,
    Colors.orange.shade800,
    Colors.pink.shade600,
    Colors.blue.shade800,
    Colors.amber.shade700,
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

            final cardColor = colorPalette[index % colorPalette.length];

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
                    cardColor: cardColor,
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
    required this.cardColor,
  });

  final bool showFront;
  final bool isFocused;
  final Map<String, dynamic> topic;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: showFront
            ? _buildFrontCard()
            : Transform.flip(
                flipY: true,
                child: _buildBackCard(),
              ),
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      decoration: BoxDecoration(
        color: isFocused ? cardColor : cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.5),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topic['title'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isFocused ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (isFocused) ...[
            const SizedBox(height: 10),
            Text(
              'Tap to view questions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade500,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          topic['title'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
