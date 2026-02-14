import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/feed_v3_post.dart';
import '../../data/repositories/feed_v3_repository.dart';
import '../widgets/feed_v3_post_card.dart';
import '../widgets/feed_v3_comments_section.dart';
import '../../../../core/di/injection.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final _repository = getIt<FeedV3Repository>();
  FeedV3Post? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final post = await _repository.getPost(widget.postId);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray900),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Post',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLimeGreen),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.gray600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadPost();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLimeGreen,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_post == null) {
      return const Center(child: Text('Post not found'));
    }

    return RefreshIndicator(
      onRefresh: _loadPost,
      color: AppColors.primaryLimeGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Post card (no tap navigation since we're already on the detail)
            FeedV3PostCard(
              post: _post!,
              onLike: () async {
                try {
                  await _repository.toggleLike(_post!.id);
                  setState(() {
                    _post = _post!.copyWith(
                      hasLiked: !_post!.hasLiked,
                      likesCount:
                          _post!.likesCount + (_post!.hasLiked ? -1 : 1),
                    );
                  });
                } catch (_) {}
              },
              onPollVote: (optionId) async {
                try {
                  await _repository.vote(_post!.id, [optionId]);
                  _loadPost(); // Refresh to get updated poll data
                } catch (_) {}
              },
            ),

            // Comments section (expanded by default on detail page)
            FeedV3CommentsSection(
              postId: widget.postId,
              repository: _repository,
              pageSize: 20,
              onCommentAdded: () {
                _loadPost(); // Refresh comment count
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
