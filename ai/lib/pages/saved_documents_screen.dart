import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/saved_documents_controller.dart';
import '../theme/app_theme.dart';
import 'pdf_viewer_screen.dart';
import 'dart:io';

class SavedDocumentsScreen extends StatelessWidget {
  const SavedDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = SavedDocumentsController.instance;

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by MainScreen
      appBar: AppBar(
        title: const Text(
          'Saved Documents',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.savedDocuments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Saved Documents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PDFs you view will appear here for offline access.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100, left: 16, right: 16),
          itemCount: controller.savedDocuments.length,
          itemBuilder: (context, index) {
            final doc = controller.savedDocuments[index];
            return _buildDocumentCard(context, doc, controller);
          },
        );
      }),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    SavedDocument doc,
    SavedDocumentsController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key(doc.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red.shade400,
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (_) {
            controller.removeDocument(doc.id);
            Get.snackbar(
              'Document Removed',
              '${doc.title} has been deleted from your device.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.cardBackground,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                // Check if file still exists
                final file = File(doc.localPath);
                if (await file.exists()) {
                  Get.to(() => PdfViewerScreen(
                        pdfUrl: doc.url,
                        title: doc.title,
                      ));
                } else {
                  // File missing
                  controller.removeDocument(doc.id);
                  Get.snackbar(
                    'File Not Found',
                    'The downloaded file no longer exists. Please redownload it.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade900,
                    colorText: Colors.white,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: AppTheme.accentBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${doc.savedAt.day.toString().padLeft(2, '0')}/${doc.savedAt.month.toString().padLeft(2, '0')}/${doc.savedAt.year} • ${doc.savedAt.hour.toString().padLeft(2, '0')}:${doc.savedAt.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.3),
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
