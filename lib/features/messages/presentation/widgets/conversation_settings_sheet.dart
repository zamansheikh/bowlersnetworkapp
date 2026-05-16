import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

/// Outcome the thread screen needs back after the sheet closes — lets the
/// caller decide whether to pop the thread (deleted/left) or update the
/// header (muted/renamed).
class ConversationSettingsResult {
  ConversationSettingsResult({
    this.muteToggled = false,
    this.newMuted = false,
    this.exited = false,
  });

  final bool muteToggled;
  final bool newMuted;
  final bool exited;
}

Future<ConversationSettingsResult?> showConversationSettings(
  BuildContext context, {
  required ConversationListItem conversation,
}) {
  return showModalBottomSheet<ConversationSettingsResult>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ConversationSettingsSheet(conversation: conversation),
  );
}

class _ConversationSettingsSheet extends StatefulWidget {
  const _ConversationSettingsSheet({required this.conversation});
  final ConversationListItem conversation;

  @override
  State<_ConversationSettingsSheet> createState() =>
      _ConversationSettingsSheetState();
}

class _ConversationSettingsSheetState
    extends State<_ConversationSettingsSheet> {
  final _repo = getIt<MessagesRepository>();
  bool _muted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _muted = widget.conversation.isMuted;
  }

  Future<void> _toggleMute() async {
    setState(() => _busy = true);
    final res = await _repo.toggleMute(widget.conversation.uid);
    if (!mounted) return;
    res.fold(
      (f) {
        setState(() => _busy = false);
        showAppToast(context,
            message: f.messages.isNotEmpty ? f.messages.first : 'Failed',
            variant: ToastVariant.error);
      },
      (muted) {
        setState(() {
          _busy = false;
          _muted = muted;
        });
        Navigator.of(context).pop(ConversationSettingsResult(
          muteToggled: true,
          newMuted: muted,
        ));
      },
    );
  }

  Future<void> _leave() async {
    final ok = await _confirm(
      context,
      title: 'Leave group?',
      body: 'You won\'t receive new messages from ${widget.conversation.name}.',
      destructive: true,
      confirmLabel: 'Leave',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final res = await _repo.leaveGroup(widget.conversation.uid);
    if (!mounted) return;
    res.fold(
      (f) {
        setState(() => _busy = false);
        showAppToast(context,
            message: f.messages.isNotEmpty ? f.messages.first : 'Failed',
            variant: ToastVariant.error);
      },
      (_) => Navigator.of(context)
          .pop(ConversationSettingsResult(exited: true)),
    );
  }

  Future<void> _delete() async {
    final ok = await _confirm(
      context,
      title: 'Delete group?',
      body:
          'This will remove the group for everyone. This action can\'t be undone.',
      destructive: true,
      confirmLabel: 'Delete',
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final res = await _repo.deleteConversation(widget.conversation.uid);
    if (!mounted) return;
    res.fold(
      (f) {
        setState(() => _busy = false);
        showAppToast(context,
            message: f.messages.isNotEmpty ? f.messages.first : 'Failed',
            variant: ToastVariant.error);
      },
      (_) => Navigator.of(context)
          .pop(ConversationSettingsResult(exited: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = widget.conversation;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgSurfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderStrong,
                borderRadius: AppRadius.fullAll,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Text(
                c.name,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              leading: Icon(
                _muted ? LucideIcons.bell : LucideIcons.bellOff,
                size: 18,
                color: colors.textSecondary,
              ),
              title: Text(
                _muted ? 'Unmute notifications' : 'Mute notifications',
                style:
                    AppTextStyles.body.copyWith(color: colors.textPrimary),
              ),
              enabled: !_busy,
              onTap: _busy ? null : _toggleMute,
            ),
            if (c.isGroup) ...[
              ListTile(
                leading: Icon(LucideIcons.logOut,
                    size: 18, color: colors.textSecondary),
                title: Text(
                  'Leave group',
                  style: AppTextStyles.body.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                enabled: !_busy,
                onTap: _busy ? null : _leave,
              ),
              ListTile(
                leading:
                    Icon(LucideIcons.trash2, size: 18, color: colors.error),
                title: Text(
                  'Delete group',
                  style: AppTextStyles.body.copyWith(color: colors.error),
                ),
                subtitle: Text(
                  'Group creator only',
                  style: AppTextStyles.micro.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                enabled: !_busy,
                onTap: _busy ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dCtx) {
      final colors = dCtx.colors;
      return AlertDialog(
        backgroundColor: colors.bgSurfaceElevated,
        title: Text(title,
            style: AppTextStyles.sectionTitle
                .copyWith(color: colors.textPrimary, fontSize: 16)),
        content: Text(body,
            style:
                AppTextStyles.body.copyWith(color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: Text('Cancel',
                style: AppTextStyles.buttonLabel
                    .copyWith(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: Text(
              confirmLabel,
              style: AppTextStyles.buttonLabel.copyWith(
                color: destructive ? colors.error : colors.accent,
              ),
            ),
          ),
        ],
      );
    },
  );
}
