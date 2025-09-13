import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../controllers/about_us.dart';
import '../controllers/image_carousel_contr.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AboutUsController controller = Get.put(AboutUsController());
    final ImageCarouselController carouselController = Get.put(ImageCarouselController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    controller.refreshAboutUs();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.refreshAboutUs(),
              carouselController.refreshImages(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel Section
                _buildImageCarousel(carouselController),
                
                // Main Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      // Text(
                      //   controller.aboutUsData.value.title,
                      //   style: const TextStyle(
                      //     fontSize: 24,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black,
                      //   ),
                      // ),
                      const SizedBox(height: 16),

                      // Description
                      if (controller.aboutUsData.value.description.isNotEmpty) ...[
                        _buildSection('About', controller.aboutUsData.value.description),
                        const SizedBox(height: 16),
                      ],

                      // Mission
                      if (controller.aboutUsData.value.mission.isNotEmpty) ...[
                        _buildSection('Our Mission', controller.aboutUsData.value.mission),
                        const SizedBox(height: 16),
                      ],

                      // Vision
                      if (controller.aboutUsData.value.vision.isNotEmpty) ...[
                        _buildSection('Our Vision', controller.aboutUsData.value.vision),
                        const SizedBox(height: 16),
                      ],

                      // Contact Information
                      if (controller.aboutUsData.value.contactInfo.isNotEmpty ||
                          controller.aboutUsData.value.email.isNotEmpty ||
                          controller.aboutUsData.value.phone.isNotEmpty) ...[
                        _buildContactSection(controller.aboutUsData.value),
                      ],

                      // Last updated
                      if (controller.aboutUsData.value.lastUpdated != null) ...[
                        const SizedBox(height: 24),
                        // Text(
                        //   'Last updated: ${_formatDate(controller.aboutUsData.value.lastUpdated!)}',
                        //   style: TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.grey[600],
                        //     fontStyle: FontStyle.italic,
                        //   ),
                        // ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageCarousel(ImageCarouselController carouselController) {
    return Obx(() {
      if (carouselController.isLoading.value) {
        return Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (carouselController.errorMessage.value.isNotEmpty || 
          carouselController.images.isEmpty) {
        return Container(
          height: 200,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  'No images available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            CarouselSlider.builder(
              itemCount: carouselController.images.length,
              itemBuilder: (context, index, realIndex) {
                final image = carouselController.images[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: image.downloadUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Colors.grey[600],
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Optional: Add gradient overlay for text readability
                        if (image.title.isNotEmpty || image.description.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.7),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (image.title.isNotEmpty)
                                    Text(
                                      image.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (image.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      image.description,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                enlargeFactor: 0.2,
                viewportFraction: 0.85,
                onPageChanged: (index, reason) {
                  carouselController.updateCurrentIndex(index);
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page indicator
            if (carouselController.images.length > 1)
              AnimatedSmoothIndicator(
                activeIndex: carouselController.currentIndex.value,
                count: carouselController.images.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 4,
                  activeDotColor: Colors.blue,
                  dotColor: Colors.blue.withOpacity(0.3),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(AboutUs aboutUs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        if (aboutUs.contactInfo.isNotEmpty) ...[
          Text(
            aboutUs.contactInfo,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (aboutUs.email.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.email, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  aboutUs.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 45, 65, 82),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (aboutUs.phone.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  aboutUs.phone,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (aboutUs.address.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  aboutUs.address,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}