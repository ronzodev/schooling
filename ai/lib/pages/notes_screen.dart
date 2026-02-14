import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notes_controller.dart';
import '../controllers/ads_controller.dart';
import '../theme/app_theme.dart';

import 'pdf_viewer_screen.dart';

class NotesScreen extends StatelessWidget {
  static int _clickCount = 0;

  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotesController());

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accentOrange),
                    );
                  }

                  if (controller.courses.isEmpty) {
                    return const Center(
                      child: Text(
                        'No courses found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.courses.length,
                    itemBuilder: (context, index) {
                      final course = controller.courses[index];
                      return _buildCourseCard(course, index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'My Notes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> courseData, int index) {
    // Get color from data or fallback to index-based
    final colorString = courseData['color'] as String? ?? 'accentBlue';
    final color = _getColor(colorString);
    final title = courseData['courseName'] ?? 'Unknown Course';
    final iconName = courseData['icon'] as String? ?? 'folder_rounded';
    final List files = courseData['files'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              getIconForNote(iconName),
              color: color,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            '${files.length} Notes',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            if (files.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No notes available yet.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              )
            else
              ...files.map((file) {
                final fileIndex = file['index'] ?? 0;
                final fileTitle = file['title'] ?? 'Note $fileIndex';
                final fileLink = file['link'] ?? '';
                return _buildFileItem(fileIndex, fileTitle, fileLink, color);
              }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(var index, String title, String link, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          if (link.isNotEmpty) {
            // Increment click count
            NotesScreen._clickCount++;

            // Check if we should show ad (every 2nd click)
            if (NotesScreen._clickCount % 2 == 0 &&
                GoogleAdsController.instance.isInterstitialReady()) {
              // Set callback to navigate after ad closes
              GoogleAdsController.instance.onInterstitialClosed = () {
                Get.to(() => PdfViewerScreen(
                      pdfUrl: link,
                      title: title,
                    ));
                // Clear callback to avoid unwanted trimming
                GoogleAdsController.instance.onInterstitialClosed = null;
              };

              // Show the ad
              GoogleAdsController.instance.showInterstitialAd();
            } else {
              // Navigate directly if not 2nd click or ad not ready
              Get.to(() => PdfViewerScreen(
                    pdfUrl: link,
                    title: title,
                  ));
            }
          } else {
            Get.snackbar('Error', 'Invalid PDF link');
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: color.withOpacity(0.7),
        ),
      ),
    );
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'accentBlue':
        return AppTheme.accentBlue;
      case 'accentGreen':
        return AppTheme.accentGreen;
      case 'accentPink':
        return AppTheme.accentPink;
      case 'accentPurple':
        return AppTheme.accentPurple;
      case 'accentOrange':
        return AppTheme.accentOrange;
      default:
        return AppTheme.accentBlue;
    }
  }

  IconData getIconForNote(String? iconName) {
    switch (iconName) {
      case 'functions_rounded':
        return Icons.functions_rounded;
      case 'square_foot_rounded':
        return Icons.square_foot_rounded;
      case 'eco_rounded':
        return Icons.eco_rounded;
      case 'science_rounded':
        return Icons.science_rounded;
      case 'menu_book_rounded':
        return Icons.menu_book_rounded;
      case 'history_edu_rounded':
        return Icons.history_edu_rounded;
      case 'bolt_rounded':
        return Icons.bolt_rounded;
      case 'folder_rounded': // Added for course cards
        return Icons.folder_rounded;
      default:
        return Icons.note_rounded;
    }
  }
}
