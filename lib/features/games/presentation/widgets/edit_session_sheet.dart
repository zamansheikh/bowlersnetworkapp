import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/games_repository.dart';

/// Edit-session metadata sheet — name, lane numbers, game context, oil
/// pattern, notes. Mirrors web's `<EditSessionDialog>`. Calls
/// `PATCH /api/games/sessions/{uid}/update` and returns the updated
/// [Session] on success (or `null` if the user dismissed without saving).
Future<Session?> showEditSessionSheet(
  BuildContext context, {
  required Session session,
}) {
  return showAppBottomSheet<Session>(
    context: context,
    title: 'Edit session',
    child: _EditSessionForm(session: session),
  );
}

class _EditSessionForm extends StatefulWidget {
  const _EditSessionForm({required this.session});
  final Session session;

  @override
  State<_EditSessionForm> createState() => _EditSessionFormState();
}

class _EditSessionFormState extends State<_EditSessionForm> {
  late final _name = TextEditingController(text: widget.session.name);
  late final _lanes = TextEditingController(text: widget.session.laneNumbers);
  late final _oilName =
      TextEditingController(text: widget.session.oilPatternName);
  late final _oilLength = TextEditingController(
    text: widget.session.oilPatternLength?.toString() ?? '',
  );
  late final _notes = TextEditingController(text: widget.session.notes);
  late GameContext _context = widget.session.context;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _lanes.dispose();
    _oilName.dispose();
    _oilLength.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    if (name.isEmpty) {
      showAppToast(
        context,
        message: 'Session name is required.',
        variant: ToastVariant.error,
      );
      return;
    }
    final lenRaw = _oilLength.text.trim();
    int? len;
    if (lenRaw.isNotEmpty) {
      len = int.tryParse(lenRaw);
      if (len == null || len < 0) {
        showAppToast(
          context,
          message: 'Oil pattern length must be a positive number.',
          variant: ToastVariant.error,
        );
        return;
      }
    }

    setState(() => _saving = true);
    final repo = getIt<GamesRepository>();
    final res = await repo.updateSession(
      uid: widget.session.uid,
      name: name,
      laneNumbers: _lanes.text.trim(),
      gameContext: _context.apiValue,
      oilPatternName: _oilName.text.trim(),
      oilPatternLength: len,
      notes: _notes.text.trim(),
    );
    if (!mounted) return;
    res.fold(
      (f) {
        setState(() => _saving = false);
        showAppToast(
          context,
          message: f.messages.join('\n'),
          variant: ToastVariant.error,
        );
      },
      (updated) {
        Navigator.of(context).pop(updated);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              controller: _name,
              label: 'Name',
              hint: 'Session name',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              controller: _lanes,
              label: 'Lane numbers',
              hint: 'e.g. 5,6',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'CONTEXT',
              style: AppTextStyles.label.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in GameContext.values)
                  _ContextChip(
                    label: c.label,
                    selected: _context == c,
                    onTap: () => setState(() => _context = c),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppInput(
                    controller: _oilName,
                    label: 'Oil pattern',
                    hint: 'Pattern name',
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppInput(
                    controller: _oilLength,
                    label: 'Length (ft)',
                    hint: '40',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              controller: _notes,
              label: 'Notes',
              hint: 'Anything worth remembering about this session',
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    expand: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Save',
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                    expand: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextChip extends StatelessWidget {
  const _ContextChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected
          ? colors.accent.withValues(alpha: 0.12)
          : colors.bgSurface,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: selected ? colors.accent : colors.borderDefault,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: selected ? colors.accent : colors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
