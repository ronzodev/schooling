import 'package:get_storage/get_storage.dart';

class LocalStorageUtils {
  LocalStorageUtils._();

  static final _storage = GetStorage();

  // Storage keys
  static const String _keyAppReviewLastPrompt    = 'app_review_last_prompt';
  static const String _keyAppReviewPromptCount   = 'app_review_prompt_count';
  static const String _keyPdfViewCount           = 'pdf_view_count';
  static const String _keyAnswerRevealCount      = 'answer_reveal_count';

  // ── App Review: last prompt timestamp ────────────────────────────────────

  static Future<void> saveAppReviewLastPrompt(DateTime timestamp) async {
    await _storage.write(_keyAppReviewLastPrompt, timestamp.toIso8601String());
  }

  static DateTime? getAppReviewLastPrompt() {
    final raw = _storage.read<String>(_keyAppReviewLastPrompt);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  // ── App Review: prompt count ──────────────────────────────────────────────

  static Future<void> saveAppReviewPromptCount(int count) async {
    await _storage.write(_keyAppReviewPromptCount, count);
  }

  static int getAppReviewPromptCount() {
    return _storage.read<int>(_keyAppReviewPromptCount) ?? 0;
  }

  static Future<void> incrementAppReviewPromptCount() async {
    await saveAppReviewPromptCount(getAppReviewPromptCount() + 1);
  }

  // ── PDF view count ────────────────────────────────────────────────────────

  static int getPdfViewCount() {
    return _storage.read<int>(_keyPdfViewCount) ?? 0;
  }

  static Future<void> incrementPdfViewCount() async {
    await _storage.write(_keyPdfViewCount, getPdfViewCount() + 1);
  }

  // ── Answer reveal count ───────────────────────────────────────────────────

  static int getAnswerRevealCount() {
    return _storage.read<int>(_keyAnswerRevealCount) ?? 0;
  }

  static Future<void> incrementAnswerRevealCount() async {
    await _storage.write(_keyAnswerRevealCount, getAnswerRevealCount() + 1);
  }
}
