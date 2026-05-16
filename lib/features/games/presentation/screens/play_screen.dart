import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/repositories/games_repository.dart';
import '../bloc/play_bloc.dart';
import '../widgets/pin_deck.dart';
import '../widgets/scorecard.dart';

/// Pin-by-pin scoring screen for a single session. URL convention matches
/// web: `/games/play?session=<uid>`.
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key, required this.sessionUid});

  final String sessionUid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayBloc>(
      create: (_) => PlayBloc(
        repository: getIt<GamesRepository>(),
        sessionUid: sessionUid,
      ),
      child: const _PlayView(),
    );
  }
}

class _PlayView extends StatelessWidget {
  const _PlayView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<PlayBloc, PlayState>(
      listenWhen: (p, n) => p.submittedGame != n.submittedGame || p.errors != n.errors,
      listener: (context, state) {
        if (state.submittedGame != null) {
          HapticFeedback.mediumImpact();
          showAppToast(
            context,
            message: 'Game ${state.submittedGame!.gameNumber} submitted — '
                '${state.submittedGame!.totalScore}',
            variant: ToastVariant.success,
          );
          // Pop back to the games tab.
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.games);
          }
        } else if (state.errors.isNotEmpty) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.bgPrimary,
          appBar: AppBar(
            title: const Text('Score game'),
            actions: [
              IconButton(
                tooltip: 'Undo last ball',
                icon: const Icon(LucideIcons.undo2, size: 18),
                onPressed: () => context
                    .read<PlayBloc>()
                    .add(const PlayDeliveryUndone()),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      children: [
                        _HeaderStrip(state: state),
                        const SizedBox(height: AppSpacing.md),
                        Scorecard(
                          frames: state.score.frames,
                          activeIndex: state.cursor.frameIndex.clamp(0, 9),
                          onFrameTap: (i) => context
                              .read<PlayBloc>()
                              .add(PlayFrameJumped(i)),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CurrentFrameLabel(state: state),
                        const SizedBox(height: AppSpacing.sm),
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: PinDeck(
                            standing: state.activeStanding,
                            onPinTap: state.isGameOver
                                ? null
                                : (pin) => context
                                    .read<PlayBloc>()
                                    .add(PlayPinToggled(pin)),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _QuickActions(disabled: state.isGameOver),
                      ],
                    ),
                  ),
                ),
                _SubmitBar(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Header strip — running total + projected.
// ═══════════════════════════════════════════════════════════════════════════
class _HeaderStrip extends StatelessWidget {
  const _HeaderStrip({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgSurfaceElevated,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatBlock(
              label: 'SCORE',
              value: '${state.score.totalScore}',
              color: colors.accent,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: colors.borderDefault,
          ),
          Expanded(
            child: _StatBlock(
              label: 'PROJECTED',
              value: '${state.score.projectedScore}',
              color: colors.textSecondary,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: colors.borderDefault,
          ),
          Expanded(
            child: _StatBlock(
              label: state.isGameOver ? 'DONE' : 'FRAME',
              value: state.isGameOver
                  ? '✓'
                  : '${state.currentFrameNumber}',
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.sectionTitle.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// "Frame N · Ball M" label above the pin deck.
// ═══════════════════════════════════════════════════════════════════════════
class _CurrentFrameLabel extends StatelessWidget {
  const _CurrentFrameLabel({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (state.isGameOver) {
      return Text(
        'Game complete — submit to save.',
        style: AppTextStyles.body.copyWith(color: colors.accent),
      );
    }
    return Text(
      'Frame ${state.currentFrameNumber}  ·  Ball ${state.currentDeliveryNumber}',
      style: AppTextStyles.bodyMedium.copyWith(
        color: colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Quick action row — Strike / Spare / Miss / Clear.
// ═══════════════════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.disabled});
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickButton(
            label: 'Strike',
            icon: LucideIcons.zap,
            disabled: disabled,
            onTap: () => context
                .read<PlayBloc>()
                .add(const PlayQuickAction(PlayQuickActionType.strike)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickButton(
            label: 'Spare',
            icon: LucideIcons.check,
            disabled: disabled,
            onTap: () => context
                .read<PlayBloc>()
                .add(const PlayQuickAction(PlayQuickActionType.spare)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickButton(
            label: 'Miss',
            icon: LucideIcons.x,
            disabled: disabled,
            onTap: () => context
                .read<PlayBloc>()
                .add(const PlayQuickAction(PlayQuickActionType.miss)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickButton(
            label: 'Clear',
            icon: LucideIcons.eraser,
            disabled: disabled,
            onTap: () => context
                .read<PlayBloc>()
                .add(const PlayQuickAction(PlayQuickActionType.clear)),
          ),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.label,
    required this.icon,
    required this.disabled,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: colors.borderDefault),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: disabled ? colors.textTertiary : colors.textPrimary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.nano.copyWith(
                  color: disabled ? colors.textTertiary : colors.textSecondary,
                  fontWeight: FontWeight.w600,
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
// Submit bar at the bottom.
// ═══════════════════════════════════════════════════════════════════════════
class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: state.submitting ? 'Submitting…' : 'Submit game',
          loading: state.submitting,
          expand: true,
          size: AppButtonSize.large,
          onPressed: (state.submitting || !state.score.isComplete)
              ? null
              : () =>
                  context.read<PlayBloc>().add(const PlayGameSubmitted()),
        ),
      ),
    );
  }
}
