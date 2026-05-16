import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/games_repository.dart';

/// Two-step modal: catalog search → weight grid → POST.
/// Returns the new [UserBall] when added (null on cancel) so the caller
/// can fire [EquipmentAdded].
Future<UserBall?> showBallPickerSheet(BuildContext context) {
  return showModalBottomSheet<UserBall>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _BallPickerSheet(),
  );
}

class _BallPickerSheet extends StatefulWidget {
  const _BallPickerSheet();

  @override
  State<_BallPickerSheet> createState() => _BallPickerSheetState();
}

class _BallPickerSheetState extends State<_BallPickerSheet> {
  final _repo = getIt<GamesRepository>();
  final _searchCtl = TextEditingController();
  Timer? _debounce;
  List<CatalogBall> _results = const [];
  bool _searching = false;
  CatalogBall? _pickingBall;
  int? _weight;
  bool _saving = false;
  List<String> _errors = const [];

  @override
  void initState() {
    super.initState();
    _runSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String query) async {
    setState(() => _searching = true);
    final res = await _repo.searchBallCatalog(
      search: query.trim().isEmpty ? null : query.trim(),
    );
    if (!mounted) return;
    res.fold(
      (_) => setState(() {
        _searching = false;
        _results = const [];
      }),
      (data) => setState(() {
        _searching = false;
        _results = data.balls;
      }),
    );
  }

  Future<void> _save() async {
    if (_pickingBall == null || _weight == null) return;
    setState(() {
      _saving = true;
      _errors = const [];
    });
    final res = await _repo.addEquipment(
      ballId: _pickingBall!.id,
      weight: _weight!,
    );
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _saving = false;
        _errors = f.messages;
      }),
      (ball) {
        showAppToast(
          context,
          message: 'Ball added to your loadout.',
          variant: ToastVariant.success,
        );
        Navigator.of(context).pop(ball);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
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
            _GrabHandle(color: colors.borderStrong),
            _Header(
              title: _pickingBall == null ? 'Pick a ball' : 'Pick a weight',
              onBack: _pickingBall == null
                  ? null
                  : () => setState(() {
                        _pickingBall = null;
                        _weight = null;
                      }),
              onClose: () => Navigator.of(context).pop(),
            ),
            if (_pickingBall == null)
              Expanded(child: _CatalogStep(
                searchCtl: _searchCtl,
                searching: _searching,
                results: _results,
                onQueryChanged: _onQueryChanged,
                onPick: (b) => setState(() => _pickingBall = b),
              ))
            else
              Expanded(child: _WeightStep(
                ball: _pickingBall!,
                weight: _weight,
                saving: _saving,
                errors: _errors,
                onWeight: (w) => setState(() => _weight = w),
                onSave: _save,
              )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Catalog step.
// ═══════════════════════════════════════════════════════════════════════════
class _CatalogStep extends StatelessWidget {
  const _CatalogStep({
    required this.searchCtl,
    required this.searching,
    required this.results,
    required this.onQueryChanged,
    required this.onPick,
  });

  final TextEditingController searchCtl;
  final bool searching;
  final List<CatalogBall> results;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<CatalogBall> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.borderStrong),
            ),
            child: TextField(
              controller: searchCtl,
              autofocus: true,
              onChanged: onQueryChanged,
              style: AppTextStyles.body.copyWith(color: colors.textPrimary),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search balls…',
                hintStyle: AppTextStyles.body
                    .copyWith(color: colors.textTertiary, fontSize: 13),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 16,
                  color: colors.textTertiary,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 36),
                suffixIcon: searching
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.accent,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        Expanded(
          child: results.isEmpty && !searching
              ? Center(
                  child: Text(
                    'No balls found',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: colors.textTertiary),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: results.length,
                  itemBuilder: (_, i) =>
                      _CatalogBallTile(ball: results[i], onTap: () => onPick(results[i])),
                ),
        ),
      ],
    );
  }
}

class _CatalogBallTile extends StatelessWidget {
  const _CatalogBallTile({required this.ball, required this.onTap});
  final CatalogBall ball;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderDefault),
            borderRadius: AppRadius.mdAll,
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: ball.ballImage.isEmpty
                      ? Icon(
                          LucideIcons.circle,
                          size: 48,
                          color: colors.textTertiary,
                        )
                      : CachedNetworkImage(
                          imageUrl: ball.ballImage,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ball.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (ball.brand != null)
                Text(
                  ball.brand!.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Weight step.
// ═══════════════════════════════════════════════════════════════════════════
class _WeightStep extends StatelessWidget {
  const _WeightStep({
    required this.ball,
    required this.weight,
    required this.saving,
    required this.errors,
    required this.onWeight,
    required this.onSave,
  });

  final CatalogBall ball;
  final int? weight;
  final bool saving;
  final List<String> errors;
  final ValueChanged<int> onWeight;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ball preview card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.borderDefault),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ball.ballImage.isEmpty
                      ? Icon(LucideIcons.circle, color: colors.textTertiary)
                      : CachedNetworkImage(
                          imageUrl: ball.ballImage,
                          fit: BoxFit.contain,
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ball.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ball.brand != null)
                        Text(
                          ball.brand!.name,
                          style: AppTextStyles.secondary.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'WEIGHT (LB)',
            style: AppTextStyles.label.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final w in ballWeightOptions)
                _WeightChip(
                  weight: w,
                  selected: weight == w,
                  onTap: () => onWeight(w),
                ),
            ],
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              errors.join('\n'),
              style: AppTextStyles.bodySmall.copyWith(color: colors.error),
            ),
          ],
          const Spacer(),
          SafeArea(
            top: false,
            child: AppButton(
              label: saving ? 'Adding…' : 'Add to my loadout',
              loading: saving,
              expand: true,
              size: AppButtonSize.large,
              onPressed: (saving || weight == null) ? null : onSave,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightChip extends StatelessWidget {
  const _WeightChip({
    required this.weight,
    required this.selected,
    required this.onTap,
  });

  final int weight;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.accent : colors.bgSurface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? colors.accent : colors.borderDefault,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$weight',
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? Colors.white : colors.textSecondary,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared bits.
// ═══════════════════════════════════════════════════════════════════════════
class _GrabHandle extends StatelessWidget {
  const _GrabHandle({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.fullAll,
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, this.onBack, required this.onClose});
  final String title;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              icon: Icon(LucideIcons.chevronLeft,
                  size: 20, color: colors.textSecondary),
              onPressed: onBack,
              visualDensity: VisualDensity.compact,
            )
          else
            IconButton(
              icon: Icon(LucideIcons.x,
                  size: 20, color: colors.textSecondary),
              onPressed: onClose,
              visualDensity: VisualDensity.compact,
            ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
