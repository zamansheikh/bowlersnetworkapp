// Hide `State` because dartz exports a `State` monad that shadows the
// Flutter State<T> class used by every [StatefulWidget].
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
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/create_post_draft.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../bloc/feed_bloc.dart';

enum CreatePostKind { text, photo, video, score, poll }

/// Full-screen composer supporting all 5 post types (matches the web's
/// `CreatePostModal` tab set).
///
/// Open via [showCreatePostSheet]. On success prepends the new post to
/// [FeedBloc] so the feed updates without a refetch.
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

/// Public helpers so [CreatePostComposer]'s action-chip handlers can pick
/// the right initial tab without exposing the private enum.
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

  // Shared
  final _captionCtl = TextEditingController();

  // Photo
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

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<void> _pickPhotos() async {
    final picked =
        await getIt<ImagePickerService>().pickImages(limit: 4);
    if (picked.isEmpty) return;
    setState(() {
      _photos
        ..clear()
        ..addAll(picked.map((p) => (bytes: p.bytes, name: p.name)));
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
          _errors = ['Pick at least one photo.'];
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
              result = r.map((_) => throw StateError('unreachable'));
              break;
            }
            urls.add(url);
          }
          if (urls.length != _photos.length) {
            setState(() {
              _busy = false;
              _errors = ['One or more photos failed to upload.'];
            });
            return;
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
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtl) => Container(
          decoration: BoxDecoration(
            color: colors.bgSurfaceElevated,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
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
              const SizedBox(height: AppSpacing.md),
              _Header(
                onClose: () => Navigator.of(context).pop(),
                onSubmit: _busy ? null : _submit,
                busy: _busy,
              ),
              _KindTabs(
                active: _kind,
                onChanged: (k) => setState(() => _kind = k),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtl,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    0,
                    AppSpacing.base,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CaptionField(controller: _captionCtl, kind: _kind),
                      const SizedBox(height: AppSpacing.md),
                      _KindBody(
                        kind: _kind,
                        photos: _photos,
                        onPickPhotos: _pickPhotos,
                        onRemovePhoto: (i) =>
                            setState(() => _photos.removeAt(i)),
                        video: _video,
                        onPickVideo: _pickVideo,
                        onRemoveVideo: () =>
                            setState(() => _video = null),
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
                            : () => setState(
                                () => _pollOptionCtls.add(TextEditingController())),
                        onRemoveOption: _pollOptionCtls.length <= 2
                            ? null
                            : (i) => setState(() {
                                  _pollOptionCtls.removeAt(i).dispose();
                                }),
                        expiryHours: _expiryHours,
                        onExpiryChanged: (h) =>
                            setState(() => _expiryHours = h),
                      ),
                      if (_errors.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        _ErrorBanner(messages: _errors),
                      ],
                    ],
                  ),
                ),
              ),
              _AudienceBar(
                audience: _audience,
                onChanged: (a) => setState(() => _audience = a),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.onClose,
    required this.onSubmit,
    required this.busy,
  });

  final VoidCallback onClose;
  final VoidCallback? onSubmit;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.x, size: 20, color: colors.textSecondary),
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          Text(
            'New post',
            style: AppTextStyles.sectionTitle.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 88,
            child: AppButton(
              label: busy ? 'Posting' : 'Post',
              size: AppButtonSize.small,
              loading: busy,
              onPressed: onSubmit,
              expand: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _KindTabs extends StatelessWidget {
  const _KindTabs({required this.active, required this.onChanged});

  final CreatePostKind active;
  final ValueChanged<CreatePostKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = const [
      (CreatePostKind.text, LucideIcons.pencil, 'Text'),
      (CreatePostKind.photo, LucideIcons.image, 'Photo'),
      (CreatePostKind.video, LucideIcons.video, 'Video'),
      (CreatePostKind.score, LucideIcons.target, 'Score'),
      (CreatePostKind.poll, LucideIcons.chartColumn, 'Poll'),
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (_, i) {
          final (k, icon, label) = items[i];
          final on = active == k;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.fullAll,
              onTap: () => onChanged(k),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: on
                      ? colors.accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: AppRadius.fullAll,
                  border: Border.all(
                    color: on ? colors.accent : colors.borderDefault,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: on ? colors.accent : colors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: on ? colors.accent : colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CaptionField extends StatelessWidget {
  const _CaptionField({required this.controller, required this.kind});

  final TextEditingController controller;
  final CreatePostKind kind;

  String get _hint => switch (kind) {
        CreatePostKind.text => "What's on your mind?",
        CreatePostKind.photo => 'Say something about these photos…',
        CreatePostKind.video => 'Say something about this video…',
        CreatePostKind.score => 'Add a comment about this game…',
        CreatePostKind.poll => 'Add context for the poll…',
      };

  @override
  Widget build(BuildContext context) {
    return AppInput(
      controller: controller,
      hint: _hint,
      maxLines: 5,
      minLines: 3,
    );
  }
}

class _KindBody extends StatelessWidget {
  const _KindBody({
    required this.kind,
    required this.photos,
    required this.onPickPhotos,
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

  // Photo
  final List<({Uint8List bytes, String name})> photos;
  final VoidCallback onPickPhotos;
  final ValueChanged<int> onRemovePhoto;

  // Video
  final ({Uint8List bytes, String name})? video;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  // Score
  final TextEditingController scoreCtl;
  final TextEditingController strikePctCtl;
  final TextEditingController splitCountCtl;
  final GameType gameType;
  final ValueChanged<GameType> onGameTypeChanged;

  // Poll
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
        return _PhotoGridPicker(
          photos: photos,
          onPickPhotos: onPickPhotos,
          onRemovePhoto: onRemovePhoto,
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
class _PhotoGridPicker extends StatelessWidget {
  const _PhotoGridPicker({
    required this.photos,
    required this.onPickPhotos,
    required this.onRemovePhoto,
  });

  final List<({Uint8List bytes, String name})> photos;
  final VoidCallback onPickPhotos;
  final ValueChanged<int> onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (photos.isEmpty) {
      return _MediaDropZone(
        icon: LucideIcons.image,
        label: 'Pick photos',
        hint: 'Up to 4 images',
        onTap: onPickPhotos,
      );
    }
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (var i = 0; i < photos.length; i++)
          _PickedThumb(
            key: ValueKey('photo-$i'),
            bytes: photos[i].bytes,
            onRemove: () => onRemovePhoto(i),
          ),
        if (photos.length < 4)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.mdAll,
              onTap: onPickPhotos,
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colors.borderStrong,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: AppRadius.mdAll,
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.plus,
                  size: 22,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PickedThumb extends StatelessWidget {
  const _PickedThumb({
    super.key,
    required this.bytes,
    required this.onRemove,
  });

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: Image.memory(
            bytes,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black87,
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
      return _MediaDropZone(
        icon: LucideIcons.video,
        label: 'Pick a video',
        hint: 'Up to 90 seconds',
        onTap: onPick,
      );
    }
    final v = video!;
    final sizeKb = (v.bytes.lengthInBytes / 1024).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.accentSubtle,
              borderRadius: AppRadius.smAll,
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.video, size: 20, color: colors.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  v.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$sizeKb KB',
                  style: AppTextStyles.micro
                      .copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, size: 18, color: colors.textSecondary),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _MediaDropZone extends StatelessWidget {
  const _MediaDropZone({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: colors.borderDefault),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors.accentSubtle,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: colors.accent),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hint,
                style: AppTextStyles.secondary
                    .copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
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
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          controller: scoreCtl,
          label: 'Total Score',
          hint: '0 – 300',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'GAME TYPE',
          style: AppTextStyles.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < GameType.values.length; i++) ...[
              Expanded(
                child: _SegmentButton(
                  label: GameType.values[i].label,
                  active: gameType == GameType.values[i],
                  onTap: () => onGameTypeChanged(GameType.values[i]),
                ),
              ),
              if (i < GameType.values.length - 1)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppInput(
                controller: strikePctCtl,
                label: 'Strike %',
                hint: '0 – 100',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppInput(
                controller: splitCountCtl,
                label: 'Splits',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: active
                ? colors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? colors.accent : colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
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
    final expiries = const [12, 24, 48, 72, 168];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          controller: questionCtl,
          label: 'Question',
          hint: 'Ask your question',
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'OPTIONS',
          style: AppTextStyles.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < optionCtls.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: AppInput(
                    controller: optionCtls[i],
                    hint: 'Option ${i + 1}',
                  ),
                ),
                if (onRemoveOption != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: colors.textTertiary,
                    ),
                    onPressed: () => onRemoveOption!(i),
                  ),
                ],
              ],
            ),
          ),
        if (onAddOption != null)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddOption,
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Add option'),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'CLOSES IN',
          style: AppTextStyles.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final h in expiries)
              _SegmentButtonFit(
                label: h < 24 ? '${h}h' : '${h ~/ 24}d',
                active: expiryHours == h,
                onTap: () => onExpiryChanged(h),
              ),
          ],
        ),
      ],
    );
  }
}

class _SegmentButtonFit extends StatelessWidget {
  const _SegmentButtonFit({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: active
                ? colors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? colors.accent : colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _AudienceBar extends StatelessWidget {
  const _AudienceBar({required this.audience, required this.onChanged});

  final PostAudience audience;
  final ValueChanged<PostAudience> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border(top: BorderSide(color: colors.borderDefault)),
        ),
        child: Row(
          children: [
            Icon(
              _iconFor(audience),
              size: 14,
              color: colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Audience:',
              style: AppTextStyles.bodySmall
                  .copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in PostAudience.values)
                    _AudienceChip(
                      label: a.label,
                      active: audience == a,
                      onTap: () => onChanged(a),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(PostAudience a) => switch (a) {
        PostAudience.public => LucideIcons.globe,
        PostAudience.followers => LucideIcons.users,
        PostAudience.center => LucideIcons.mapPin,
        PostAudience.private => LucideIcons.lock,
      };
}

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? colors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.micro.copyWith(
              color: active ? colors.accent : colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

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
                  Icon(
                    LucideIcons.circleAlert,
                    size: 14,
                    color: colors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      m,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: colors.error),
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
