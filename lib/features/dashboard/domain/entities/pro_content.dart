import 'package:equatable/equatable.dart';

/// Response of /api/pro/content. `heatmap` is a 7×24 matrix of counts
/// (Mon-Sun rows, 0-23h columns) in the viewer's local time.
class ProContent extends Equatable {
  const ProContent({
    this.windowDays = 7,
    this.summary = const ProContentSummary(),
    this.topPosts = const [],
    this.topVideos = const [],
    this.topSplits = const [],
    this.topDiscussions = const [],
    this.heatmap = const [],
  });

  final int windowDays;
  final ProContentSummary summary;
  final List<ProContentRow> topPosts;
  final List<ProContentRow> topVideos;
  final List<ProContentRow> topSplits;
  final List<ProContentRow> topDiscussions;

  /// 7 rows × 24 cells. Cells are post counts at that day/hour.
  final List<List<int>> heatmap;

  @override
  List<Object?> get props => [
        windowDays,
        summary,
        topPosts,
        topVideos,
        topSplits,
        topDiscussions,
        heatmap,
      ];
}

class ProContentSummary extends Equatable {
  const ProContentSummary({
    this.posts = 0,
    this.videos = 0,
    this.splits = 0,
    this.discussions = 0,
    this.total = 0,
  });
  final int posts;
  final int videos;
  final int splits;
  final int discussions;
  final int total;
  @override
  List<Object?> get props => [posts, videos, splits, discussions, total];
}

class ProContentRow extends Equatable {
  const ProContentRow({
    required this.uid,
    this.label = '',
    this.createdAt,
    this.impressions = 0,
    this.reach = 0,
    this.engagement = 0,
    this.engagementRate = 0,
    this.previewUrl = '',
    this.previewKind = 'placeholder',
  });

  final String uid;
  final String label;
  final DateTime? createdAt;
  final int impressions;
  final int reach;
  final int engagement;
  final double engagementRate;
  final String previewUrl;
  final String previewKind;

  @override
  List<Object?> get props => [
        uid,
        label,
        createdAt,
        impressions,
        reach,
        engagement,
        engagementRate,
        previewUrl,
        previewKind,
      ];
}
