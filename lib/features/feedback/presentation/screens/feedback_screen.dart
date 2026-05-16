import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/feedback_draft.dart';
import '../bloc/feedback_bloc.dart';

/// /feedback — single-screen submit form (no public feed / replies / rating
/// in v1; those endpoints exist and can be wired in a follow-up).
///
/// Sections:
///   * Category pills (Bug / Suggestion / Feature / Complaint / Question)
///   * Feature area dropdown (Newsfeed, Chatter, Games, …, Other)
///   * Title + body text fields
///   * Submit button (with loading spinner)
class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeedbackBloc>(
      create: (_) => getIt<FeedbackBloc>(),
      child: const _FeedbackView(),
    );
  }
}

class _FeedbackView extends StatefulWidget {
  const _FeedbackView();

  @override
  State<_FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<_FeedbackView> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<FeedbackBloc>().add(FeedbackSubmitRequested(
          title: _title.text,
          body: _body.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Send feedback'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<FeedbackBloc, FeedbackState>(
        listenWhen: (p, n) =>
            (p.errors != n.errors && n.errors.isNotEmpty) ||
            (p.submitted != n.submitted && n.submitted != null),
        listener: (context, state) {
          if (state.errors.isNotEmpty) {
            showAppToast(
              context,
              message: state.errors.join('\n'),
              variant: ToastVariant.error,
            );
          } else if (state.submitted != null) {
            showAppToast(
              context,
              message: 'Thanks — we got your feedback.',
              variant: ToastVariant.success,
            );
            _title.clear();
            _body.clear();
            // Reset bloc state so a future submit doesn't re-fire the
            // success toast on the next listener pass.
            context
                .read<FeedbackBloc>()
                .add(const FeedbackResetRequested());
            // Drop the user back wherever they came from.
            if (context.canPop()) context.pop();
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.xl2,
            ),
            children: [
              _SectionCard(
                icon: LucideIcons.tag,
                title: 'Category',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in FeedbackCategory.values)
                      _Pill(
                        label: c.label,
                        active: state.category == c,
                        onTap: () => context
                            .read<FeedbackBloc>()
                            .add(FeedbackCategoryChanged(c)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                icon: LucideIcons.layoutGrid,
                title: 'Area',
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FeedbackArea>(
                    isExpanded: true,
                    value: state.area,
                    iconEnabledColor: colors.textTertiary,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textPrimary,
                      fontSize: 14,
                    ),
                    dropdownColor: colors.bgSurfaceElevated,
                    items: [
                      for (final a in FeedbackArea.values)
                        DropdownMenuItem(
                          value: a,
                          child: Text(a.label),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      context
                          .read<FeedbackBloc>()
                          .add(FeedbackAreaChanged(v));
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                icon: LucideIcons.pencil,
                title: 'Title',
                child: AppInput(
                  controller: _title,
                  hint: 'Short summary',
                  maxLength: 200,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                icon: LucideIcons.fileText,
                title: 'Details',
                child: AppInput(
                  controller: _body,
                  hint: 'What happened? Steps to reproduce, expected vs '
                      'actual, screenshots links — whatever helps.',
                  maxLines: 8,
                  minLines: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Submit',
                icon: LucideIcons.send,
                size: AppButtonSize.large,
                expand: true,
                loading: state.submitting,
                onPressed: state.submitting ? null : _submit,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colors.accent),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.label
                    .copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.12) : colors.bgSurface,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? colors.accent : colors.textPrimary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
