import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/no_connection_widget.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            PDF(
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: false,
              fitPolicy: FitPolicy.WIDTH,
              onError: (error) {
                debugPrint('PDF error: $error');
              },
              onPageError: (page, error) {
                debugPrint('PDF page $page error: $error');
              },
            ).cachedFromUrl(
              widget.pdfUrl,
              placeholder: (progress) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress / 100,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading PDF... ${progress.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              errorWidget: (error) => _buildErrorUI(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return NoConnectionWidget(
      title: 'Unable to Load PDF',
      message:
          'Something went wrong while loading the PDF. Check your connection and try again.',
      onRetry: () {
        // Force rebuild by navigating again
        Get.off(() => PdfViewerScreen(
              pdfUrl: widget.pdfUrl,
              title: widget.title,
            ));
      },
    );
  }
}
