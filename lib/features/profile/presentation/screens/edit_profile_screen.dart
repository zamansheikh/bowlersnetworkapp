import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/geocoder_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../search/domain/entities/search_result.dart';
import '../../../search/domain/repositories/search_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/edit_profile_bloc.dart';
import '../bloc/profile_bloc.dart';

/// /profile/edit — single editable form mirroring the web's per-field
/// inline editors, collapsed into sectional cards on mobile. Each card
/// owns its own Save button; the bloc runs each save independently so
/// users can edit several sections without serializing API calls.
///
/// On screen open we pull the current profile from the parent
/// [ProfileBloc] so users see their existing values pre-filled. On
/// successful save we also push a refresh into [ProfileBloc] so the
/// underlying profile screen reflects the change when popped back to.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(
            title: const Text('Edit profile'),
            leading: const AppBackButton(),
          ),
            body: const Center(
              child: EmptyState(
                icon: LucideIcons.userX,
                title: 'Profile not loaded',
                hint: 'Open the Profile tab and come back.',
              ),
            ),
          );
        }
        return BlocProvider<EditProfileBloc>(
          create: (_) => EditProfileBloc(
            repository: getIt<ProfileRepository>(),
            initialProfile: profile,
          ),
          child: const _EditView(),
        );
      },
    );
  }
}

class _EditView extends StatelessWidget {
  const _EditView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
            title: const Text('Edit profile'),
            leading: const AppBackButton(),
          ),
      body: BlocConsumer<EditProfileBloc, EditProfileState>(
        listenWhen: (p, n) =>
            p.savedToken != n.savedToken ||
            (p.errors != n.errors && n.errors.isNotEmpty),
        listener: (context, state) {
          if (state.errors.isNotEmpty) {
            showAppToast(
              context,
              message: state.errors.join('\n'),
              variant: ToastVariant.error,
            );
          } else if (state.savedToken > 0) {
            showAppToast(
              context,
              message: 'Saved',
              variant: ToastVariant.success,
            );
            // Keep ProfileBloc in sync so the underlying screen reflects
            // the new value when the user pops back.
            context
                .read<ProfileBloc>()
                .add(const ProfileLoadRequested());
          }
        },
        builder: (context, state) {
          final profile = state.profile;
          if (profile == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.xl2,
            ),
            children: [
              _NicknameCard(
                initial: profile.nickname ?? '',
                busy: state.isSaving(EditableField.nickname),
              ),
              const SizedBox(height: AppSpacing.md),
              _BioCard(
                initial: profile.bio ?? '',
                busy: state.isSaving(EditableField.bio),
              ),
              const SizedBox(height: AppSpacing.md),
              _GenderCard(
                initial: profile.gender,
                busy: state.isSaving(EditableField.gender),
              ),
              const SizedBox(height: AppSpacing.md),
              _BirthdateCard(
                initial: profile.birthdate,
                busy: state.isSaving(EditableField.birthdate),
              ),
              const SizedBox(height: AppSpacing.md),
              _BallHandlingCard(
                handedness: profile.handedness,
                ballCarry: profile.ballCarry,
                grip: profile.grip,
                busy: state.isSaving(EditableField.ballHandling),
              ),
              const SizedBox(height: AppSpacing.md),
              _GameStatsCard(
                average: profile.average,
                highGame: profile.highGame,
                highSeries: profile.highSeries,
                experience: profile.experience,
                busy: state.isSaving(EditableField.gameStats),
              ),
              const SizedBox(height: AppSpacing.md),
              _AddressCard(
                initial: profile.address ?? '',
                initialZip: profile.zipCode ?? '',
                busy: state.isSaving(EditableField.address),
              ),
              const SizedBox(height: AppSpacing.md),
              _HomeCenterCard(
                initial: profile.homeCenter ?? '',
                busy: state.isSaving(EditableField.homeCenter),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section wrapper
// ─────────────────────────────────────────────────────────────────────────────
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
                style: AppTextStyles.label.copyWith(color: colors.textSecondary),
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed, required this.busy});

  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AppButton(
        label: 'Save',
        size: AppButtonSize.small,
        loading: busy,
        onPressed: busy ? null : onPressed,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nickname
// ─────────────────────────────────────────────────────────────────────────────
class _NicknameCard extends StatefulWidget {
  const _NicknameCard({required this.initial, required this.busy});
  final String initial;
  final bool busy;

  @override
  State<_NicknameCard> createState() => _NicknameCardState();
}

class _NicknameCardState extends State<_NicknameCard> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: LucideIcons.atSign,
      title: 'Nickname',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            controller: _controller,
            hint: 'What should we call you?',
            maxLength: 30,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: () => context
                .read<EditProfileBloc>()
                .add(EditProfileNicknameSubmitted(_controller.text)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bio
// ─────────────────────────────────────────────────────────────────────────────
class _BioCard extends StatefulWidget {
  const _BioCard({required this.initial, required this.busy});
  final String initial;
  final bool busy;

  @override
  State<_BioCard> createState() => _BioCardState();
}

class _BioCardState extends State<_BioCard> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: LucideIcons.fileText,
      title: 'Bio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            controller: _controller,
            hint: 'A short note about you and your bowling.',
            maxLines: 4,
            minLines: 3,
            maxLength: 280,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: () => context
                .read<EditProfileBloc>()
                .add(EditProfileBioSubmitted(_controller.text)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender (Male / Female only — backend enum)
// ─────────────────────────────────────────────────────────────────────────────
class _GenderCard extends StatefulWidget {
  const _GenderCard({required this.initial, required this.busy});
  final String? initial;
  final bool busy;

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard> {
  late String? _value = widget.initial;

  static const _options = ['Male', 'Female'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _SectionCard(
      icon: LucideIcons.user,
      title: 'Gender',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final opt in _options)
                _Pill(
                  label: opt,
                  active: _value == opt,
                  onTap: () => setState(() => _value = opt),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: _value == null
                ? null
                : () => context
                    .read<EditProfileBloc>()
                    .add(EditProfileGenderSubmitted(_value!)),
          ),
          if (_value == null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                'Pick one to enable Save',
                textAlign: TextAlign.right,
                style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Birthdate
// ─────────────────────────────────────────────────────────────────────────────
class _BirthdateCard extends StatefulWidget {
  const _BirthdateCard({required this.initial, required this.busy});
  final String? initial;
  final bool busy;

  @override
  State<_BirthdateCard> createState() => _BirthdateCardState();
}

class _BirthdateCardState extends State<_BirthdateCard> {
  DateTime? _picked;
  late final _parentEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    final raw = widget.initial;
    if (raw != null && raw.isNotEmpty) {
      _picked = DateTime.tryParse(raw);
    }
  }

  @override
  void dispose() {
    _parentEmail.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final colors = context.colors;
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _picked ??
          DateTime(now.year - 25, now.month, now.day), // sensible default
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
                  primary: colors.accent,
                ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) setState(() => _picked = result);
  }

  bool get _underageNeedsParent {
    final d = _picked;
    if (d == null) return false;
    final now = DateTime.now();
    var age = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
      age--;
    }
    return age < 13;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iso = _picked == null
        ? null
        : '${_picked!.year.toString().padLeft(4, '0')}-'
            '${_picked!.month.toString().padLeft(2, '0')}-'
            '${_picked!.day.toString().padLeft(2, '0')}';
    return _SectionCard(
      icon: LucideIcons.calendar,
      title: 'Birthdate',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _pick,
            borderRadius: AppRadius.mdAll,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: colors.borderStrong),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.calendar,
                      size: 14, color: colors.textTertiary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      iso ?? 'Tap to pick a date',
                      style: AppTextStyles.body.copyWith(
                        color: iso == null
                            ? colors.textTertiary
                            : colors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(LucideIcons.chevronRight,
                      size: 14, color: colors.textTertiary),
                ],
              ),
            ),
          ),
          if (_underageNeedsParent) ...[
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _parentEmail,
              label: 'Parent / guardian email',
              hint: 'parent@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: iso == null
                ? null
                : () => context.read<EditProfileBloc>().add(
                      EditProfileBirthdateSubmitted(
                        isoDate: iso,
                        parentEmail: _underageNeedsParent
                            ? _parentEmail.text.trim()
                            : null,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ball handling — three required dropdowns (enum-restricted server side)
// ─────────────────────────────────────────────────────────────────────────────
class _BallHandlingCard extends StatefulWidget {
  const _BallHandlingCard({
    required this.handedness,
    required this.ballCarry,
    required this.grip,
    required this.busy,
  });

  final String? handedness;
  final String? ballCarry;
  final String? grip;
  final bool busy;

  @override
  State<_BallHandlingCard> createState() => _BallHandlingCardState();
}

class _BallHandlingCardState extends State<_BallHandlingCard> {
  static const _handednessOptions = ['Righty', 'Lefty'];
  static const _carryOptions = ['One handed', 'Two handed'];
  static const _gripOptions = ['With Thumb', 'With No Thumb'];

  late String? _handedness = _normalize(widget.handedness, _handednessOptions);
  late String? _carry = _normalize(widget.ballCarry, _carryOptions);
  late String? _grip = _normalize(widget.grip, _gripOptions);

  static String? _normalize(String? raw, List<String> options) {
    if (raw == null) return null;
    final match = options.firstWhere(
      (o) => o.toLowerCase() == raw.toLowerCase(),
      orElse: () => '',
    );
    return match.isEmpty ? null : match;
  }

  bool get _complete => _handedness != null && _carry != null && _grip != null;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: LucideIcons.hand,
      title: 'Ball handling',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OptionRow(
            label: 'Handedness',
            options: _handednessOptions,
            value: _handedness,
            onChanged: (v) => setState(() => _handedness = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _OptionRow(
            label: 'Ball carry',
            options: _carryOptions,
            value: _carry,
            onChanged: (v) => setState(() => _carry = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _OptionRow(
            label: 'Grip',
            options: _gripOptions,
            value: _grip,
            onChanged: (v) => setState(() => _grip = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: _complete
                ? () => context.read<EditProfileBloc>().add(
                      EditProfileBallHandlingSubmitted(
                        handedness: _handedness!,
                        ballCarry: _carry!,
                        grip: _grip!,
                      ),
                    )
                : null,
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final opt in options)
              _Pill(
                label: opt,
                active: value == opt,
                onTap: () => onChanged(opt),
              ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Game stats
// ─────────────────────────────────────────────────────────────────────────────
class _GameStatsCard extends StatefulWidget {
  const _GameStatsCard({
    required this.average,
    required this.highGame,
    required this.highSeries,
    required this.experience,
    required this.busy,
  });

  final num? average;
  final int? highGame;
  final int? highSeries;
  final int? experience;
  final bool busy;

  @override
  State<_GameStatsCard> createState() => _GameStatsCardState();
}

class _GameStatsCardState extends State<_GameStatsCard> {
  late final _average =
      TextEditingController(text: widget.average?.toString() ?? '');
  late final _highGame =
      TextEditingController(text: widget.highGame?.toString() ?? '');
  late final _highSeries =
      TextEditingController(text: widget.highSeries?.toString() ?? '');
  late final _experience =
      TextEditingController(text: widget.experience?.toString() ?? '');

  @override
  void dispose() {
    _average.dispose();
    _highGame.dispose();
    _highSeries.dispose();
    _experience.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: LucideIcons.target,
      title: 'Game stats',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppInput(
                  controller: _average,
                  label: 'Average',
                  hint: '180',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppInput(
                  controller: _highGame,
                  label: 'High game',
                  hint: '300',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppInput(
                  controller: _highSeries,
                  label: 'High series',
                  hint: '750',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppInput(
                  controller: _experience,
                  label: 'Years bowling',
                  hint: '10',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: () => context.read<EditProfileBloc>().add(
                  EditProfileGameStatsSubmitted(
                    average: num.tryParse(_average.text.trim()),
                    highGame: int.tryParse(_highGame.text.trim()),
                    highSeries: int.tryParse(_highSeries.text.trim()),
                    experience: int.tryParse(_experience.text.trim()),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Address — Nominatim autocomplete
// ─────────────────────────────────────────────────────────────────────────────
class _AddressCard extends StatefulWidget {
  const _AddressCard({
    required this.initial,
    required this.initialZip,
    required this.busy,
  });

  final String initial;
  final String initialZip;
  final bool busy;

  @override
  State<_AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<_AddressCard> {
  late final _controller = TextEditingController(text: widget.initial);
  final _geocoder = getIt<GeocoderService>();

  Timer? _debounce;
  List<GeocodeSuggestion> _suggestions = const [];
  bool _searching = false;
  GeocodeSuggestion? _picked;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _picked = null;
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      final results = await _geocoder.search(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _SectionCard(
      icon: LucideIcons.mapPin,
      title: 'Address',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            controller: _controller,
            hint: 'Start typing an address…',
            onChanged: _onChanged,
            suffixIcon: _searching
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.accent,
                      ),
                    ),
                  )
                : null,
          ),
          if (_suggestions.isNotEmpty && _picked == null) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: colors.borderDefault),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _suggestions.length; i++) ...[
                    if (i > 0)
                      Divider(height: 1, color: colors.borderDefault),
                    InkWell(
                      onTap: () {
                        final s = _suggestions[i];
                        _controller.text = s.displayName;
                        setState(() {
                          _picked = s;
                          _suggestions = const [];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          _suggestions[i].displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (_picked != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Coordinates ${_picked!.latitude.toStringAsFixed(4)}, '
              '${_picked!.longitude.toStringAsFixed(4)}'
              '${_picked!.zipCode.isEmpty ? '' : '  •  ZIP ${_picked!.zipCode}'}',
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: _picked == null
                ? null
                : () {
                    final p = _picked!;
                    context.read<EditProfileBloc>().add(
                          EditProfileAddressSubmitted(
                            address: p.displayName,
                            zipCode: p.zipCode.isNotEmpty
                                ? p.zipCode
                                : widget.initialZip,
                            latitude: p.latitude,
                            longitude: p.longitude,
                          ),
                        );
                  },
          ),
          if (_picked == null && _controller.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                'Pick a suggestion to enable Save',
                textAlign: TextAlign.right,
                style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home center — debounced /api/search/centers autocomplete
// ─────────────────────────────────────────────────────────────────────────────
class _HomeCenterCard extends StatefulWidget {
  const _HomeCenterCard({required this.initial, required this.busy});
  final String initial;
  final bool busy;

  @override
  State<_HomeCenterCard> createState() => _HomeCenterCardState();
}

class _HomeCenterCardState extends State<_HomeCenterCard> {
  late final _controller = TextEditingController(text: widget.initial);
  final _search = getIt<SearchRepository>();

  Timer? _debounce;
  List<CenterSearchResult> _suggestions = const [];
  bool _searching = false;
  CenterSearchResult? _picked;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _picked = null;
    final q = value.trim();
    if (q.length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      final res = await _search.searchCenters(query: q);
      if (!mounted) return;
      res.fold(
        (_) => setState(() {
          _suggestions = const [];
          _searching = false;
        }),
        (list) => setState(() {
          _suggestions = list;
          _searching = false;
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _SectionCard(
      icon: LucideIcons.house,
      title: 'Home center',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInput(
            controller: _controller,
            hint: 'Search bowling centers…',
            onChanged: _onChanged,
            suffixIcon: _searching
                ? Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.accent,
                      ),
                    ),
                  )
                : null,
          ),
          if (_suggestions.isNotEmpty && _picked == null) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: colors.borderDefault),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _suggestions.length; i++) ...[
                    if (i > 0)
                      Divider(height: 1, color: colors.borderDefault),
                    InkWell(
                      onTap: () {
                        final c = _suggestions[i];
                        _controller.text = c.name;
                        setState(() {
                          _picked = c;
                          _suggestions = const [];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _suggestions[i].name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_suggestions[i].address.isNotEmpty)
                              Text(
                                _suggestions[i].address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.nano.copyWith(
                                  color: colors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _SaveButton(
            busy: widget.busy,
            onPressed: _picked == null
                ? null
                : () => context.read<EditProfileBloc>().add(
                      EditProfileHomeCenterSubmitted(
                        centerId: _picked!.id,
                        centerName: _picked!.name,
                      ),
                    ),
          ),
          if (_picked == null && _controller.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                'Pick a center to enable Save',
                textAlign: TextAlign.right,
                style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared pill
// ─────────────────────────────────────────────────────────────────────────────
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
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
