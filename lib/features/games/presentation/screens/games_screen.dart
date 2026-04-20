import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';

/// Stub — full game-tracking feature arrives in Phase 3. Rendered so the
/// bottom-nav Games tab has a valid landing screen.
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(title: Text(l10n.navGames)),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: EmptyState(
            icon: LucideIcons.target,
            title: 'Game tracking coming soon',
            hint: 'Log frames, analyse pin-leaves, and review your sessions.',
          ),
        ),
      ),
    );
  }
}
