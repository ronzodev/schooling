import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../theme/app_theme.dart';
import '../pages/course.dart';
import '../chem_periodic/periodic.dart';
import '../math_formula/main_screen.dart';
import '../solar/solar_system_screen.dart';
import '../pages/past_papers.dart';

// Native Ad Widget
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({Key? key}) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  //real ad
  // final String _adUnitId = 'ca-app-pub-9049620363523701/8454585993';

  // test ad

  final String _adUnitId = 'ca-app-pub-3940256099942544/2247696110';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Native ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      height: 65,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}

// Main Screen with Playful Design
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    CourseListScreen(),
    ElementsScreen(),
    const MathFormulasScreen(),
    const PastPapersScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.menu_book_rounded,
      label: 'Courses',
      color: AppTheme.accentBlue,
    ),
    NavItem(
      icon: Icons.science_rounded,
      label: 'Periodic',
      color: AppTheme.accentPink,
    ),
    NavItem(
      icon: Icons.functions_rounded,
      label: 'Formulas',
      color: AppTheme.accentPurple,
    ),
    NavItem(
      icon: Icons.description_rounded,
      label: 'Papers',
      color: AppTheme.accentGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: _screens[_selectedIndex],
            ),

            // Native Ad positioned above bottom nav
            const NativeAdWidget(),

            // Bottom Navigation
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GNav(
          gap: 6,
          activeColor: Colors.white,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: AppTheme.accentBlue.withOpacity(0.1),
          color: AppTheme.textSecondary,
          tabs: _navItems.map((item) {
            return GButton(
              icon: item.icon,
              text: item.label,
              backgroundColor: item.color.withOpacity(0.2),
              iconActiveColor: item.color,
              textColor: Colors.white,
            );
          }).toList(),
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
