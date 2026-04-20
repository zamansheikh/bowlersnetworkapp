import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../bloc/conversations_bloc.dart';
import '../widgets/conversation_tile.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConversationsBloc>(
      create: (_) =>
          getIt<ConversationsBloc>()..add(const ConversationsLoadRequested()),
      child: const _MessagesView(),
    );
  }
}

class _MessagesView extends StatelessWidget {
  const _MessagesView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.navMessages),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.accent,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(LucideIcons.squarePen, size: 20),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<ConversationsBloc, ConversationsState>(
          builder: (context, state) {
            if (state.loading && state.items.isEmpty) {
              return const _ConversationsSkeleton();
            }
            if (state.items.isEmpty) {
              return EmptyState(
                icon: LucideIcons.messageCircle,
                title: 'No conversations yet',
                hint: state.errors.isNotEmpty
                    ? state.errors.join('\n')
                    : 'Start a chat with a friend or a teammate.',
                action: state.errors.isNotEmpty
                    ? AppButton(
                        label: l10n.actionRetry,
                        onPressed: () => context
                            .read<ConversationsBloc>()
                            .add(const ConversationsRefreshRequested()),
                      )
                    : null,
              );
            }

            return RefreshIndicator(
              color: colors.accent,
              onRefresh: () async {
                context
                    .read<ConversationsBloc>()
                    .add(const ConversationsRefreshRequested());
                await context
                    .read<ConversationsBloc>()
                    .stream
                    .firstWhere((s) => !s.refreshing);
              },
              child: ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 72,
                  color: colors.borderDefault.withValues(alpha: 0.5),
                ),
                itemBuilder: (_, i) {
                  final c = state.items[i];
                  return ConversationTile(
                    conversation: c,
                    onTap: () {
                      context
                          .read<ConversationsBloc>()
                          .add(ConversationMarkedRead(conversationUid: c.uid));
                      context.push(
                        '${RouteNames.messages}/${c.uid}',
                        extra: c,
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ConversationsSkeleton extends StatelessWidget {
  const _ConversationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const SkeletonCircle(size: 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(height: 14, width: 140),
                  SizedBox(height: 8),
                  SkeletonBox(height: 11, width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
