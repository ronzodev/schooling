import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
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
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text('Home',style: TextStyle(color: Colors.black),),
            onTap: () {
              Get.offAll(() => MainScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Colors.black),
            title: const Text('Courses',style: TextStyle(color: Colors.black) ),
            onTap: () {
              Get.offAll(() => CourseListScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.black),
            title: const Text('Share App', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Add your settings page navigation here
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.black,),
            title: const Text('Privacy Policy', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Handle logout logic
            },
          ),
           ListTile(
            leading: const Icon(Icons.info, color: Colors.black),
            title: const Text('About Us',style: TextStyle(color: Colors.black)),
            onTap: () {
              // Handle logout logic
            },
          ),
          const Divider(),
          const Text('Follow Us On', textAlign: TextAlign.center,
              
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
       ListTile(
            leading: const Icon(Icons.facebook, color: Colors.black),
            title: const Text('facebook', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Handle logout logic
            },
          ), 
          ListTile(
            leading: const Icon(Icons.tiktok, color: Colors.black),
            title: const Text('TikTok', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Handle logout logic
            },
          ),
          ListTile(
            leading: const LineIcon( Icons.messenger, color: Colors.black),
            title: const Text('whatsapp', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Handle logout logic
            },
          ), ],
      ),
    );
  }
}
