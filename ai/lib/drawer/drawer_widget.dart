import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../theme/app_theme.dart';
import '../controllers/about_us.dart';
import '../controllers/link_controller.dart';
import '../pages/about_us_screen.dart';
import '../pages/course.dart';
import '../pages/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final LinksController linksController = Get.put(LinksController());
    final AboutUsController aboutController = Get.put(AboutUsController());

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 70,
                      height: 70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Past paper Solutions',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              onTap: () => Get.offAll(() => MainScreen()),
            ),
            _buildDrawerItem(
              icon: Icons.menu_book_rounded,
              title: 'Courses',
              onTap: () => Get.offAll(() => CourseListScreen()),
            ),
            _buildDrawerItem(
              icon: Icons.share_rounded,
              title: 'Share App',
              onTap: () => shareApp(),
            ),
            _buildDrawerItem(
              icon: Icons.privacy_tip_rounded,
              title: 'Privacy Policy',
              onTap: () => privacyPolicy(),
            ),
            _buildDrawerItem(
              icon: Icons.info_rounded,
              title: 'About Us',
              onTap: () => Get.to(() => const AboutUsPage()),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.white24),
            ),
            const Text(
              'Follow Us On',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Dynamic social media links from Firebase
            Obx(() {
              if (linksController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentBlue),
                );
              }

              if (linksController.errorMessage.value.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading social links',
                    style: TextStyle(color: AppTheme.error),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (linksController.links.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No social links available',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: linksController.links
                      .where((link) => link.isActive)
                      .map((link) => ListTile(
                            leading: _getSocialIcon(link.iconName),
                            title: Text(
                              link.platform,
                              style:
                                  const TextStyle(color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              linksController.launchLink(link.url);
                              Navigator.pop(context); // Close drawer
                            },
                          ))
                      .toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      onTap: onTap,
    );
  }

  // privacy policy link

  void privacyPolicy() {
    _launch('https://sites.google.com/view/ronzodevsolveit/home');
  }

  // share app link
  void shareApp() {
    Share.share(
        'https://play.google.com/store/apps/details?id=com.ronzodev.solveit');
  }

  // Helper method to get appropriate icons for social platforms
  Widget _getSocialIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'facebook':
        return const Icon(Icons.facebook, color: AppTheme.accentBlue);
      case 'tiktok':
        return const Icon(Icons.tiktok, color: AppTheme.textPrimary);
      case 'whatsapp':
        return const Icon(LineIcons.whatSApp, color: AppTheme.accentGreen);

      default:
        return const Icon(Icons.link, color: AppTheme.textSecondary);
    }
  }
}

Future<void> _launch(String url) async {
  // ignore: deprecated_member_use
  if (!await launch(
    url,
  )) {
    throw 'Could not launch $url';
  }
}
