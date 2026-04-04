import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';

class FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;

  const FeedVideoPlayer({super.key, required this.videoUrl, this.thumbnailUrl});

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _playing = false;
  bool _showControls = true;
  bool _hasError = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initAndPlay() async {
    if (_controller != null) return;

    setState(() => _showControls = false);

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      controller.addListener(_onVideoUpdate);
      setState(() {
        _initialized = true;
        _playing = true;
      });
      await controller.play();
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onVideoUpdate() {
    if (!mounted || _controller == null) return;
    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _playing) {
      setState(() => _playing = isPlaying);
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_initialized) {
      _initAndPlay();
      return;
    }
    if (_playing) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
    setState(() => _showControls = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _playing) setState(() => _showControls = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _initialized ? _controller!.value.aspectRatio : 16 / 9,
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Container(
          color: const Color(0xFF1a1a2e),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video or thumbnail
              if (_initialized && _controller != null)
                VideoPlayer(_controller!)
              else if (widget.thumbnailUrl != null &&
                  widget.thumbnailUrl!.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: widget.thumbnailUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),

              // Loading spinner while initializing
              if (!_initialized && !_showControls && !_hasError)
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),

              // Play/pause overlay
              if (_showControls || !_playing)
                AnimatedOpacity(
                  opacity: (_showControls || !_playing) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                    child: Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Error state
              if (_hasError)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Video unavailable',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

              // Progress bar
              if (_initialized && _controller != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppColors.primary,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white10,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
