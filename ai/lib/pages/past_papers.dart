import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../controllers/ads_controller.dart';
import 'pdf_viewer_screen.dart';

class PastPapersScreen extends StatefulWidget {
  const PastPapersScreen({super.key});

  @override
  State<PastPapersScreen> createState() => _PastPapersScreenState();
}

class _PastPapersScreenState extends State<PastPapersScreen> {
  int _currentLevel = 0;
  String? _selectedGradeId;
  String? _selectedGradeName;
  String? _selectedSubjectId;
  String? _selectedSubjectName;

  // ECZ Firebase Firestore instance (ECZ is the default app)
  FirebaseFirestore get _eczFirestore => FirebaseFirestore.instance;

  // Gradient palette for cards
  final List<LinearGradient> cardGradients = [
    AppTheme.blueGradient,
    AppTheme.pinkGradient,
    AppTheme.purpleGradient,
    AppTheme.greenGradient,
    AppTheme.orangeGradient,
  ];

  // Icons for subjects
  final Map<String, IconData> subjectIcons = {
    'mathematics': Icons.calculate_rounded,
    'math': Icons.calculate_rounded,
    'science': Icons.science_rounded,
    'biology': Icons.biotech_rounded,
    'chemistry': Icons.science_rounded,
    'physics': Icons.bolt_rounded,
    'english': Icons.language_rounded,
    'literature': Icons.menu_book_rounded,
    'history': Icons.account_balance_rounded,
    'geography': Icons.public_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentLevel > 0) {
          // Trigger interstitial ad when going back from Subjects (Level 1) to Grades (Level 0)
          if (_currentLevel == 1) {
            GoogleAdsController.instance.showInterstitialAd();
          }

          setState(() {
            _currentLevel--;
            if (_currentLevel == 1) {
              _selectedSubjectId = null;
              _selectedSubjectName = null;
            } else if (_currentLevel == 0) {
              _selectedGradeId = null;
              _selectedGradeName = null;
            }
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(),

                // Header
                _buildHeader(),

                // Content
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button (only show if not at grade level)
          if (_currentLevel > 0)
            GestureDetector(
              onTap: () {
                // Trigger interstitial ad when going back from Subjects (Level 1) to Grades (Level 0)
                if (_currentLevel == 1) {
                  GoogleAdsController.instance.showInterstitialAd();
                }

                setState(() {
                  _currentLevel--;
                  if (_currentLevel == 1) {
                    _selectedSubjectId = null;
                    _selectedSubjectName = null;
                  } else if (_currentLevel == 0) {
                    _selectedGradeId = null;
                    _selectedGradeName = null;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
              ),
            )
          else
            const SizedBox(width: 44),

          const Spacer(),

          // Title
          Text(
            _getAppBarTitle(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),

          const Spacer(),

          // Placeholder for symmetry
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String subtitle;

    switch (_currentLevel) {
      case 0:
        subtitle = 'Choose your grade level';
        break;
      case 1:
        subtitle = 'Select a subject to view papers';
        break;
      case 2:
        subtitle = 'Tap on a paper to view';
        break;
      default:
        subtitle = '';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: cardGradients[_currentLevel % cardGradients.length],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cardGradients[_currentLevel % cardGradients.length]
                      .colors
                      .first
                      .withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 50,
              height: 50,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentLevel == 0
                      ? 'Past Papers'
                      : _currentLevel == 1
                          ? _selectedGradeName ?? 'Subjects'
                          : _selectedSubjectName ?? 'Papers',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentLevel) {
      case 0:
        return 'Grades';
      case 1:
        return 'Subjects';
      case 2:
        return 'Papers';
      default:
        return 'Past Papers';
    }
  }

  Widget _buildBody() {
    switch (_currentLevel) {
      case 0:
        return _buildGradesList();
      case 1:
        return _buildSubjectsList();
      case 2:
        return _buildPapersList();
      default:
        return const Center(child: Text('Error'));
    }
  }

  Widget _buildGradesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _eczFirestore.collection('grade').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState('No grades found', Icons.school_rounded);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final name = data['name'] ?? docs[index].id;
            final logoUrl = data['logo'];
            final gradient = cardGradients[index % cardGradients.length];

            return _buildGradeCard(
              name: name,
              logoUrl: logoUrl,
              gradient: gradient,
              onTap: () {
                setState(() {
                  _selectedGradeId = docs[index].id;
                  _selectedGradeName = name;
                  _currentLevel = 1;
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGradeCard({
    required String name,
    String? logoUrl,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardBackground.withOpacity(0.9),
              AppTheme.cardBackgroundLight.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Grade icon/logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Grade name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'View subjects →',
                    style: TextStyle(
                      fontSize: 14,
                      color: gradient.colors.first,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: gradient.colors.first,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _eczFirestore
          .collection('grade')
          .doc(_selectedGradeId)
          .collection('subjects')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState('No subjects found', Icons.book_rounded);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>?;
            final name = data != null && data.containsKey('name')
                ? data['name']
                : docs[index].id;
            final gradient = cardGradients[index % cardGradients.length];
            final icon = _getSubjectIcon(name.toString().toLowerCase());

            return _buildSubjectCard(
              name: name,
              gradient: gradient,
              icon: icon,
              onTap: () {
                setState(() {
                  _selectedSubjectId = docs[index].id;
                  _selectedSubjectName = name;
                  _currentLevel = 2;
                });
              },
            );
          },
        );
      },
    );
  }

  IconData _getSubjectIcon(String subjectName) {
    for (var entry in subjectIcons.entries) {
      if (subjectName.contains(entry.key)) {
        return entry.value;
      }
    }
    return Icons.menu_book_rounded;
  }

  Widget _buildSubjectCard({
    required String name,
    required LinearGradient gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardBackground.withOpacity(0.9),
              AppTheme.cardBackgroundLight.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPapersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _eczFirestore
          .collection('grade')
          .doc(_selectedGradeId)
          .collection('subjects')
          .doc(_selectedSubjectId)
          .collection('past papers')
          .orderBy('idx')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(
            'No past papers found for $_selectedSubjectName',
            Icons.description_rounded,
          );
        }

        // Calculate total items (papers + ads)
        final paperCount = docs.length;
        final adInterval = 3; // Show ad every 3 papers
        final adCount = (paperCount / adInterval).floor();
        final totalItems = paperCount + adCount;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            // Calculate if this position should be an ad
            final adPositions = <int>{};
            for (int i = 1; i <= adCount; i++) {
              adPositions.add((i * adInterval) + (i - 1));
            }

            // Show ad at calculated positions
            if (adPositions.contains(index)) {
              final adNumber = adPositions.toList().indexOf(index);
              return _buildNativeAdCard(adIndex: adNumber);
            }

            // Calculate actual paper index (accounting for ads)
            final adsBeforeThisIndex =
                adPositions.where((pos) => pos < index).length;
            final paperIndex = index - adsBeforeThisIndex;

            if (paperIndex >= paperCount) return const SizedBox.shrink();

            final data = docs[paperIndex].data() as Map<String, dynamic>;
            final name = data['name'] ?? docs[paperIndex].id;
            final url = data['url'];

            return _buildPaperCard(
              name: name,
              index: paperIndex,
              onTap: () {
                if (url != null) {
                  Get.to(() => PdfViewerScreen(
                        pdfUrl: url,
                        title: name,
                      ));
                } else {
                  Get.snackbar(
                    'Error',
                    'PDF URL not available',
                    backgroundColor: AppTheme.error.withOpacity(0.9),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPaperCard({
    required String name,
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardBackground.withOpacity(0.9),
              AppTheme.cardBackgroundLight.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // PDF Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppTheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Paper info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to view PDF',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // View button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.blueGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNativeAdCard({required int adIndex}) {
    final adsController = GoogleAdsController.instance;

    // Try to get a native ad widget with exact paper card styling
    final adWidget = adsController.getNativeAdWidget(
      width: double.infinity,
      height: 80, // Compact height to match paper card
      adIndex: adIndex,
    );

    // If no ad is available, return empty widget
    if (adWidget == null) {
      return const SizedBox.shrink();
    }

    // Wrap in exact same styling as paper cards
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(
          4), // Reduced padding to let ad occupy more space
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackground.withOpacity(0.9),
            AppTheme.cardBackgroundLight.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: adWidget,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: AppTheme.accentBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading...',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
