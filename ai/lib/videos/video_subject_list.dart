import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import '../pages/main_screen.dart';
import 'video_topic_screeen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Subject colors that adapt to theme
  Map<String, Color> _getSubjectColors(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return {
      '🧬': brightness == Brightness.dark 
          ? const Color(0xFF81C784) // Light green for dark mode
          : const Color(0xFF4CAF50), // Green for light mode
      '📐': brightness == Brightness.dark 
          ? const Color(0xFFE57373) // Light red for dark mode
          : const Color(0xFFF44336), // Red for light mode
      '🔬': brightness == Brightness.dark 
          ? const Color(0xFFBA68C8) // Light purple for dark mode
          : const Color(0xFF9C27B0), // Purple for light mode
      '📚': brightness == Brightness.dark 
          ? const Color(0xFF64B5F6) // Light blue for dark mode
          : const Color(0xFF2196F3), // Blue for light mode
      '🧪': brightness == Brightness.dark 
          ? const Color(0xFF4DD0E1) // Light cyan for dark mode
          : const Color(0xFF00BCD4), // Cyan for light mode
      '⚛️': brightness == Brightness.dark 
          ? const Color(0xFF9575CD) // Light deep purple for dark mode
          : const Color(0xFF673AB7), // Deep purple for light mode
    };
  }

  @override
  Widget build(BuildContext context) {
    final subjectColors = _getSubjectColors(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.off(MainScreen()),
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.white),
        ),
        title: const Text(
          'Educational Videos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF121212),
                    const Color(0xFF1E1E1E),
                  ]
                : [
                    const Color(0xFFE8EAF6),
                    const Color(0xFFC5CAE9),
                  ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.deepPurple.shade200 : Colors.deepPurple,
                  ),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('videos').orderBy('title').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString(), isDarkMode);
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState(isDarkMode);
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(isDarkMode);
                  }

                  return _buildSubjectGrid(snapshot.data!.docs, subjectColors, isDarkMode);
                },
              ),
      ),
    );
  }

  Widget _buildSubjectGrid(
      List<QueryDocumentSnapshot> subjects, Map<String, Color> subjectColors, bool isDarkMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              return _buildSubjectCard(subjects[index], subjectColors, isDarkMode);
            },
          ),
        );
      },
    );
  }

  Widget _buildSubjectCard(
      QueryDocumentSnapshot subject, Map<String, Color> subjectColors, bool isDarkMode) {
    final icon = subject['icon'] ?? '📚';
    final color = subjectColors[icon] ?? subjectColors['📚']!;
    final blurHash = _getBlurHashForSubject(icon);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      color: isDarkMode ? Colors.grey.shade900.withOpacity(0.5) : Colors.white,
      child: Stack(
        children: [
          // Blurred background based on subject icon
          if (blurHash != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BlurHash(
                hash: blurHash,
                color: color.withOpacity(isDarkMode ? 0.5 : 0.7),
                imageFit: BoxFit.cover,
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: color.withOpacity(isDarkMode ? 0.5 : 0.7),
              ),
            ),

          // Content overlay
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _navigateToSubject(subject),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.8),
                        ]
                      : [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        subject['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.play_circle_fill,
                      color: Colors.white.withOpacity(isDarkMode ? 0.9 : 1.0),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _getBlurHashForSubject(String icon) {
    final blurHashes = {
      '🧬': 'L5H2EC=PM+yV0g-mq.wG9c010J}I', // Biology
      '📐': 'LKO2?U%2Tw=w]|RBVZRi};RPxuwH', // Math
      '🔬': 'L6Pj0^i_.AyE_3t7t7R**0o#DgR4', // Science
      '📚': 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', // Default
      '🧪': 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', // Chemistry
      '⚛️': 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', // Physics
    };
    return blurHashes[icon] ?? blurHashes['📚'];
  }

  void _navigateToSubject(QueryDocumentSnapshot subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicListScreenVideo(
          subjectId: subject.id,
          subjectTitle: subject['title'],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: isDarkMode ? Colors.red.shade300 : Colors.redAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading content\n$error',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.red.shade300 : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          isDarkMode ? Colors.deepPurple.shade200 : Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 72,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No subjects available',
            style: TextStyle(
              fontSize: 20,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    if (screenWidth > 1200) return 4;
    if (screenWidth > 800) return 3;
    if (screenWidth > 600) return 2;
    return 1;
  }
}