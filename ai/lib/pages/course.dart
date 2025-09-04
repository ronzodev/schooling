
import 'package:ai/videos/video_subject_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/course_controller.dart';
import '../controllers/theme_controller.dart';
import '../drawer/drawer_widget.dart';
import 'topic.dart';
import 'package:ionicons/ionicons.dart';

class CourseListScreen extends StatelessWidget  {
  final List<Color> cardColors = [
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFEF4444), // Red
    const Color(0xFFF97316), // Orange
    const Color.fromARGB(255, 102, 102, 136), // Gray
  ];

  CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.put(CourseController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final ThemeController themeController = Get.put(ThemeController());
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
    
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
        actions: [
          Obx(() {
            return IconButton(
              onPressed: () {
                themeController.toggleTheme();
              },
              icon: Icon(
                themeController.isDarkMode.value 
                    ? Icons.wb_sunny 
                    : Icons.nights_stay,
                color: Colors.white,
              ),
            );
          }),
          const SizedBox(width: 15,),
          IconButton(
            onPressed: () {
              Get.off(const SubjectListScreen());
            },
            icon: const Icon(Ionicons.logo_youtube, color: Colors.white),
          ),
          const SizedBox(width: 15,),
          IconButton(
            onPressed: () {
              courseController.fetchCourses(forceRefresh: true);
            },
            icon: const Icon(
              Ionicons.refresh,
              color: Colors.white,
            ),
          ),
         const  
         SizedBox(width: 15,),
        ],
     iconTheme: const IconThemeData(color: Colors.white), ),
      body: Obx(() {
        // Show loading spinner if loading and there's no error yet
        if (courseController.isLoading.value &&
            courseController.errorMessage.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
              
        // Show error message if offline and no data
        if (courseController.errorMessage.isNotEmpty &&
            courseController.courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 80),
                const SizedBox(height: 16),
                Text(
                  courseController.errorMessage.value,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }
              
        final courses = courseController.courses;
        final cardHeight = screenHeight * 0.22;
        final cardOverlap = screenHeight * 0.18;
              
        return Padding(
          padding: const EdgeInsets.only(top: 16), // Adjusted for app bar
          child: SizedBox(
            height: screenHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(courses.length, (index) {
                final course = courses[index];
                final color = cardColors[index % cardColors.length];
                final cardWidth = screenWidth *
                    (0.95 - (index * 0.05)).clamp(0.7, 0.95);
              
                return Positioned(
                  top: index * cardOverlap,
                  child: GestureDetector(
                    onTap: () => Get.to(
                        () => TopicListScreen(courseId: course['id'])),
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          course['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}