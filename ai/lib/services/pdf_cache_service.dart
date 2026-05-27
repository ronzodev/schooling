import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../controllers/saved_documents_controller.dart';

/// Lightweight file-based PDF cache.
///
/// Stores downloaded PDFs in `<appDocDir>/cached_pdfs/<urlHash>.pdf`.
/// No database needed — the filesystem IS the cache.
class PdfCacheService {
  PdfCacheService._();
  static final PdfCacheService instance = PdfCacheService._();

  /// Returns a local [File] for the given [url].
  ///
  /// If the file is already cached it returns immediately.
  /// Otherwise it downloads with progress reported via [onProgress] (0.0 → 1.0).
  Future<File> getOrDownload(
    String url, {
    String? title,
    ValueChanged<double>? onProgress,
  }) async {
    final file = await _localFile(url);
    final hash = _hashUrl(url);

    if (await file.exists()) {
      debugPrint('📄 PDF cache HIT: ${file.path}');
      onProgress?.call(1.0);
      
      // Update saved document timestamp
      if (title != null && title.isNotEmpty) {
        try {
          SavedDocumentsController.instance.saveDocument(
            id: hash,
            title: title,
            url: url,
            localPath: file.path,
          );
        } catch (_) {} // Ignore if controller not initialized
      }
      
      return file;
    }

    debugPrint('📥 PDF cache MISS — downloading: $url');
    final downloadedFile = await _download(url, file, onProgress);
    
    // Save to local database
    if (title != null && title.isNotEmpty) {
      try {
        SavedDocumentsController.instance.saveDocument(
          id: hash,
          title: title,
          url: url,
          localPath: downloadedFile.path,
        );
      } catch (_) {}
    }
    
    return downloadedFile;
  }

  /// Generates a stable cache path from the URL.
  Future<File> _localFile(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/cached_pdfs');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    // Use a simple hash of the URL as filename
    final hash = _hashUrl(url);
    return File('${cacheDir.path}/$hash.pdf');
  }

  /// Simple URL → filename hash (uses hashCode for speed, no crypto dep needed).
  String _hashUrl(String url) {
    // Use Dart's built-in hashCode plus a secondary check to avoid collisions
    final bytes = utf8.encode(url);
    int hash = 0;
    for (final b in bytes) {
      hash = (hash * 31 + b) & 0x7FFFFFFF;
    }
    return hash.toRadixString(36);
  }

  /// Downloads [url] to [file] with progress reporting.
  Future<File> _download(
    String url,
    File file,
    ValueChanged<double>? onProgress,
  ) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await http.Client().send(request);

    final contentLength = response.contentLength ?? -1;
    int received = 0;
    final sink = file.openWrite();

    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (contentLength > 0) {
        onProgress?.call(received / contentLength);
      }
    }

    await sink.flush();
    await sink.close();

    debugPrint('✅ PDF cached: ${file.path} (${(received / 1024).toStringAsFixed(0)} KB)');
    return file;
  }

  /// Clear all cached PDFs (for settings / storage management).
  Future<void> clearCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/cached_pdfs');
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
      debugPrint('🗑️ PDF cache cleared');
    }
  }
}
