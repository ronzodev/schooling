import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import '../controllers/about_us.dart';
import '../controllers/link_controller.dart';
import '../pages/about_us_screen.dart';
import '../pages/course.dart';
import '../pages/main_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final LinksController linksController = Get.put(LinksController());
    final AboutUsController aboutController = Get.put(AboutUsController());

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_icon.png',
                  width: 70,
                ),
                const SizedBox(height: 5),
                const Text(
                  'schooling',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text('Home', style: TextStyle(color: Colors.black)),
            onTap: () {
              Get.offAll(() => MainScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Colors.black),
            title: const Text('Courses', style: TextStyle(color: Colors.black)),
            onTap: () {
              Get.offAll(() => CourseListScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.black),
            title:
                const Text('Share App', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Add your share app functionality here
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.black),
            title: const Text('Privacy Policy',
                style: TextStyle(color: Colors.black)),
            onTap: () {
              // Add privacy policy navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.black),
            title:
                const Text('About Us', style: TextStyle(color: Colors.black)),
            onTap: () {
              Get.to(() =>  const AboutUsPage());
            },
          ),
          const Divider(),
          const Text(
            'Follow Us On',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),

          // Dynamic social media links from Firebase
          Obx(() {
            if (linksController.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (linksController.errorMessage.value.isNotEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Error loading social links',
                  style: TextStyle(color: Colors.red),
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
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }

            return Column(
              children: linksController.links
                  .where((link) => link.isActive)
                  .map((link) => ListTile(
                        leading: _getSocialIcon(link.iconName),
                        title: Text(
                          link.platform,
                          style: const TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          linksController.launchLink(link.url);
                          Navigator.pop(context); // Close drawer
                        },
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  // Helper method to get appropriate icons for social platforms
  Widget _getSocialIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'facebook':
        return const Icon(Icons.facebook, color: Colors.black);
      case 'tiktok':
        return const Icon(Icons.tiktok, color: Colors.black);
      case 'whatsapp':
        return const Icon(LineIcons.whatSApp, color: Colors.black);

      default:
        return const Icon(Icons.link, color: Colors.black);
    }
  }
}
