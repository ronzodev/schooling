import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String youtubeId;
  final String videoTitle;

  const VideoPlayerScreen({
    super.key,
    required this.youtubeId,
    required this.videoTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        autoPlay: false, // Changed to false for better UX
        mute: false,
        enableCaption: true,
        isLive: false,
        controlsVisibleAtStart: true,
        forceHD: false, // Let it adapt to network conditions
        hideControls: false,
        disableDragSeek: false,
        loop: false,
        useHybridComposition: true, // Better performance
      ),
    )..addListener(_playerListener);
  }

  void _playerListener() {
    if (!mounted) return;

    final value = _controller.value;
    
    // Handle errors
    if (value.hasError) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error code: ${value.errorCode}';
      });
      return;
    }

    // Update ready state
    if (!_isPlayerReady && value.isReady) {
      setState(() {
        _isPlayerReady = true;
        _hasError = false;
      });
    }

    // Only update UI if player is ready and not in fullscreen
    if (_isPlayerReady && !value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_playerListener);
    _controller.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (_hasError) {
      return Container(
        height: 200,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video',
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _retryLoad,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.redAccent,
      progressColors: const ProgressBarColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
        bufferedColor: Colors.grey,
        backgroundColor: Colors.black12,
      ),
      onReady: () {
        if (mounted) {
          setState(() {
            _isPlayerReady = true;
            _hasError = false;
          });
        }
      },
      onEnded: (data) {
        // Handle video end if needed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video ended'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      bottomActions: [
        const SizedBox(width: 8.0),
        CurrentPosition(),
        const SizedBox(width: 8.0),
        ProgressBar(isExpanded: true),
        const SizedBox(width: 8.0),
        RemainingDuration(),
        const SizedBox(width: 8.0),
        const PlaybackSpeedButton(),
        const SizedBox(width: 8.0),
        FullScreenButton(),
        const SizedBox(width: 8.0),
      ],
      topActions: [
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            widget.videoTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  void _retryLoad() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isPlayerReady = false;
    });
    
    _controller.dispose();
    _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.redAccent,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          bufferedColor: Colors.grey,
          backgroundColor: Colors.black12,
        ),
        onReady: () {
          if (mounted) {
            setState(() {
              _isPlayerReady = true;
              _hasError = false;
            });
          }
        },
        onEnded: (data) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video ended'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        bottomActions: [
          const SizedBox(width: 8.0),
          CurrentPosition(),
          const SizedBox(width: 8.0),
          ProgressBar(isExpanded: true),
          const SizedBox(width: 8.0),
          RemainingDuration(),
          const SizedBox(width: 8.0),
          const PlaybackSpeedButton(),
          const SizedBox(width: 8.0),
          FullScreenButton(),
          const SizedBox(width: 8.0),
        ],
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              widget.videoTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          appBar: AppBar(
            title: Text(
              widget.videoTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Video Player Container
              Container(
                color: Colors.black,
                child: player,
              ),
              
              // Video Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Title
                      Text(
                        widget.videoTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Video Status
                      if (_isPlayerReady) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ready to play',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                              ? Colors.grey[800] 
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: isDarkMode ? Colors.blue[300] : Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Rotate your phone or tap the fullscreen button for an immersive viewing experience.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode 
                                      ? Colors.grey[300] 
                                      : Colors.grey[600],
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Additional space for scroll
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}