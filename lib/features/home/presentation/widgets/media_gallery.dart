import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';

enum MediaType { image, video }

class MediaInfo {
  final String url;
  final MediaType type;
  final int index;

  MediaInfo({required this.url, required this.type, required this.index});

  static MediaType detectMediaType(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.mp4') ||
            lowerUrl.contains('.mov') ||
            lowerUrl.contains('.avi') ||
            lowerUrl.contains('.mkv') ||
            lowerUrl.contains('.webm') ||
            lowerUrl.contains('.m4v') ||
            lowerUrl.contains('.3gp') ||
            lowerUrl.contains('video') ||
            lowerUrl.contains('/video/') ||
            lowerUrl.contains('youtube.com') ||
            lowerUrl.contains('vimeo.com')
        ? MediaType.video
        : MediaType.image;
  }
}

class MediaGallery extends StatelessWidget {
  final List<String> mediaUrls;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const MediaGallery({
    super.key,
    required this.mediaUrls,
    this.height,
    this.padding,
    this.borderRadius,
  });

  List<MediaInfo> get _mediaInfoList {
    return mediaUrls
        .asMap()
        .entries
        .map(
          (entry) => MediaInfo(
            url: entry.value,
            type: MediaInfo.detectMediaType(entry.value),
            index: entry.key,
          ),
        )
        .toList();
  }

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenMediaViewer(
              mediaInfoList: _mediaInfoList,
              initialIndex: initialIndex,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    final mediaCount = mediaUrls.length;
    final height = this.height ?? 300.0;

    if (mediaCount == 0) return const SizedBox.shrink();

    return Container(
      height: height,
      padding: padding,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: _buildLayoutByCount(context, mediaCount, height),
      ),
    );
  }

  Widget _buildLayoutByCount(BuildContext context, int count, double height) {
    switch (count) {
      case 1:
        return _buildSingleMedia(context, 0);
      case 2:
        return _buildTwoMedia(context, height);
      case 3:
        return _buildThreeMedia(context, height);
      case 4:
        return _buildFourMedia(context, height);
      default:
        return _buildFiveOrMoreMedia(context, height, count);
    }
  }

  Widget _buildSingleMedia(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _openFullScreen(context, index),
      child: MediaThumbnail(
        mediaInfo: _mediaInfoList[index],
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTwoMedia(BuildContext context, double height) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullScreen(context, 0),
            child: MediaThumbnail(
              mediaInfo: _mediaInfoList[0],
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 4), // Increased separator
        Expanded(
          child: GestureDetector(
            onTap: () => _openFullScreen(context, 1),
            child: MediaThumbnail(
              mediaInfo: _mediaInfoList[1],
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreeMedia(BuildContext context, double height) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _openFullScreen(context, 0),
            child: MediaThumbnail(
              mediaInfo: _mediaInfoList[0],
              height: height,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 4), // Increased separator
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 1),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[1],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4), // Increased separator
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 2),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[2],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourMedia(BuildContext context, double height) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 0),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 4), // Increased separator
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 1),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[1],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4), // Increased separator
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 2),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[2],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 4), // Increased separator
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 3),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[3],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiveOrMoreMedia(BuildContext context, double height, int count) {
    final remainingCount = count - 4;
    
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 0),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[0],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 4), // Increased separator
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 1),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[1],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4), // Increased separator
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 2),
                  child: MediaThumbnail(
                    mediaInfo: _mediaInfoList[2],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 4), // Increased separator
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullScreen(context, 3),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MediaThumbnail(
                        mediaInfo: _mediaInfoList[3],
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '+$remainingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }  @override
  Widget build(BuildContext context) {
    if (mediaUrls.isEmpty) return const SizedBox.shrink();
    return _buildGridLayout(context);
  }
}

class MediaThumbnail extends StatefulWidget {
  final MediaInfo mediaInfo;
  final BoxFit fit;
  final double? width;
  final double? height;

  const MediaThumbnail({
    super.key,
    required this.mediaInfo,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaInfo.type == MediaType.video) {
      _initializeVideoThumbnail();
    }
  }

  Future<void> _initializeVideoThumbnail() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaInfo.url),
      );

      await _controller!.initialize();

      // Seek to a frame for thumbnail (1 second in)
      if (_controller!.value.duration.inSeconds > 1) {
        await _controller!.seekTo(const Duration(seconds: 1));
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildVideoThumbnail() {
    if (_hasError) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.lightGray,
        child: const Center(
          child: Icon(Icons.error, color: AppColors.gray, size: 32),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: AppColors.lightGray,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryLimeGreen,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
        ),
        // Centered play button
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        if (_controller!.value.duration.inSeconds > 0)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(_controller!.value.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildImageThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.mediaInfo.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        placeholder: (context, url) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryLimeGreen,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: AppColors.gray, size: 32),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: widget.width,
        height: widget.height,
        child: widget.mediaInfo.type == MediaType.video
            ? _buildVideoThumbnail()
            : _buildImageThumbnail(),
      ),
    );
  }
}

// Full Screen Media Viewer
class FullScreenMediaViewer extends StatefulWidget {
  final List<MediaInfo> mediaInfoList;
  final int initialIndex;

  const FullScreenMediaViewer({
    super.key,
    required this.mediaInfoList,
    required this.initialIndex,
  });

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaInfoList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _toggleControls,
                child: FullScreenMediaItem(
                  mediaInfo: widget.mediaInfoList[index],
                ),
              );
            },
          ),
          if (_showControls)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                          const Spacer(),
                          Text(
                            '${_currentIndex + 1} / ${widget.mediaInfoList.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Bottom indicator
                    if (widget.mediaInfoList.length > 1)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.mediaInfoList.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == _currentIndex
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenMediaItem extends StatefulWidget {
  final MediaInfo mediaInfo;

  const FullScreenMediaItem({super.key, required this.mediaInfo});

  @override
  State<FullScreenMediaItem> createState() => _FullScreenMediaItemState();
}

class _FullScreenMediaItemState extends State<FullScreenMediaItem> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaInfo.type == MediaType.video) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaInfo.url),
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      _controller!.addListener(() {
        if (mounted && _controller!.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing full-screen video: $e');
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildVideo() {
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLimeGreen),
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(_controller!),
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 0.8,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: widget.mediaInfo.url,
          fit: BoxFit.contain,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryLimeGreen,
              ),
            ),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 64),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.mediaInfo.type == MediaType.video
        ? _buildVideo()
        : _buildImage();
  }
}
