import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/live_socket.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../live/domain/repositories/live_repository.dart';
import '../../data/services/play_local_state_service.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/games_repository.dart';
import '../bloc/play_bloc.dart';
import '../widgets/loadout_pill.dart';
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
        liveRepository: getIt<LiveRepository>(),
        localState: getIt<PlayLocalStateService>(),
        liveSocket: getIt<LiveSocket>(),
        sessionUid: sessionUid,
      )
        ..add(const PlayLiveRehydrateRequested())
        ..add(const PlayLocalStateRehydrateRequested()),
      child: const _PlayView(),
    );
  }
}

class _PlayView extends StatefulWidget {
  const _PlayView();

  @override
  State<_PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<_PlayView> {
  List<UserBall> _loadout = const [];

  @override
  void initState() {
    super.initState();
    _loadLoadout();
  }

  /// Fetch the user's balls so the loadout pill + picker have data.
  /// Fire-and-forget — if it fails the pill just shows "No ball".
  Future<void> _loadLoadout() async {
    final res = await getIt<GamesRepository>().getEquipment();
    if (!mounted) return;
    res.fold(
      (_) {},
      (list) => setState(() => _loadout = list),
    );
  }

  Future<void> _openLoadoutPicker(BuildContext ctx, int? currentId) async {
    final bloc = ctx.read<PlayBloc>();
    final result = await showLoadoutPicker(
      ctx,
      balls: _loadout,
      currentId: currentId,
    );
    if (result == null || !result.changed) return;
    bloc.add(PlaySelectedBallChanged(result.userBallId));
  }

  /// Routes between the three play surfaces:
  ///   • [submittedGame] set → celebration card
  ///   • [entryMode] = quick → quick-score input
  ///   • else → full frame-by-frame deck
  Widget _buildBody(BuildContext context, PlayState state) {
    if (state.submittedGame != null) {
      return _GameCompleteCard(
        state: state,
        onAnotherGame: () =>
            context.read<PlayBloc>().add(const PlayAnotherGameRequested()),
        onFinishSession: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.games);
          }
        },
      );
    }

    return Column(
      children: [
        // Mode switcher pinned at the top — Full Detail | Quick Score.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
            0,
          ),
          child: _EntryModeSelector(mode: state.entryMode),
        ),
        // Live-broadcast strip — Go Live button OR active pill. Only in
        // Full Detail (quick-score can't be live-streamed).
        if (state.entryMode == PlayEntryMode.full)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.sm,
              AppSpacing.base,
              0,
            ),
            child: _LiveStrip(state: state),
          ),
        Expanded(
          child: state.entryMode == PlayEntryMode.quick
              ? _QuickScoreView(state: state)
              : _FullDetailView(
                  state: state,
                  loadout: _loadout,
                  onPickBall: () =>
                      _openLoadoutPicker(context, state.selectedBallId),
                ),
        ),
        if (state.entryMode == PlayEntryMode.full)
          _SubmitBar(state: state)
        else
          _QuickSubmitBar(state: state),
      ],
    );
  }

  Future<void> _pickHandedness(BuildContext ctx, String current) async {
    final bloc = ctx.read<PlayBloc>();
    final picked = await showModalBottomSheet<String>(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final colors = sheetCtx.colors;
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: colors.bgSurfaceElevated,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final h in const ['Righty', 'Lefty'])
                  ListTile(
                    leading: Icon(
                      h == current
                          ? LucideIcons.circleCheck
                          : LucideIcons.circle,
                      size: 18,
                      color: h == current
                          ? colors.accent
                          : colors.textTertiary,
                    ),
                    title: Text(
                      h,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textPrimary,
                        fontWeight:
                            h == current ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    onTap: () => Navigator.of(sheetCtx).pop(h),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) bloc.add(PlayHandednessChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<PlayBloc, PlayState>(
      listenWhen: (p, n) =>
          p.submittedGame != n.submittedGame || p.errors != n.errors,
      listener: (context, state) {
        if (state.submittedGame != null) {
          // Don't auto-pop — the celebration card takes over the body
          // and lets the user pick "Another Game" or "Finish Session".
          HapticFeedback.mediumImpact();
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
              TextButton.icon(
                onPressed: () => _pickHandedness(context, state.handedness),
                icon: Icon(
                  state.handedness == 'Righty'
                      ? LucideIcons.handMetal
                      : LucideIcons.handMetal,
                  size: 14,
                  color: colors.accent,
                ),
                label: Text(
                  state.handedness,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
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
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Header strip — running total + projected + frame.
// ═══════════════════════════════════════════════════════════════════════════
class _HeaderStrip extends StatelessWidget {
  const _HeaderStrip({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showProjected =
        state.score.projectedScore > state.score.totalScore;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgSurfaceElevated,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatBlock(
                  label: 'SCORE',
                  value: '${state.score.totalScore}',
                  color: colors.accent,
                ),
              ),
              Container(width: 1, height: 36, color: colors.borderDefault),
              Expanded(
                child: _StatBlock(
                  label: 'PROJECTED',
                  value: '${state.score.projectedScore}',
                  color: colors.textSecondary,
                ),
              ),
              Container(width: 1, height: 36, color: colors.borderDefault),
              Expanded(
                child: _StatBlock(
                  label: state.isGameOver ? 'DONE' : 'FRAME',
                  value:
                      state.isGameOver ? '✓' : '${state.currentFrameNumber}',
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          if (showProjected && !state.isGameOver) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colors.accent.withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                ),
                color: colors.accent.withValues(alpha: 0.05),
              ),
              child: Text(
                'Max possible: ${state.score.projectedScore}',
                style: AppTextStyles.nano.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
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
// Pin-deck card — header (frame/ball + all-standing toggle), deck, hint.
// ═══════════════════════════════════════════════════════════════════════════
class _PinDeckCard extends StatelessWidget {
  const _PinDeckCard({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (state.isGameOver)
                Text(
                  'Game complete — submit to save.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Text(
                  'Frame ${state.currentFrameNumber}  ·  Ball ${state.currentDeliveryNumber}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              _PinDefaultToggle(value: state.pinDefault),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PinDeck(
            standing: state.activeStanding,
            availablePins: state.availablePins,
            onSetStanding: state.isGameOver
                ? (_) {}
                : (next) => context
                    .read<PlayBloc>()
                    .add(PlayStandingChanged(next)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            state.pinDefault == PinDefaultState.standing
                ? 'Tap pins you knocked down — or press and drag across several at once.'
                : 'Tap pins still standing — or press and drag across several.',
            textAlign: TextAlign.center,
            style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Two-state pill: "Pins UP" ↔ "Pins DOWN". Mirrors the web's
/// `pinDefaultState` toggle.
class _PinDefaultToggle extends StatelessWidget {
  const _PinDefaultToggle({required this.value});
  final PinDefaultState value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const labels = {
      PinDefaultState.standing: 'Pins UP',
      PinDefaultState.knocked: 'Pins DOWN',
    };
    return Material(
      color: colors.bgSurface,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.read<PlayBloc>().add(const PlayPinDefaultToggled()),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colors.borderDefault),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value == PinDefaultState.standing
                    ? LucideIcons.arrowUp
                    : LucideIcons.arrowDown,
                size: 12,
                color: colors.accent,
              ),
              const SizedBox(width: 4),
              Text(
                labels[value]!,
                style: AppTextStyles.nano.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
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
// Quick-action row — Strike / Spare / Miss / Clear / Next.
// ═══════════════════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    final disabled = state.isGameOver;
    // Show "Strike" on the first ball when all 10 are available; otherwise
    // promote that button to "Spare" (clear remaining), matching web.
    final firstBall = state.cursor.deliveryIndex == 0;
    final primaryLabel = firstBall ? 'Strike' : 'Spare';
    final primaryIcon =
        firstBall ? LucideIcons.zap : LucideIcons.check;

    return Row(
      children: [
        Expanded(
          child: _QuickButton(
            label: primaryLabel,
            icon: primaryIcon,
            disabled: disabled,
            onTap: () => context.read<PlayBloc>().add(
                  PlayQuickAction(firstBall
                      ? PlayQuickActionType.strike
                      : PlayQuickActionType.spare),
                ),
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
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickButton(
            label: 'Next',
            icon: LucideIcons.chevronRight,
            disabled: disabled,
            emphasis: true,
            onTap: () => context
                .read<PlayBloc>()
                .add(const PlayQuickAction(PlayQuickActionType.next)),
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
    this.emphasis = false,
  });
  final String label;
  final IconData icon;
  final bool disabled;
  final VoidCallback onTap;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = disabled
        ? colors.textTertiary
        : (emphasis ? Colors.white : colors.textPrimary);
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: disabled ? null : onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: emphasis && !disabled ? null : colors.bgSurface,
            gradient: emphasis && !disabled ? colors.accentGradient : null,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: emphasis && !disabled
                  ? Colors.transparent
                  : colors.borderDefault,
            ),
            boxShadow: emphasis && !disabled
                ? [
                    BoxShadow(
                      color: colors.accentGlow,
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.nano.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
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

// ═══════════════════════════════════════════════════════════════════════════
// Full-detail view — scorecard + pin deck + quick actions + loadout pill.
// Extracted from the original inline body so the screen can swap between
// full / quick / celebration modes cleanly.
// ═══════════════════════════════════════════════════════════════════════════
class _FullDetailView extends StatelessWidget {
  const _FullDetailView({
    required this.state,
    required this.loadout,
    required this.onPickBall,
  });

  final PlayState state;
  final List<UserBall> loadout;
  final VoidCallback onPickBall;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        children: [
          _HeaderStrip(state: state),
          const SizedBox(height: AppSpacing.md),
          Scorecard(
            frames: state.score.frames,
            activeIndex: state.cursor.frameIndex.clamp(0, 9),
            onFrameTap: (i) =>
                context.read<PlayBloc>().add(PlayFrameJumped(i)),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PinDeckCard(state: state),
          const SizedBox(height: AppSpacing.md),
          _QuickActions(state: state),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              LoadoutPill(
                balls: loadout,
                selectedId: state.selectedBallId,
                onTap: onPickBall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Entry-mode pill — Full Detail | Quick Score. Mirrors web's tab toggle.
// ═══════════════════════════════════════════════════════════════════════════
class _EntryModeSelector extends StatelessWidget {
  const _EntryModeSelector({required this.mode});
  final PlayEntryMode mode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          _ModeChip(
            label: 'Full Detail',
            icon: LucideIcons.target,
            active: mode == PlayEntryMode.full,
            onTap: () => context
                .read<PlayBloc>()
                .add(const PlayEntryModeChanged(PlayEntryMode.full)),
          ),
          _ModeChip(
            label: 'Quick Score',
            icon: LucideIcons.zap,
            active: mode == PlayEntryMode.quick,
            onTap: () => context
                .read<PlayBloc>()
                .add(const PlayEntryModeChanged(PlayEntryMode.quick)),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: active
                  ? colors.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: active ? colors.accent : colors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: active ? colors.accent : colors.textSecondary,
                    fontWeight: FontWeight.w700,
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

// ═══════════════════════════════════════════════════════════════════════════
// Quick-score view — number field 0–300 + handedness reminder.
// ═══════════════════════════════════════════════════════════════════════════
class _QuickScoreView extends StatefulWidget {
  const _QuickScoreView({required this.state});
  final PlayState state;

  @override
  State<_QuickScoreView> createState() => _QuickScoreViewState();
}

class _QuickScoreViewState extends State<_QuickScoreView> {
  late final TextEditingController _ctl =
      TextEditingController(text: widget.state.quickScoreDraft);

  @override
  void didUpdateWidget(covariant _QuickScoreView old) {
    super.didUpdateWidget(old);
    // Sync from bloc state when it diverges (e.g. cleared after submit).
    if (widget.state.quickScoreDraft != _ctl.text) {
      _ctl
        ..text = widget.state.quickScoreDraft
        ..selection = TextSelection.collapsed(
          offset: widget.state.quickScoreDraft.length,
        );
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.zap,
                    color: colors.accent, size: 28),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Quick Score',
                  style: AppTextStyles.sectionTitle
                      .copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Type the final total — 0 to 300.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  decoration: BoxDecoration(
                    color: colors.bgSurface,
                    borderRadius: AppRadius.xlAll,
                    border: Border.all(color: colors.borderStrong),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: TextField(
                    controller: _ctl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    textAlign: TextAlign.center,
                    textInputAction: TextInputAction.done,
                    onChanged: (v) => context
                        .read<PlayBloc>()
                        .add(PlayQuickScoreDraftChanged(v)),
                    onSubmitted: (_) => _submit(context),
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: colors.textTertiary.withValues(alpha: 0.4),
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Handedness: ${widget.state.handedness}',
                  style: AppTextStyles.nano
                      .copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    final v = int.tryParse(_ctl.text.trim());
    if (v == null) return;
    context.read<PlayBloc>().add(PlayQuickScoreSubmitted(v));
  }
}

/// Submit bar for quick-score mode — enabled when the draft parses to a
/// valid 0–300 number.
class _QuickSubmitBar extends StatelessWidget {
  const _QuickSubmitBar({required this.state});
  final PlayState state;

  bool get _canSubmit {
    final v = int.tryParse(state.quickScoreDraft.trim());
    return v != null && v >= 0 && v <= 300;
  }

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
          label: state.submitting ? 'Saving…' : 'Save score',
          loading: state.submitting,
          expand: true,
          size: AppButtonSize.large,
          onPressed: (state.submitting || !_canSubmit)
              ? null
              : () {
                  final v = int.parse(state.quickScoreDraft.trim());
                  context
                      .read<PlayBloc>()
                      .add(PlayQuickScoreSubmitted(v));
                },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Game-complete celebration card — trophy / sparkles, big final score,
// strikes/spares/opens grid, "Another Game" + "Finish Session" actions.
// ═══════════════════════════════════════════════════════════════════════════
class _GameCompleteCard extends StatelessWidget {
  const _GameCompleteCard({
    required this.state,
    required this.onAnotherGame,
    required this.onFinishSession,
  });

  final PlayState state;
  final VoidCallback onAnotherGame;
  final VoidCallback onFinishSession;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final game = state.submittedGame!;
    final total = game.totalScore;
    final isPerfect = total == 300;

    // Frame stats — use the server's authoritative counts when present
    // (full-detail submit), else fall back to the local scorer.
    final strikes = game.strikeCount > 0
        ? game.strikeCount
        : state.score.frames.where((f) => f.isStrike).length;
    final spares = game.spareCount > 0
        ? game.spareCount
        : state.score.frames.where((f) => f.isSpare).length;
    final opens = game.openCount > 0
        ? game.openCount
        : state.score.frames.where((f) => f.isOpen).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPerfect ? LucideIcons.sparkles : LucideIcons.trophy,
                    size: 48,
                    color: isPerfect
                        ? const Color(0xFFEAB308)
                        : colors.accent,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    isPerfect
                        ? 'PERFECT GAME! 🎳'
                        : 'Game ${game.gameNumber} complete!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '$total',
                    style: AppTextStyles.displayHero.copyWith(
                      color: colors.accent,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _CompleteStat(
                          value: '$strikes',
                          label: 'Strikes',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompleteStat(
                          value: '$spares',
                          label: 'Spares',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompleteStat(
                          value: '$opens',
                          label: 'Opens',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Another Game',
                    icon: LucideIcons.plus,
                    onPressed: onAnotherGame,
                    expand: true,
                    size: AppButtonSize.large,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Finish Session',
                    icon: LucideIcons.flag,
                    variant: AppButtonVariant.secondary,
                    onPressed: onFinishSession,
                    expand: true,
                    size: AppButtonSize.large,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompleteStat extends StatelessWidget {
  const _CompleteStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover.withValues(alpha: 0.4),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.numberLarge.copyWith(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Live broadcast strip — shows "Go Live" when off-air, an animated pill
// (pulsing rose dot + viewer count + End) when on-air. Per-frame sync to
// viewers is driven by [PlayBloc] inside `_commitDelivery`.
// ═══════════════════════════════════════════════════════════════════════════
const Color _kLiveRose = Color(0xFFE11D48);

class _LiveStrip extends StatelessWidget {
  const _LiveStrip({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    return state.isLive ? _ActiveLivePill(state: state) : _GoLiveButton(state: state);
  }
}

class _GoLiveButton extends StatelessWidget {
  const _GoLiveButton({required this.state});
  final PlayState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = state.liveBusy;
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.xlAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: disabled
            ? null
            : () => context
                .read<PlayBloc>()
                .add(const PlayGoLiveRequested()),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _kLiveRose.withValues(alpha: 0.06),
            borderRadius: AppRadius.xlAll,
            border: Border.all(
              color: _kLiveRose.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.radio, size: 16, color: _kLiveRose),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Go Live',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _kLiveRose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Stream every frame to your followers as you bowl.',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (disabled)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kLiveRose,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveLivePill extends StatelessWidget {
  const _ActiveLivePill({required this.state});
  final PlayState state;

  Future<void> _confirmEnd(BuildContext context) async {
    final colors = context.colors;
    final bloc = context.read<PlayBloc>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: colors.bgSurfaceElevated,
        title: Text(
          'End broadcast?',
          style: AppTextStyles.sectionTitle.copyWith(
            color: colors.textPrimary,
            fontSize: 16,
          ),
        ),
        content: Text(
          'Viewers will stop receiving frame updates. You can keep playing — '
          'just without the live audience.',
          style: AppTextStyles.body
              .copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.buttonLabel
                  .copyWith(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: Text(
              'End',
              style: AppTextStyles.buttonLabel.copyWith(color: _kLiveRose),
            ),
          ),
        ],
      ),
    );
    if (ok == true) bloc.add(const PlayEndLiveRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final live = state.live!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        border: Border.all(
          color: _kLiveRose.withValues(alpha: 0.4),
        ),
        gradient: LinearGradient(
          colors: [
            _kLiveRose.withValues(alpha: 0.12),
            _kLiveRose.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Row(
        children: [
          const _PulsingDot(color: _kLiveRose),
          const SizedBox(width: 8),
          Text(
            'LIVE',
            style: AppTextStyles.nano.copyWith(
              color: _kLiveRose,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(LucideIcons.users,
              size: 12, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            '${live.viewerCount}',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          if (state.liveBusy)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _kLiveRose,
              ),
            )
          else
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _confirmEnd(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kLiveRose,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'End',
                    style: AppTextStyles.nano.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctl,
            builder: (_, _) {
              final t = _ctl.value;
              return Opacity(
                opacity: (1 - t) * 0.7,
                child: Container(
                  width: 8 + (t * 8),
                  height: 8 + (t * 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
