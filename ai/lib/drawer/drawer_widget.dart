import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/course.dart';
import '../pages/main_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Get.offAll(() => MainScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Courses'),
            onTap: () {
              Get.offAll(() => CourseListScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share App'),
            onTap: () {
              // Add your settings page navigation here
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Handle logout logic
            },
          ),
           ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () {
              // Handle logout logic
            },
          ),
          const Divider(),
          const Text('Social Media',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
       ListTile(
            leading: const Icon(Icons.facebook),
            title: const Text('facebook'),
            onTap: () {
              // Handle logout logic
            },
          ), 
          ListTile(
            leading: const Icon(Icons.tiktok),
            title: const Text('TikTok'),
            onTap: () {
              // Handle logout logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_rounded),
            title: const Text('whatsapp'),
            onTap: () {
              // Handle logout logic
            },
          ), ],
      ),
    );
  }
}
