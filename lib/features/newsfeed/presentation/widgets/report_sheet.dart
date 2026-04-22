import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/repositories/newsfeed_repository.dart';

/// Reason codes the backend's `reporting/models.py` accepts. Labels come
/// from the web's Report modal.
enum ReportReason {
  spam('spam', 'Spam', 'Unwanted commercial content or repetitive posts.'),
  harassment('harassment', 'Harassment', 'Targeting or threatening another person.'),
  inappropriate('inappropriate', 'Inappropriate', 'Violent, sexual, or shocking content.'),
  misinformation('misinformation', 'Misinformation', 'False or misleading information.'),
  fakeCredentials(
    'fake_credentials',
    'Fake credentials',
    'Claiming achievements, rank, or affiliation they don\'t have.',
  ),
  impersonation(
    'impersonation',
    'Impersonation',
    'Pretending to be someone else.',
  );

  const ReportReason(this.apiValue, this.label, this.hint);
  final String apiValue;
  final String label;
  final String hint;
}

/// Universal report sheet. Works for any reportable entity — the backend
/// accepts `content_type` of `post`, `comment`, `discussion`, `opinion`,
/// `user`.
Future<void> showReportSheet(
  BuildContext context, {
  required String contentType,
  required int contentId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => _ReportSheet(
      contentType: contentType,
      contentId: contentId,
    ),
  );
}

// =============================================================================
class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.contentType, required this.contentId});

  final String contentType;
  final int contentId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  ReportReason? _reason;
  final _detailCtl = TextEditingController();
  bool _busy = false;
  List<String> _errors = const [];

  @override
  void dispose() {
    _detailCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) {
      setState(() => _errors = const ['Pick a reason first.']);
      return;
    }
    setState(() {
      _busy = true;
      _errors = const [];
    });
    final res = await getIt<NewsfeedRepository>().submitReport(
      contentType: widget.contentType,
      contentId: widget.contentId,
      reason: _reason!.apiValue,
      detail: _detailCtl.text.trim().isEmpty ? null : _detailCtl.text.trim(),
    );
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _busy = false;
        _errors = f.messages;
      }),
      (_) {
        Navigator.of(context).pop();
        showAppToast(
          context,
          message: 'Thanks — our team will review this.',
          variant: ToastVariant.success,
        );
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
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
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
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderStrong,
                borderRadius: AppRadius.fullAll,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.x,
                        size: 20, color: colors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Report ${widget.contentType}',
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
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.base,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Why are you reporting this?',
                      style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    for (final r in ReportReason.values) ...[
                      _ReasonRow(
                        reason: r,
                        selected: _reason == r,
                        onTap: () => setState(() => _reason = r),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'ADDITIONAL CONTEXT (OPTIONAL)',
                      style: AppTextStyles.label.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.bgSurface,
                        borderRadius: AppRadius.mdAll,
                        border: Border.all(color: colors.borderStrong),
                      ),
                      child: TextField(
                        controller: _detailCtl,
                        maxLines: 3,
                        minLines: 3,
                        maxLength: 500,
                        style: AppTextStyles.body.copyWith(
                          color: colors.textPrimary,
                          fontSize: 13,
                        ),
                        cursorColor: colors.accent,
                        decoration: InputDecoration(
                          hintText: 'Give our moderators more context…',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: colors.textTertiary,
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          border: InputBorder.none,
                          counterStyle: AppTextStyles.nano.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    if (_errors.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.08),
                          borderRadius: AppRadius.mdAll,
                          border: Border.all(
                            color: colors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final m in _errors)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(LucideIcons.circleAlert,
                                      size: 13, color: colors.error),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      m,
                                      style: AppTextStyles.bodySmall
                                          .copyWith(color: colors.error),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.base,
                ),
                child: AppButton(
                  label: _busy ? 'Submitting' : 'Submit report',
                  loading: _busy,
                  expand: true,
                  size: AppButtonSize.large,
                  variant: AppButtonVariant.destructive,
                  onPressed: (_busy || _reason == null) ? null : _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    required this.reason,
    required this.selected,
    required this.onTap,
  });

  final ReportReason reason;
  final bool selected;
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
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? colors.accent.withValues(alpha: 0.08)
                : colors.bgSurface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: selected ? colors.accent : colors.borderDefault,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.accent : colors.borderStrong,
                    width: selected ? 5 : 1.5,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reason.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reason.hint,
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
      ),
    );
  }
}
