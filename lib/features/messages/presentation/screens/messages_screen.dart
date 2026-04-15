import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';

/// Stub — full real-time messaging lands in Phase 2.3. Rendered so the
/// bottom-nav Messages tab has a valid landing screen.
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(title: Text(l10n.navMessages)),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No conversations yet',
            hint: 'Direct and group chats will appear here.',
          ),
        ),
      ),
    );
  }
}
