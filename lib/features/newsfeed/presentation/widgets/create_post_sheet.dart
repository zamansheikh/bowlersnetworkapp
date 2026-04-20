// Hide `State` because dartz exports a `State` monad that shadows the
// Flutter State<T> class used by every [StatefulWidget].
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/cloud_upload_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/create_post_draft.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../bloc/feed_bloc.dart';

enum CreatePostKind { text, photo, video, score, poll }

/// Web-parity create-post modal, ported to Flutter as a bottom sheet so it
/// feels native on mobile. Layout mirrors `_Content.tsx CreatePostModal`:
///
/// ```
/// [×]   Create Post
/// ──────────────────────────────────────
/// [avatar] Name · @username
/// [Text] [Photo] [Video] [Score] [Poll]    ← compact chips, wrap
/// ┌────────────────────────────────────┐
/// │ What's on your mind?               │   ← textarea, always visible
/// └────────────────────────────────────┘
/// (type-specific fields appear here)
/// ──────────────────────────────────────
/// [🌐][👥][🏠][🔒]                  [Post]  ← audience icons left, Post right
/// ```
Future<void> showCreatePostSheet(
  BuildContext context, {
  CreatePostKind initial = CreatePostKind.text,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => BlocProvider.value(
      value: context.read<FeedBloc>(),
      child: _CreatePostSheet(initial: initial),
    ),
  );
}

Future<void> openCreateText(BuildContext c) =>
    showCreatePostSheet(c, initial: CreatePostKind.text);
Future<void> openCreatePhoto(BuildContext c) =>
    showCreatePostSheet(c, initial: CreatePostKind.photo);
Future<void> openCreateVideo(BuildContext c) =>
    showCreatePostSheet(c, initial: CreatePostKind.video);
Future<void> openCreateScore(BuildContext c) =>
    showCreatePostSheet(c, initial: CreatePostKind.score);
Future<void> openCreatePoll(BuildContext c) =>
    showCreatePostSheet(c, initial: CreatePostKind.poll);

// =============================================================================
class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet({required this.initial});
  final CreatePostKind initial;

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  late CreatePostKind _kind = widget.initial;
  PostAudience _audience = PostAudience.public;

  final _captionCtl = TextEditingController();

  // Photo — web supports single photo; keep multi-capable list.
  final List<({Uint8List bytes, String name})> _photos = [];

  // Video
  ({Uint8List bytes, String name})? _video;

  // Score
  final _scoreCtl = TextEditingController();
  final _strikePctCtl = TextEditingController();
  final _splitCountCtl = TextEditingController();
  GameType _gameType = GameType.practice;

  // Poll
  final _questionCtl = TextEditingController();
  final _pollOptionCtls = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  int _expiryHours = 24;

  bool _busy = false;
  List<String> _errors = const [];

  @override
  void dispose() {
    _captionCtl.dispose();
    _scoreCtl.dispose();
    _strikePctCtl.dispose();
    _splitCountCtl.dispose();
    _questionCtl.dispose();
    for (final c in _pollOptionCtls) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Pickers ────────────────────────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    final picked = await getIt<ImagePickerService>().pickImage();
    if (picked == null) return;
    setState(() {
      _photos
        ..clear()
        ..add((bytes: picked.bytes, name: picked.name));
    });
  }

  Future<void> _pickVideo() async {
    final picked = await getIt<ImagePickerService>().pickVideo();
    if (picked == null) return;
    setState(() => _video = (bytes: picked.bytes, name: picked.name));
  }

  bool _validate() {
    _errors = const [];
    switch (_kind) {
      case CreatePostKind.text:
        if (_captionCtl.text.trim().isEmpty) {
          _errors = ['Write something before posting.'];
          return false;
        }
      case CreatePostKind.photo:
        if (_photos.isEmpty) {
          _errors = ['Pick a photo.'];
          return false;
        }
      case CreatePostKind.video:
        if (_video == null) {
          _errors = ['Pick a video.'];
          return false;
        }
      case CreatePostKind.score:
        final s = int.tryParse(_scoreCtl.text.trim());
        if (s == null || s < 0 || s > 300) {
          _errors = ['Total score must be between 0 and 300.'];
          return false;
        }
      case CreatePostKind.poll:
        if (_questionCtl.text.trim().isEmpty) {
          _errors = ['Write a question.'];
          return false;
        }
        final nonEmpty = _pollOptionCtls
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
        if (nonEmpty.length < 2) {
          _errors = ['Add at least 2 options.'];
          return false;
        }
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) {
      setState(() {});
      return;
    }
    setState(() => _busy = true);

    final repo = getIt<NewsfeedRepository>();
    final upload = getIt<CloudUploadService>();
    final caption = _captionCtl.text.trim();
    final audience = _audience.apiValue;

    Either<Failure, Post> result;
    try {
      switch (_kind) {
        case CreatePostKind.text:
          result = await repo.createTextPost(
              caption: caption, audience: audience);

        case CreatePostKind.photo:
          final urls = <String>[];
          for (final p in _photos) {
            final r = await upload.uploadFile(
              fileBytes: p.bytes,
              fileName: p.name,
              bucket: 'media',
            );
            final url = r.fold((_) => null, (u) => u);
            if (url == null) {
              setState(() {
                _busy = false;
                _errors = r.fold((f) => f.messages, (_) => ['Upload failed.']);
              });
              return;
            }
            urls.add(url);
          }
          result = await repo.createPhotoPost(
            caption: caption,
            audience: audience,
            mediaUrls: urls,
          );

        case CreatePostKind.video:
          final v = _video!;
          final r = await upload.uploadFile(
            fileBytes: v.bytes,
            fileName: v.name,
            bucket: 'media',
          );
          final videoUrl = r.fold((_) => null, (u) => u);
          if (videoUrl == null) {
            setState(() {
              _busy = false;
              _errors = r.fold((f) => f.messages, (_) => ['Upload failed.']);
            });
            return;
          }
          result = await repo.createVideoPost(
            caption: caption,
            audience: audience,
            videoUrl: videoUrl,
          );

        case CreatePostKind.score:
          result = await repo.createScorePost(
            caption: caption,
            audience: audience,
            totalScore: int.parse(_scoreCtl.text.trim()),
            gameType: _gameType.apiValue,
            strikePercentage: double.tryParse(_strikePctCtl.text.trim()),
            splitCount: int.tryParse(_splitCountCtl.text.trim()),
          );

        case CreatePostKind.poll:
          final options = _pollOptionCtls
              .map((c) => c.text.trim())
              .where((t) => t.isNotEmpty)
              .toList();
          result = await repo.createPollPost(
            caption: caption,
            audience: audience,
            question: _questionCtl.text.trim(),
            options: options,
            expiryHours: _expiryHours,
          );
      }
    } catch (e) {
      setState(() {
        _busy = false;
        _errors = ['Something went wrong: $e'];
      });
      return;
    }

    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _busy = false;
        _errors = f.messages;
      }),
      (post) {
        context.read<FeedBloc>().add(FeedPostCreated(post));
        Navigator.of(context).pop();
        showAppToast(
          context,
          message: 'Posted!',
          variant: ToastVariant.success,
        );
      },
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderStrong,
                borderRadius: AppRadius.fullAll,
              ),
            ),
            _Header(onClose: () => Navigator.of(context).pop()),
            Divider(height: 1, color: colors.borderDefault),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.base,
                  AppSpacing.xl,
                  AppSpacing.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AuthorRow(),
                    const SizedBox(height: AppSpacing.base),
                    _KindTabs(
                      active: _kind,
                      onChanged: (k) => setState(() => _kind = k),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _CaptionArea(controller: _captionCtl, kind: _kind),
                    if (_kind != CreatePostKind.text) ...[
                      const SizedBox(height: AppSpacing.md),
                      _TypeBody(
                        kind: _kind,
                        photos: _photos,
                        onPickPhoto: _pickPhoto,
                        onRemovePhoto: () => setState(() => _photos.clear()),
                        video: _video,
                        onPickVideo: _pickVideo,
                        onRemoveVideo: () => setState(() => _video = null),
                        scoreCtl: _scoreCtl,
                        strikePctCtl: _strikePctCtl,
                        splitCountCtl: _splitCountCtl,
                        gameType: _gameType,
                        onGameTypeChanged: (g) =>
                            setState(() => _gameType = g),
                        questionCtl: _questionCtl,
                        pollOptionCtls: _pollOptionCtls,
                        onAddOption: _pollOptionCtls.length >= 5
                            ? null
                            : () => setState(() => _pollOptionCtls
                                .add(TextEditingController())),
                        onRemoveOption: _pollOptionCtls.length <= 2
                            ? null
                            : (i) => setState(() {
                                  _pollOptionCtls.removeAt(i).dispose();
                                }),
                        expiryHours: _expiryHours,
                        onExpiryChanged: (h) =>
                            setState(() => _expiryHours = h),
                      ),
                    ],
                    if (_errors.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _ErrorBanner(messages: _errors),
                    ],
                  ],
                ),
              ),
            ),
            _Footer(
              audience: _audience,
              onAudienceChanged: (a) => setState(() => _audience = a),
              onPost: _busy ? null : _submit,
              busy: _busy,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Header: close button + "Create Post" title
// =============================================================================
class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: Icon(LucideIcons.x, size: 20, color: colors.textSecondary),
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            tooltip: 'Close',
          ),
          Expanded(
            child: Center(
              child: Text(
                'Create Post',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44 + AppSpacing.sm),
        ],
      ),
    );
  }
}

// =============================================================================
// Author row
// =============================================================================
class _AuthorRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, n) =>
          p.profile?.user.id != n.profile?.user.id ||
          p.profile?.profilePictureUrl != n.profile?.profilePictureUrl,
      builder: (context, state) {
        final user = state.profile?.user;
        final name = user == null
            ? 'You'
            : '${user.firstName} ${user.lastName}'.trim().isEmpty
                ? user.username
                : '${user.firstName} ${user.lastName}'.trim();
        final username = user?.username ?? '';
        final avatar = state.profile?.profilePictureUrl;

        return Row(
          children: [
            _AuthorAvatar(url: avatar, fallback: name),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (username.isNotEmpty)
                    Text(
                      '@$username',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.url, required this.fallback});

  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const size = 36.0;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();

    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.micro.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );

    if (url == null || url!.isEmpty) return placeholder;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

// =============================================================================
// Type tabs — compact chips, wrap (matches web `flex gap-1 flex-wrap`)
// =============================================================================
class _KindTabs extends StatelessWidget {
  const _KindTabs({required this.active, required this.onChanged});

  final CreatePostKind active;
  final ValueChanged<CreatePostKind> onChanged;

  static const _items = [
    (CreatePostKind.text, LucideIcons.pencil, 'Text'),
    (CreatePostKind.photo, LucideIcons.image, 'Photo'),
    (CreatePostKind.video, LucideIcons.video, 'Video'),
    (CreatePostKind.score, LucideIcons.target, 'Score'),
    (CreatePostKind.poll, LucideIcons.chartColumn, 'Poll'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (k, icon, label) in _items)
          _TabChip(
            icon: icon,
            label: label,
            active: active == k,
            onTap: () => onChanged(k),
            accent: colors.accent,
            accentBg: colors.accentSubtle,
            dim: colors.textTertiary,
          ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.accent,
    required this.accentBg,
    required this.dim,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color accent;
  final Color accentBg;
  final Color dim;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: active ? accentBg : Colors.transparent,
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: active ? accent.withValues(alpha: 0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: active ? accent : dim),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.micro.copyWith(
                  color: active ? accent : dim,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Caption textarea — always visible, 3 rows
// =============================================================================
class _CaptionArea extends StatelessWidget {
  const _CaptionArea({required this.controller, required this.kind});

  final TextEditingController controller;
  final CreatePostKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        minLines: 3,
        autofocus: kind == CreatePostKind.text,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.textPrimary,
          fontSize: 13,
        ),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          hintText: "What's on your mind?",
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: colors.textTertiary,
            fontSize: 13,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// =============================================================================
// Type-body
// =============================================================================
class _TypeBody extends StatelessWidget {
  const _TypeBody({
    required this.kind,
    required this.photos,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.video,
    required this.onPickVideo,
    required this.onRemoveVideo,
    required this.scoreCtl,
    required this.strikePctCtl,
    required this.splitCountCtl,
    required this.gameType,
    required this.onGameTypeChanged,
    required this.questionCtl,
    required this.pollOptionCtls,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.expiryHours,
    required this.onExpiryChanged,
  });

  final CreatePostKind kind;

  final List<({Uint8List bytes, String name})> photos;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  final ({Uint8List bytes, String name})? video;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  final TextEditingController scoreCtl;
  final TextEditingController strikePctCtl;
  final TextEditingController splitCountCtl;
  final GameType gameType;
  final ValueChanged<GameType> onGameTypeChanged;

  final TextEditingController questionCtl;
  final List<TextEditingController> pollOptionCtls;
  final VoidCallback? onAddOption;
  final ValueChanged<int>? onRemoveOption;
  final int expiryHours;
  final ValueChanged<int> onExpiryChanged;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case CreatePostKind.text:
        return const SizedBox.shrink();
      case CreatePostKind.photo:
        return _PhotoPicker(
          photos: photos,
          onPick: onPickPhoto,
          onRemove: onRemovePhoto,
        );
      case CreatePostKind.video:
        return _VideoPicker(
          video: video,
          onPick: onPickVideo,
          onRemove: onRemoveVideo,
        );
      case CreatePostKind.score:
        return _ScoreForm(
          scoreCtl: scoreCtl,
          strikePctCtl: strikePctCtl,
          splitCountCtl: splitCountCtl,
          gameType: gameType,
          onGameTypeChanged: onGameTypeChanged,
        );
      case CreatePostKind.poll:
        return _PollForm(
          questionCtl: questionCtl,
          optionCtls: pollOptionCtls,
          onAddOption: onAddOption,
          onRemoveOption: onRemoveOption,
          expiryHours: expiryHours,
          onExpiryChanged: onExpiryChanged,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photos,
    required this.onPick,
    required this.onRemove,
  });

  final List<({Uint8List bytes, String name})> photos;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return _DashedDropZone(
        icon: LucideIcons.image,
        label: 'Click to upload photo',
        onTap: onPick,
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 192),
            child: Image.memory(
              photos.first.bytes,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.x, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoPicker extends StatelessWidget {
  const _VideoPicker({
    required this.video,
    required this.onPick,
    required this.onRemove,
  });

  final ({Uint8List bytes, String name})? video;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (video == null) {
      return _DashedDropZone(
        icon: LucideIcons.video,
        label: 'Click to upload video',
        onTap: onPick,
      );
    }
    final v = video!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.video, size: 16, color: colors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              v.name,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, size: 14, color: colors.textTertiary),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _DashedDropZone extends StatelessWidget {
  const _DashedDropZone({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: colors.borderStrong,
            radius: AppRadius.lg,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xl,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: colors.textTertiary),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed outline — Flutter's default Container border doesn't dash, so we
/// paint it ourselves. Matches web's `border-2 border-dashed`.
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashLen = 6.0;
    const gapLen = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance = end + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

// =============================================================================
// Score form — grid-cols-2 x 2 rows (Total/GameType, Strike%/Splits)
// =============================================================================
class _ScoreForm extends StatelessWidget {
  const _ScoreForm({
    required this.scoreCtl,
    required this.strikePctCtl,
    required this.splitCountCtl,
    required this.gameType,
    required this.onGameTypeChanged,
  });

  final TextEditingController scoreCtl;
  final TextEditingController strikePctCtl;
  final TextEditingController splitCountCtl;
  final GameType gameType;
  final ValueChanged<GameType> onGameTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Total Score',
                child: _NumberField(controller: scoreCtl, hint: '279'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _LabeledField(
                label: 'Game Type',
                child: _GameTypeDropdown(
                  value: gameType,
                  onChanged: onGameTypeChanged,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _LabeledField(
                label: 'Strike %',
                child: _NumberField(
                  controller: strikePctCtl,
                  hint: '45.5',
                  allowDecimal: true,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _LabeledField(
                label: 'Split Count',
                child: _NumberField(controller: splitCountCtl, hint: '3'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.hint,
    this.allowDecimal = false,
  });
  final TextEditingController controller;
  final String hint;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderStrong),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
        inputFormatters: allowDecimal
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.body.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
            color: colors.textTertiary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _GameTypeDropdown extends StatelessWidget {
  const _GameTypeDropdown({required this.value, required this.onChanged});

  final GameType value;
  final ValueChanged<GameType> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GameType>(
          value: value,
          isExpanded: true,
          icon: Icon(LucideIcons.chevronDown,
              size: 14, color: colors.textTertiary),
          dropdownColor: colors.bgSurfaceElevated,
          style: AppTextStyles.body.copyWith(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          items: [
            for (final g in GameType.values)
              DropdownMenuItem(value: g, child: Text(g.label)),
          ],
          onChanged: (g) {
            if (g != null) onChanged(g);
          },
        ),
      ),
    );
  }
}

// =============================================================================
// Poll form
// =============================================================================
class _PollForm extends StatelessWidget {
  const _PollForm({
    required this.questionCtl,
    required this.optionCtls,
    required this.onAddOption,
    required this.onRemoveOption,
    required this.expiryHours,
    required this.onExpiryChanged,
  });

  final TextEditingController questionCtl;
  final List<TextEditingController> optionCtls;
  final VoidCallback? onAddOption;
  final ValueChanged<int>? onRemoveOption;
  final int expiryHours;
  final ValueChanged<int> onExpiryChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: 'Question',
          child: _SmallTextField(
            controller: questionCtl,
            hint: 'Ask something...',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < optionCtls.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _SmallTextField(
                    controller: optionCtls[i],
                    hint: 'Option ${i + 1}',
                    compact: true,
                  ),
                ),
                if (onRemoveOption != null)
                  IconButton(
                    icon: Icon(
                      LucideIcons.minus,
                      size: 14,
                      color: colors.textTertiary,
                    ),
                    onPressed: () => onRemoveOption!(i),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        Row(
          children: [
            if (onAddOption != null)
              GestureDetector(
                onTap: onAddOption,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.plus, size: 12, color: colors.accent),
                    const SizedBox(width: 4),
                    Text(
                      'Add option',
                      style: AppTextStyles.micro.copyWith(
                        color: colors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Text(
              'Duration: ',
              style: AppTextStyles.micro.copyWith(
                color: colors.textTertiary,
                fontSize: 11,
              ),
            ),
            _DurationDropdown(
              value: expiryHours,
              onChanged: onExpiryChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallTextField extends StatelessWidget {
  const _SmallTextField({
    required this.controller,
    required this.hint,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hint;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: compact ? 36 : 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: compact ? AppRadius.smAll : AppRadius.mdAll,
        border: Border.all(color: colors.borderStrong),
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.body.copyWith(
          color: colors.textPrimary,
          fontSize: compact ? 12 : 13,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
            color: colors.textTertiary,
            fontSize: compact ? 12 : 13,
          ),
        ),
      ),
    );
  }
}

class _DurationDropdown extends StatelessWidget {
  const _DurationDropdown({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  static const _items = [
    (12, '12h'),
    (24, '24h'),
    (48, '2d'),
    (72, '3d'),
    (168, '1w'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: colors.borderStrong),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          icon: Icon(LucideIcons.chevronDown,
              size: 12, color: colors.textTertiary),
          dropdownColor: colors.bgSurfaceElevated,
          style: AppTextStyles.micro.copyWith(
            color: colors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          items: [
            for (final (h, label) in _items)
              DropdownMenuItem(value: h, child: Text(label)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// =============================================================================
// Footer: audience icons left, Post button right
// =============================================================================
class _Footer extends StatelessWidget {
  const _Footer({
    required this.audience,
    required this.onAudienceChanged,
    required this.onPost,
    required this.busy,
  });

  final PostAudience audience;
  final ValueChanged<PostAudience> onAudienceChanged;
  final VoidCallback? onPost;
  final bool busy;

  static const _icons = <PostAudience, IconData>{
    PostAudience.public: LucideIcons.globe,
    PostAudience.followers: LucideIcons.users,
    PostAudience.center: LucideIcons.house,
    PostAudience.private: LucideIcons.lock,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderDefault)),
        ),
        child: Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final a in PostAudience.values)
                  _AudienceIconButton(
                    icon: _icons[a]!,
                    active: audience == a,
                    tooltip: a.label,
                    onTap: () => onAudienceChanged(a),
                  ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: 88,
              child: AppButton(
                label: busy ? 'Posting' : 'Post',
                size: AppButtonSize.regular,
                loading: busy,
                onPressed: onPost,
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceIconButton extends StatelessWidget {
  const _AudienceIconButton({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: onTap,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: active ? colors.accentSubtle : Colors.transparent,
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 14,
              color: active ? colors.accent : colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Error banner
// =============================================================================
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.messages});
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in messages)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.circleAlert, size: 13, color: colors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
