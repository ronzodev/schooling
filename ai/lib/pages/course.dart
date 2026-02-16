import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';
import '../controllers/link_controller.dart';
import '../controllers/app_content_controller.dart';
import 'package:line_icons/line_icons.dart';
import '../drawer/drawer_widget.dart';
import '../theme/app_theme.dart';
import '../utils/icon_helper.dart';
import 'topic.dart';
import 'category_header_delegate.dart';
import '../solar/solar_system_screen.dart';
import 'notes_screen.dart';
import 'past_papers.dart';
import '../widgets/no_connection_widget.dart';

class CourseListScreen extends StatelessWidget {
  // Playful gradient colors for course cards
  final List<LinearGradient> cardGradients = [
    AppTheme.blueGradient,
    AppTheme.pinkGradient,
    AppTheme.purpleGradient,
    AppTheme.greenGradient,
    AppTheme.orangeGradient,
  ];

  CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourseController courseController = Get.put(CourseController());
    final LinksController linksController = Get.put(LinksController());
    Get.put(AppContentController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sliver App Bar with Flexible Space (Spotify-like header)
              SliverAppBar(
                backgroundColor: AppTheme.backgroundDark, // Fully opaque
                expandedHeight: 180.0, // Reduced height further
                floating: false,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0, // Disable M3 scroll tint
                surfaceTintColor: Colors.transparent, // Disable M3 tint
                shadowColor: Colors.transparent,
                leading: GestureDetector(
                  onTap: () => scaffoldKey.currentState?.openDrawer(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_rounded,
                        color: AppTheme.textPrimary),
                  ),
                ),
                actions: [
                  // WhatsApp Button
                  GestureDetector(
                    onTap: () {
                      final whatsapp =
                          linksController.getLinkByPlatform('whatsapp');
                      if (whatsapp != null) {
                        linksController.launchLink(whatsapp.url);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LineIcons.whatSApp,
                        color: AppTheme.accentGreen,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Refresh Button
                  GestureDetector(
                    onTap: () {
                      if (courseController.isRefreshing.value) return;
                      courseController.fetchCourses(forceRefresh: true);
                      Get.find<AppContentController>().fetchContent();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Obx(() => courseController.isRefreshing.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppTheme.accentBlue,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh_rounded,
                              color: AppTheme.accentBlue,
                              size: 20,
                            )),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: LayoutBuilder(
                    builder: (context, constraints) {
                      final double percentage = ((constraints.biggest.height -
                                  kToolbarHeight -
                                  MediaQuery.of(context).padding.top) /
                              (180.0 -
                                  kToolbarHeight -
                                  MediaQuery.of(context).padding.top))
                          .clamp(0.0, 1.0);
                      return Opacity(
                        opacity: percentage,
                        child: _buildHeader(),
                      );
                    },
                  ),
                  collapseMode: CollapseMode.parallax,
                  expandedTitleScale: 1.0,
                ),
              ),

              // 2. Category Icons (Sticky Header)
              SliverPersistentHeader(
                pinned: true,
                delegate: CategoryHeaderDelegate(
                  minHeight: 145.0,
                  maxHeight: 145.0,
                  builder: (context, overlapsContent) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        // Use gradient when stuck to match app background feel, transparent when at rest
                        gradient: overlapsContent
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.backgroundDark,
                                  AppTheme.backgroundDark,
                                  AppTheme.backgroundDark.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              )
                            : null,
                        color: overlapsContent ? null : Colors.transparent,
                        boxShadow: [],
                      ),
                      child: _buildCategoryIcons(),
                    );
                  },
                ),
              ),

              // 3. Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Text(
                            Get.find<AppContentController>().sectionTitle.value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          )),
                      Obx(() => Text(
                            '${courseController.courses.length} courses',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              // 4. Course List
              Obx(() => _buildCourseListSliver(courseController)),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // Bottom padding
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final contentController = Get.find<AppContentController>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => Text(
                    contentController.greeting.value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  )),
              const SizedBox(width: 8),
              Obx(() => Text(
                    contentController.emoji.value,
                    style: const TextStyle(fontSize: 28),
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
                contentController.subtitle.value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryIcons() {
    final categories = [
      {
        'icon': Icons.wb_sunny_rounded,
        'label': 'Solar System',
        'color': AppTheme.accentBlue
      },
      // {
      //   'icon': Icons.games_rounded,
      //   'label': 'Games',
      //   'color': AppTheme.accentPink
      // },
      {
        'icon': Icons.text_snippet,
        'label': 'Past Papers',
        'color': AppTheme.accentPurple
      },
      {
        'icon': Icons.menu_book_rounded,
        'label': 'Notes',
        'color': AppTheme.accentOrange
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((category) {
          return GestureDetector(
            onTap: () {
              if (category['label'] == 'Solar System') {
                Get.to(
                  () => const SolarSystemScreen(),
                  transition: Transition.downToUp,
                );
              } else if (category['label'] == 'Past Papers') {
                Get.to(
                  () => const PastPapersScreen(),
                  transition: Transition.downToUp,
                );
              } else if (category['label'] == 'Notes') {
                Get.to(
                  () => const NotesScreen(),
                  transition: Transition.downToUp,
                );
              }
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (category['color'] as Color),
                        (category['color'] as Color).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: (category['color'] as Color).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  category['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseListSliver(CourseController courseController) {
    // Loading state
    if (courseController.isLoading.value &&
        courseController.errorMessage.isEmpty) {
      return const SliverToBoxAdapter(
          child: Padding(
              padding: EdgeInsets.only(top: 50),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.accentBlue,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading courses...',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )));
    }

    // Check if empty and showing error
    if (courseController.courses.isEmpty) {
      if (courseController.errorMessage.value.isNotEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: NoConnectionWidget(
              onRetry: () => courseController.fetchCourses(forceRefresh: true),
              message: courseController.errorMessage.value.contains('internet')
                  ? 'Please check your internet connection and try again.'
                  : courseController.errorMessage.value,
            ),
          ),
        );
      }
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Center(child: Text("No courses available")),
        ),
      );
    }

    // Course list without ads
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = courseController.courses[index];
            final gradient = cardGradients[index % cardGradients.length];
            final icon = IconHelper.getIconForSubject(course['title'] ?? '');

            return _buildCourseCard(
              course: course,
              gradient: gradient,
              icon: icon,
              index: index,
            );
          },
          childCount: courseController.courses.length,
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required Map<String, dynamic> course,
    required LinearGradient gradient,
    required IconData icon,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => Get.to(
        () => TopicListScreen(courseId: course['id']),
        transition: Transition.rightToLeft,
      ),
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
          borderRadius: BorderRadius.circular(24),
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
            // Course icon with gradient
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Course info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'] ?? 'Course',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Start learning',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
