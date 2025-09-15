import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';

class MediaItem extends StatefulWidget {
  final String mediaUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const MediaItem({
    super.key,
    required this.mediaUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = false;

  bool get _isVideo {
    final url = widget.mediaUrl.toLowerCase();
    return url.contains('.mp4') ||
        url.contains('.mov') ||
        url.contains('.avi') ||
        url.contains('.mkv') ||
        url.contains('.webm') ||
        url.contains('.m4v') ||
        url.contains('.3gp') ||
        url.contains('video') ||
        // Check if URL explicitly mentions video in the path
        url.contains('/video/') ||
        // Check for common video hosting patterns
        url.contains('youtube.com') ||
        url.contains('vimeo.com');
  }

  @override
  void initState() {
    super.initState();
    if (_isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrl),
      );

      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }

      // Listen to video state changes
      _videoController!.addListener(() {
        if (mounted && _videoController!.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _videoController!.value.isPlaying;
          });
        }
      });
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_videoController != null && _isVideoInitialized) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (_videoController == null || !_isVideoInitialized) {
      return Container(
        width: widget.width,
        height: widget.height ?? 200,
        color: AppColors.lightGray,
        child: Center(
          child: _videoController == null
              ? const Icon(Icons.videocam_off, color: AppColors.gray, size: 48)
              : const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryLimeGreen,
                  ),
                ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
        // Play/Pause overlay
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Center(
              child: AnimatedOpacity(
                opacity: _isPlaying ? 0.0 : 0.8,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Video progress indicator (optional)
        if (_isVideoInitialized &&
            _videoController!.value.duration.inSeconds > 0)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: LinearProgressIndicator(
                value:
                    _videoController!.value.position.inSeconds /
                    _videoController!.value.duration.inSeconds,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryLimeGreen,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlayer() {
    return CachedNetworkImage(
      imageUrl: widget.mediaUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => Container(
        width: widget.width,
        height: widget.height ?? 200,
        color: AppColors.lightGray,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryLimeGreen,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: widget.width,
        height: widget.height ?? 200,
        color: AppColors.lightGray,
        child: const Center(
          child: Icon(Icons.broken_image, color: AppColors.gray, size: 48),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _isVideo ? _buildVideoPlayer() : _buildImagePlayer(),
    );
  }
}
