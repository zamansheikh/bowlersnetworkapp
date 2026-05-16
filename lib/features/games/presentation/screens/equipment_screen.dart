import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/equipment.dart';
import '../bloc/equipment_bloc.dart';
import '../widgets/ball_picker_sheet.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EquipmentBloc>(
      create: (_) =>
          getIt<EquipmentBloc>()..add(const EquipmentLoadRequested()),
      child: const _EquipmentView(),
    );
  }
}

class _EquipmentView extends StatelessWidget {
  const _EquipmentView();

  Future<void> _addBall(BuildContext context) async {
    final bloc = context.read<EquipmentBloc>();
    final added = await showBallPickerSheet(context);
    if (added != null) bloc.add(EquipmentAdded(added));
  }

  Future<bool> _confirmDelete(BuildContext context, UserBall ball) async {
    final colors = context.colors;
    final result = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: colors.bgSurfaceElevated,
        title: Text(
          'Remove ${ball.ball.name}?',
          style: AppTextStyles.sectionTitle.copyWith(
            color: colors.textPrimary,
            fontSize: 16,
          ),
        ),
        content: Text(
          'This ball will be removed from your loadout. Your existing game data won\'t change.',
          style: AppTextStyles.body.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonLabel.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: Text(
              'Remove',
              style: AppTextStyles.buttonLabel.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(title: const Text('My Equipment')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 18),
        label: Text(
          'Add ball',
          style: AppTextStyles.buttonLabel.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: () => _addBall(context),
      ),
      body: BlocBuilder<EquipmentBloc, EquipmentState>(
        builder: (context, state) {
          if (state.loading && state.balls.isEmpty) {
            return const _EquipmentSkeleton();
          }
          if (state.balls.isEmpty) {
            return EmptyState(
              icon: LucideIcons.target,
              title: 'No balls yet',
              hint: state.errors.isNotEmpty
                  ? state.errors.join('\n')
                  : 'Pick from our catalog to start tracking your loadout.',
              action: AppButton(
                label: 'Add your first ball',
                onPressed: () => _addBall(context),
              ),
            );
          }
          return RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context
                  .read<EquipmentBloc>()
                  .add(const EquipmentRefreshRequested());
              await context
                  .read<EquipmentBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                80,
              ),
              itemCount: state.balls.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final ball = state.balls[i];
                return _UserBallCard(
                  ball: ball,
                  stats: state.stats[ball.id],
                  onDelete: () async {
                    final ok = await _confirmDelete(context, ball);
                    if (!ok || !context.mounted) return;
                    context
                        .read<EquipmentBloc>()
                        .add(EquipmentDeleteRequested(ball.id));
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _UserBallCard extends StatelessWidget {
  const _UserBallCard({
    required this.ball,
    required this.stats,
    required this.onDelete,
  });

  final UserBall ball;
  final BallStats? stats;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _BallAvatar(ball: ball.ball),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ball.ball.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (ball.ball.brand != null) ...[
                          Flexible(
                            child: Text(
                              ball.ball.brand!.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.secondary
                                  .copyWith(color: colors.textTertiary),
                            ),
                          ),
                          Text(
                            '  ·  ',
                            style: AppTextStyles.secondary
                                .copyWith(color: colors.textTertiary),
                          ),
                        ],
                        Text(
                          '${ball.weight} lb',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove ball',
                icon: Icon(LucideIcons.trash2,
                    size: 16, color: colors.textTertiary),
                onPressed: onDelete,
              ),
            ],
          ),
          if (stats?.hasUsage == true) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.borderDefault.withValues(alpha: 0.6),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Games',
                      value: '${stats!.gamesPlayed}',
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: 'First-ball avg',
                      value: stats!.firstBallAvg.toStringAsFixed(1),
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      label: 'Strikes',
                      value: '${stats!.strikeRate.toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ),
            ),
          ] else if (stats != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Throw a few frames with this ball to see stats.',
                textAlign: TextAlign.center,
                style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

class _BallAvatar extends StatelessWidget {
  const _BallAvatar({required this.ball});
  final CatalogBall ball;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.bgSurfaceHover,
      ),
      clipBehavior: Clip.antiAlias,
      child: ball.ballImage.isEmpty
          ? Icon(LucideIcons.circle, color: colors.textTertiary)
          : CachedNetworkImage(
              imageUrl: ball.ballImage,
              fit: BoxFit.cover,
            ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.nano.copyWith(
            color: colors.textTertiary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _EquipmentSkeleton extends StatelessWidget {
  const _EquipmentSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonCard(height: 96),
    );
  }
}
