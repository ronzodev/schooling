import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SavedDocument {
  final String id;
  final String title;
  final String url;
  final String localPath;
  final DateTime savedAt;

  SavedDocument({
    required this.id,
    required this.title,
    required this.url,
    required this.localPath,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'localPath': localPath,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedDocument.fromJson(Map<String, dynamic> json) => SavedDocument(
        id: json['id'],
        title: json['title'],
        url: json['url'],
        localPath: json['localPath'],
        savedAt: DateTime.parse(json['savedAt']),
      );
}

class SavedDocumentsController extends GetxController {
  static SavedDocumentsController get instance => Get.find();

  final _storage = GetStorage();
  final _storageKey = 'saved_documents';

  RxList<SavedDocument> savedDocuments = <SavedDocument>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDocuments();
  }

  void _loadDocuments() {
    final List<dynamic>? storedDocs = _storage.read<List<dynamic>>(_storageKey);
    if (storedDocs != null) {
      final now = DateTime.now();
      final validDocs = <SavedDocument>[];
      bool needsPersist = false;

      for (var e in storedDocs) {
        final doc = SavedDocument.fromJson(Map<String, dynamic>.from(e));
        // Check if document is 3 or more days old
        if (now.difference(doc.savedAt).inDays >= 3) {
          // Delete physical file
          try {
            final file = File(doc.localPath);
            if (file.existsSync()) {
              file.deleteSync();
            }
          } catch (e) {
            print("Error deleting expired local file: $e");
          }
          needsPersist = true;
        } else {
          validDocs.add(doc);
        }
      }

      savedDocuments.value = validDocs;
      // Sort by newest first
      savedDocuments.sort((a, b) => b.savedAt.compareTo(a.savedAt));

      if (needsPersist) {
        _persist();
      }
    }
  }

  Future<void> saveDocument({
    required String id,
    required String title,
    required String url,
    required String localPath,
  }) async {
    // Check if already exists
    final index = savedDocuments.indexWhere((doc) => doc.id == id);
    if (index != -1) {
      // Update existing
      savedDocuments[index] = SavedDocument(
        id: id,
        title: title,
        url: url,
        localPath: localPath,
        savedAt: DateTime.now(),
      );
    } else {
      // Add new
      savedDocuments.insert(
        0,
        SavedDocument(
          id: id,
          title: title,
          url: url,
          localPath: localPath,
          savedAt: DateTime.now(),
        ),
      );
    }
    await _persist();
  }

  Future<void> removeDocument(String id) async {
    final doc = savedDocuments.firstWhereOrNull((d) => d.id == id);
    if (doc != null) {
      savedDocuments.remove(doc);
      await _persist();
      // Also delete the physical file if it exists
      try {
        final file = File(doc.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print("Error deleting local file: $e");
      }
    }
  }

  Future<void> _persist() async {
    final jsonList = savedDocuments.map((e) => e.toJson()).toList();
    await _storage.write(_storageKey, jsonList);
  }
}
