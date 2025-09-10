import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Observable variables
  var isLoading = true.obs;
  var aboutUsData = AboutUs().obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAboutUs();
  }

  // Fetch About Us content from Firebase
  Future<void> fetchAboutUs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Assuming you have a single document for About Us
      // You can change 'about' to your document ID
      DocumentSnapshot doc = await _firestore
          .collection('aboutUs')
          .doc('about')
          .get();

      if (doc.exists) {
        aboutUsData.value = AboutUs.fromFirestore(doc);
      } else {
        // If document doesn't exist, try to get the first document in collection
        QuerySnapshot querySnapshot = await _firestore
            .collection('aboutUs')
            .limit(1)
            .get();
            
        if (querySnapshot.docs.isNotEmpty) {
          aboutUsData.value = AboutUs.fromFirestore(querySnapshot.docs.first);
        } else {
          errorMessage.value = 'No about us content found';
        }
      }
    } catch (e) {
      errorMessage.value = 'Error fetching about us content: $e';
      print('Error fetching about us: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh about us content
  Future<void> refreshAboutUs() async {
    await fetchAboutUs();
  }

  // Get specific section of about us
  String getSection(String section) {
    switch (section.toLowerCase()) {
      case 'mission':
        return aboutUsData.value.mission;
      case 'vision':
        return aboutUsData.value.vision;
      case 'description':
        return aboutUsData.value.description;
      case 'contact':
        return aboutUsData.value.contactInfo;
      default:
        return aboutUsData.value.description;
    }
  }
}

// Model class for About Us content
class AboutUs {
  final String title;
  final String description;
  final String mission;
  final String vision;
  final String contactInfo;
  final String email;
  final String phone;
  final String address;
  final DateTime? lastUpdated;

  AboutUs({
    this.title = 'About Us',
    this.description = '',
    this.mission = '',
    this.vision = '',
    this.contactInfo = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.lastUpdated,
  });

  // Create AboutUs from Firestore document
  factory AboutUs.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return AboutUs(
      title: data['title'] ?? 'About Us',
      description: data['description'] ?? '',
      mission: data['mission'] ?? '',
      vision: data['vision'] ?? '',
      contactInfo: data['contactInfo'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      lastUpdated: data['lastUpdated']?.toDate(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'mission': mission,
      'vision': vision,
      'contactInfo': contactInfo,
      'email': email,
      'phone': phone,
      'address': address,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Get formatted about us text
  String getFormattedText() {
    List<String> sections = [];
    
    if (description.isNotEmpty) {
      sections.add(description);
    }
    
    if (mission.isNotEmpty) {
      sections.add('\n\nOur Mission:\n$mission');
    }
    
    if (vision.isNotEmpty) {
      sections.add('\n\nOur Vision:\n$vision');
    }
    
    if (contactInfo.isNotEmpty) {
      sections.add('\n\nContact Information:\n$contactInfo');
    }
    
    return sections.join('');
  }
}