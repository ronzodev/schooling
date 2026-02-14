import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ImageCarouselController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Observable variables
  var isLoading = true.obs;
  var images = <CarouselImage>[].obs;
  var errorMessage = ''.obs;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  // Fetch images from Firebase
  Future<void> fetchImages() async {
  try {
    isLoading.value = true;
    errorMessage.value = '';
    
    debugPrint('Fetching images from Firestore...');
    
    // TEMPORARY WORKAROUND - Remove orderBy until index is created
    QuerySnapshot querySnapshot = await _firestore
        .collection('images')
        .where('isActive', isEqualTo: true)
        .get();

    debugPrint('Found ${querySnapshot.docs.length} documents');

    if (querySnapshot.docs.isEmpty) {
      images.value = [];
      errorMessage.value = 'No images found in database';
      return;
    }

    // Sort locally by order field
    var docs = querySnapshot.docs;
    // sort by order if possible
    try {
      docs.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>?;
        final bData = b.data() as Map<String, dynamic>?;
        final int orderA = (aData != null && aData['order'] is int) ? aData['order'] as int : int.tryParse('${aData?['order']}') ?? 0;
        final int orderB = (bData != null && bData['order'] is int) ? bData['order'] as int : int.tryParse('${bData?['order']}') ?? 0;
        return orderA.compareTo(orderB);
      });
    } catch (e) {
      debugPrint('Failed to sort images by order: $e');
    }

    List<CarouselImage> fetchedImages = [];
    
    for (var doc in docs) {
      try {
        debugPrint('Processing document: ${doc.id}');
        CarouselImage image = await CarouselImage.fromFirestore(doc, _storage);
        fetchedImages.add(image);
        debugPrint('Successfully processed image: ${image.title}');
      } catch (e) {
        debugPrint('Error processing image ${doc.id}: $e');
        continue;
      }
    }

    images.value = fetchedImages;
    
    if (fetchedImages.isEmpty) {
      errorMessage.value = 'No valid images could be loaded';
      debugPrint('No valid images loaded');
    } else {
      debugPrint('Successfully loaded ${fetchedImages.length} images');
    }
    
  } catch (e) {
    errorMessage.value = 'Error fetching images: ${e.toString()}';
    debugPrint('Error fetching images: $e');
  } finally {
    isLoading.value = false;
  }
}

  // Refresh images
  Future<void> refreshImages() async {
    await fetchImages();
  }

  // Update current index
  void updateCurrentIndex(int index) {
    currentIndex.value = index;
  }

  // Auto-advance carousel (optional)
  void startAutoPlay() {
    if (images.isNotEmpty) {
      Future.delayed(const Duration(seconds: 3), () {
        if (images.isNotEmpty) {
          currentIndex.value = (currentIndex.value + 1) % images.length;
          startAutoPlay();
        }
      });
    }
  }
}

// Model class for carousel images
class CarouselImage {
  final String id;
  final String title;
  final String description;
  final String storagePath;
  final String downloadUrl;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  CarouselImage({
    required this.id,
    required this.title,
    required this.description,
    required this.storagePath,
    required this.downloadUrl,
    this.isActive = true,
    this.order = 0,
    this.createdAt,
  });

  // Create CarouselImage from Firestore document
  static Future<CarouselImage> fromFirestore(
    DocumentSnapshot doc,
    FirebaseStorage storage,
  ) async {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    final String title = (data['title'] as String?)?.trim() ?? '';
    final String description = (data['description'] as String?)?.trim() ?? '';
    final String storagePath = (data['storagePath'] as String?)?.trim() ?? '';
    String downloadUrl = (data['downloadUrl'] as String?)?.trim() ?? '';
    final bool isActive = data['isActive'] is bool ? data['isActive'] as bool : true;
    final int order = (data['order'] is int) ? data['order'] as int : int.tryParse('${data['order']}') ?? 0;
    final DateTime? createdAt = (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : null;

    if (downloadUrl.isEmpty) {
      if (storagePath.isNotEmpty) {
        try {
          if (storagePath.startsWith('http://') || storagePath.startsWith('https://')) {
            downloadUrl = storagePath;
          } else {
            final ref = storage.ref().child(storagePath);
            downloadUrl = await ref.getDownloadURL();
          }
        } catch (e) {
          debugPrint('Failed to getDownloadURL for doc ${doc.id}, storagePath="$storagePath": $e');
          downloadUrl = '';
        }
      }
    }

    return CarouselImage(
      id: doc.id,
      title: title,
      description: description,
      storagePath: storagePath,
      downloadUrl: downloadUrl,
      isActive: isActive,
      order: order,
      createdAt: createdAt,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'storagePath': storagePath,
      'isActive': isActive,
      'order': order,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}