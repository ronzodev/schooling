import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../widgets/no_connection_widget.dart';
import '../services/pdf_cache_service.dart';
import '../controllers/review_contr.dart';

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
  PdfControllerPinch? _pdfController;

  // ValueNotifiers — only the specific widgets rebuild, not the whole tree.
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(1);
  final ValueNotifier<int> _totalPagesNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> _downloadProgressNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isDocumentReadyNotifier =
      ValueNotifier<bool>(false);

  bool _hasError = false;
  bool _isDownloading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final file = await PdfCacheService.instance.getOrDownload(
        widget.pdfUrl,
        title: widget.title,
        onProgress: (progress) {
          _downloadProgressNotifier.value = progress;
        },
      );
      if (mounted) {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(file.path),
        );
        setState(() {
          _isDownloading = false;
        });
      }
    } catch (e) {
      debugPrint('PDF download error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isDownloading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _currentPageNotifier.dispose();
    _totalPagesNotifier.dispose();
    _downloadProgressNotifier.dispose();
    _isDocumentReadyNotifier.dispose();
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
                  ? [Colors.deepPurple.shade900, Colors.indigo.shade900]
                  : [Colors.deepPurple.shade700, Colors.indigo.shade700],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _hasError
            ? _buildErrorUI()
            : Stack(
                children: [
                  // ── PDF Viewer ──────────────────────────────────────────
                  if (_pdfController != null)
                    RepaintBoundary(
                      child: PdfViewPinch(
                        controller: _pdfController!,
                        padding: 4,
                        backgroundDecoration: const BoxDecoration(
                          color: Color(0xFF1A1A2E),
                        ),
                        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                          options: const DefaultBuilderOptions(),
                          documentLoaderBuilder: (_) => const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.accentBlue,
                              strokeWidth: 3,
                            ),
                          ),
                          pageLoaderBuilder: (_) => const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                color: AppTheme.accentBlue,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorBuilder: (_, error) => Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: AppTheme.error, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'Failed to render page',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onDocumentLoaded: (PdfDocument document) {
                          _totalPagesNotifier.value = document.pagesCount;
                          _isDocumentReadyNotifier.value = true;
                          
                          // Trigger the app review flow logic only AFTER the PDF is successfully rendered
                          // This prevents the native review dialog from crashing the native PDF renderer during load
                          AppReviewController.instance.onPdfOpened();
                        },
                        onPageChanged: (int page) {
                          _currentPageNotifier.value = page;
                        },
                      ),
                    ),

                  // ── Download progress overlay ───────────────────────────
                  if (_isDownloading) _buildDownloadOverlay(),

                  // ── Side-rail page indicator (only rebuilds via ValueNotifier) ──
                  ValueListenableBuilder<bool>(
                    valueListenable: _isDocumentReadyNotifier,
                    builder: (_, isReady, __) {
                      if (!isReady) return const SizedBox.shrink();
                      return _buildSideRailIndicator();
                    },
                  ),
                ],
              ),
      ),
    );
  }

  /// Full-screen overlay showing download percentage.
  Widget _buildDownloadOverlay() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ValueListenableBuilder<double>(
            valueListenable: _downloadProgressNotifier,
            builder: (_, progress, __) {
              final pct = (progress * 100).clamp(0, 100).toInt();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular progress with percentage inside
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(
                            value: progress > 0 ? progress : null,
                            strokeWidth: 4,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.accentBlue),
                            backgroundColor:
                                AppTheme.accentBlue.withValues(alpha: 0.12),
                          ),
                        ),
                        Text(
                          progress > 0 ? '$pct%' : '…',
                          style: const TextStyle(
                            color: AppTheme.accentBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Downloading…',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    progress > 0
                        ? 'Fetching document • $pct%'
                        : 'Connecting to server…',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Right-edge page indicator that slides vertically with scroll position.
  Widget _buildSideRailIndicator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Usable vertical range for the indicator (leave padding at top/bottom)
        const topPad = 16.0;
        const bottomPad = 40.0;
        final railHeight = constraints.maxHeight - topPad - bottomPad - 44;

        return ValueListenableBuilder<int>(
          valueListenable: _totalPagesNotifier,
          builder: (_, totalPages, __) {
            if (totalPages == 0) return const SizedBox.shrink();
            return ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (_, currentPage, __) {
                // Position: fraction through the document
                final fraction =
                    ((currentPage - 1) / (totalPages - 1).clamp(1, totalPages))
                        .clamp(0.0, 1.0);
                final topOffset = topPad + (fraction * railHeight);

                return Stack(
                  children: [
                    // Subtle vertical track line
                    Positioned(
                      right: 6,
                      top: topPad + 22,
                      bottom: bottomPad + 22,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                    // Moving page tab
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      right: 0,
                      top: topOffset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.accentBlue.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(-2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$currentPage',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                height: 1,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              width: 10,
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            Text(
                              '$totalPages',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildErrorUI() {
    return NoConnectionWidget(
      title: 'Unable to Load PDF',
      message:
          'Something went wrong while loading the PDF. Check your connection and try again.',
      onRetry: () {
        Get.off(() => PdfViewerScreen(
              pdfUrl: widget.pdfUrl,
              title: widget.title,
            ));
      },
    );
  }
}
