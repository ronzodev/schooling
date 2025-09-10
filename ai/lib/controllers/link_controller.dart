import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable variables
  var isLoading = true.obs;
  var links = <SocialLink>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLinks();
  }

  // Fetch links from Firebase
  Future<void> fetchLinks() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      QuerySnapshot querySnapshot = await _firestore
          .collection('links')
          .orderBy('order', descending: false) // Optional: order by a field
          .get();

      List<SocialLink> fetchedLinks = querySnapshot.docs.map((doc) {
        return SocialLink.fromFirestore(doc);
      }).toList();

      links.value = fetchedLinks;
    } catch (e) {
      errorMessage.value = 'Error fetching links: $e';
      print('Error fetching links: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh links
  Future<void> refreshLinks() async {
    await fetchLinks();
  }

  // Launch URL
  Future<void> launchLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch $url',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open link: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Get link by platform name
  SocialLink? getLinkByPlatform(String platform) {
    try {
      return links.firstWhere(
        (link) => link.platform.toLowerCase() == platform.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

// Model class for social links
class SocialLink {
  final String id;
  final String platform;
  final String url;
  final String iconName;
  final bool isActive;
  final int order;

  SocialLink({
    required this.id,
    required this.platform,
    required this.url,
    required this.iconName,
    this.isActive = true,
    this.order = 0,
  });

  // Create SocialLink from Firestore document
  factory SocialLink.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return SocialLink(
      id: doc.id,
      platform: data['platform'] ?? '',
      url: data['url'] ?? '',
      iconName: data['iconName'] ?? 'link',
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'url': url,
      'iconName': iconName,
      'isActive': isActive,
      'order': order,
    };
  }
}