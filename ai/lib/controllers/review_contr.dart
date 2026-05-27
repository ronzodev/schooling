import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'review_controller.dart';

class AppReviewController extends GetxController {
  static AppReviewController get instance => Get.find();

  final InAppReview _inAppReview = InAppReview.instance;

  // ── Thresholds ────────────────────────────────────────────────────────────
  static const int _requiredPdfViews = 4;      // open 4 PDFs before eligible
  static const int _requiredAnswerReveals = 10; // OR reveal 10 answers
  static const int _maxPromptCount = 3;          // never prompt > 3 times ever
  static const int _daysBetweenPrompts = 14;     // at least 14 days between prompts

  // Set true ONLY for local testing — MUST be false for production builds
  static const bool _isTesting = false;

  // ── Public trigger: called when user opens a PDF ──────────────────────────
  Future<void> onPdfOpened() async {
    await LocalStorageUtils.incrementPdfViewCount();
    final pdfViews = LocalStorageUtils.getPdfViewCount();
    debugPrint('AppReview: PDF opened. Total views: $pdfViews');

    if (_isTesting) {
      debugPrint('AppReview: [TEST] Bypassing all checks.');
      await _tryRequestReview();
      return;
    }

    if (pdfViews < _requiredPdfViews) {
      debugPrint('AppReview: Not enough PDF views ($pdfViews/$_requiredPdfViews).');
      return;
    }
    await _tryRequestReview();
  }

  // ── Public trigger: called when user reveals an answer ───────────────────
  Future<void> onAnswerRevealed() async {
    await LocalStorageUtils.incrementAnswerRevealCount();
    final reveals = LocalStorageUtils.getAnswerRevealCount();
    debugPrint('AppReview: Answer revealed. Total reveals: $reveals');

    if (_isTesting) {
      await _tryRequestReview();
      return;
    }

    if (reveals < _requiredAnswerReveals) {
      debugPrint('AppReview: Not enough reveals ($reveals/$_requiredAnswerReveals).');
      return;
    }
    await _tryRequestReview();
  }

  // ── Public trigger: called once per app session (from MyApp) ─────────────
  // Prompts returning users who are already highly engaged but haven't been
  // asked in a while.
  Future<void> onAppSession() async {
    if (_isTesting) return; // Don't spam during dev sessions

    final pdfViews = LocalStorageUtils.getPdfViewCount();
    if (pdfViews < _requiredPdfViews) return; // Not engaged enough yet

    // Only bother checking if time constraint would pass
    final lastPrompt = LocalStorageUtils.getAppReviewLastPrompt();
    if (lastPrompt != null) {
      final days = DateTime.now().difference(lastPrompt).inDays;
      if (days < _daysBetweenPrompts) return; // Too soon
    }

    await _tryRequestReview();
  }

  // ── Core review request logic ─────────────────────────────────────────────
  Future<void> _tryRequestReview() async {
    try {
      // Check prompt count cap
      final promptCount = LocalStorageUtils.getAppReviewPromptCount();
      if (!_isTesting && promptCount >= _maxPromptCount) {
        debugPrint('AppReview: Max prompts reached ($promptCount/$_maxPromptCount). Skipping.');
        return;
      }

      // Check time gate
      if (!_isTesting) {
        final lastPrompt = LocalStorageUtils.getAppReviewLastPrompt();
        if (lastPrompt != null) {
          final daysSince = DateTime.now().difference(lastPrompt).inDays;
          if (daysSince < _daysBetweenPrompts) {
            debugPrint('AppReview: Too soon ($daysSince/$_daysBetweenPrompts days). Skipping.');
            return;
          }
        }
      }

      // Check native availability
      final isAvailable = await _inAppReview.isAvailable();
      debugPrint('AppReview: isAvailable = $isAvailable');

      if (!isAvailable) {
        debugPrint('AppReview: Native dialog not available (emulator / no Play Store). Skipping silently.');
        return;
      }

      // Brief delay so the review dialog appears after user finishes their task
      // (Google recommends not interrupting an active flow)
      await Future.delayed(const Duration(seconds: 2));

      debugPrint('AppReview: Requesting in-app review dialog.');
      await _inAppReview.requestReview();

      // Record that we prompted
      await LocalStorageUtils.saveAppReviewLastPrompt(DateTime.now());
      await LocalStorageUtils.incrementAppReviewPromptCount();
      debugPrint('AppReview: Review dialog requested successfully.');
    } catch (e) {
      // Never let review logic crash the app
      debugPrint('AppReview: Caught exception (silently swallowed): $e');
    }
  }
}
