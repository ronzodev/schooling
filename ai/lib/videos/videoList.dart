import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'video_player.dart';

class VideoListItem extends StatelessWidget {
  final DocumentSnapshot video;
  
  const VideoListItem({super.key, required this.video});

  // Helper function to get YouTube thumbnail URL
  String _getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final videoData = video.data() as Map<String, dynamic>;
    final thumbnailUrl = _getThumbnailUrl(videoData['youtubeId']);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                youtubeId: videoData['youtubeId'],
                videoTitle: videoData['title'],
              ),
            ),
          );
        },
        child: Row(
          children: [
            // Thumbnail image
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                thumbnailUrl,
                width: 120,
                height: 90,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 120,
                    height: 90,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Video details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoData['title'] ?? 'No title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    videoData['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    videoData['duration'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}