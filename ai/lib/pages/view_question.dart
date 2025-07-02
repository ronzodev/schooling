
  import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageZoomScreen extends StatefulWidget {
    final String imageUrl;
    final int index;

    const ImageZoomScreen({super.key, required this.imageUrl, required this.index});

    @override
    _ImageZoomScreenState createState() => _ImageZoomScreenState();
  }

  class _ImageZoomScreenState extends State<ImageZoomScreen> {
    late PhotoViewControllerBase controller;
    bool showFloatingButton = false;

    @override
    void initState() {
      super.initState();
      controller = PhotoViewController()
        ..outputStateStream.listen((state) {
          if (state.scale != null) {
            setState(() {
              showFloatingButton = state.scale! > 1.1;
            });
          }
        });
      
      // Auto-zoom after the image is loaded
      Future.delayed(const Duration(milliseconds: 300), () {
        controller.scale = 1.5; // Initial zoom level
        setState(() {
          showFloatingButton = true;
        });
      });
    }

    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 143, 138, 138),
    floatingActionButton: AnimatedOpacity(
      opacity: 1.0, // Always visible
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        heroTag: null,
        backgroundColor: Colors.grey.withOpacity(0.3),
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back, color: Colors.orange, weight: 23, size: 32),
      ),
    ),
    body: Center(
      child: Hero(
        tag: 'image_${widget.index}',
        child: PhotoView(
          controller: controller,
          imageProvider: CachedNetworkImageProvider(widget.imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
      ),
    ),
  );
}
  }