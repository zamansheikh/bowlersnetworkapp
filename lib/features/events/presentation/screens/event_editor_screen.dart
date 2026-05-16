import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../../../search/domain/entities/search_result.dart';
import '../../../search/domain/repositories/search_repository.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../bloc/event_editor_bloc.dart';

/// /events/new and /events/:uid/edit — single sectional form for
/// create + edit. The bloc tracks the pick-list state (type, date,
/// location); local controllers own title / description / flyer URL.
class EventEditorScreen extends StatelessWidget {
  const EventEditorScreen({super.key, this.existing});

  /// When present, the form is in edit mode and pre-fills from this
  /// event. When null, the form creates a new event.
  final Event? existing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventEditorBloc>(
      create: (_) => EventEditorBloc(
        repository: getIt<EventsRepository>(),
        existing: existing,
      )..add(const EventEditorLoadTypes()),
      child: _EditorView(existing: existing),
    );
  }
}

class _EditorView extends StatefulWidget {
  const _EditorView({this.existing});
  final Event? existing;

  @override
  State<_EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<_EditorView> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _description =
      TextEditingController(text: widget.existing?.description);
  late final _flyer = TextEditingController(text: widget.existing?.flyerUrl);

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _flyer.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<EventEditorBloc>().add(EventEditorSubmitRequested(
          title: _title.text,
          description: _description.text,
          flyerUrl: _flyer.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEdit = widget.existing != null;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit event' : 'New event'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<EventEditorBloc, EventEditorState>(
        listenWhen: (p, n) =>
            (p.errors != n.errors && n.errors.isNotEmpty) ||
            (p.saved != n.saved && n.saved != null),
        listener: (context, state) {
          if (state.errors.isNotEmpty) {
            showAppToast(
              context,
              message: state.errors.join('\n'),
              variant: ToastVariant.error,
            );
          } else if (state.saved != null) {
            showAppToast(
              context,
              message: isEdit ? 'Event updated.' : 'Event created.',
              variant: ToastVariant.success,
            );
            // For create: replace the new event's route on top.
            // For edit: pop back to the (existing) detail screen.
            if (isEdit) {
              if (context.canPop()) context.pop();
            } else {
              context.go('/events/${state.saved!.uid}');
            }
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
                icon: LucideIcons.pencil,
                title: 'Basics',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppInput(
                      controller: _title,
                      label: 'Title',
                      hint: 'e.g. Friday Night Doubles',
                      maxLength: 200,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppInput(
                      controller: _description,
                      label: 'Description',
                      hint:
                          'Format, prize, dress code, anything attendees should know.',
                      maxLines: 5,
                      minLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppInput(
                      controller: _flyer,
                      label: 'Flyer URL (optional)',
                      hint: 'https://…',
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SectionCard(
                icon: LucideIcons.tag,
                title: 'Type',
                child: state.types.isEmpty
                    ? Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                          'Loading event types…',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: colors.textTertiary),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in state.types)
                            _Pill(
                              label: t.name,
                              active: state.eventTypeId == t.id,
                              onTap: () => context
                                  .read<EventEditorBloc>()
                                  .add(EventEditorTypeChanged(t.id)),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              _DateSection(date: state.eventDate),
              const SizedBox(height: AppSpacing.md),
              _LocationSection(state: state),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: isEdit ? 'Save changes' : 'Create event',
                icon: LucideIcons.check,
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

// ─────────────────────────────────────────────────────────────────────────────
// Date + time
// ─────────────────────────────────────────────────────────────────────────────
class _DateSection extends StatelessWidget {
  const _DateSection({required this.date});
  final DateTime? date;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial =
        date != null && date!.isAfter(now) ? date! : now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !context.mounted) return;
    final combined = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time.hour,
      time.minute,
    );
    context.read<EventEditorBloc>().add(EventEditorDateChanged(combined));
  }

  String _label(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '${months[d.month - 1]} ${d.day}, ${d.year}  •  $h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _SectionCard(
      icon: LucideIcons.calendar,
      title: 'When',
      child: InkWell(
        onTap: () => _pick(context),
        borderRadius: AppRadius.mdAll,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: colors.borderStrong),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: colors.textTertiary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  date == null
                      ? 'Tap to pick date and time'
                      : _label(date!.toLocal()),
                  style: AppTextStyles.body.copyWith(
                    color: date == null
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Location — Online / Center (autocomplete) / Custom (geocode)
// ─────────────────────────────────────────────────────────────────────────────
class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.state});
  final EventEditorState state;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: LucideIcons.mapPin,
      title: 'Where',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OnlineToggle(isOnline: state.isOnline),
          if (!state.isOnline) ...[
            const SizedBox(height: AppSpacing.sm),
            _LocationModeRow(mode: state.locationMode),
            const SizedBox(height: AppSpacing.sm),
            if (state.locationMode == EventLocationMode.center)
              _CenterPicker(
                currentId: state.centerId,
                currentLabel: state.centerLabel,
              )
            else
              _AddressPicker(
                currentLabel: state.addressLabel,
                hasPick: state.latitude != null && state.longitude != null,
              ),
          ],
        ],
      ),
    );
  }
}

class _OnlineToggle extends StatelessWidget {
  const _OnlineToggle({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(LucideIcons.video, size: 14, color: colors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Online event',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
        Switch.adaptive(
          value: isOnline,
          activeThumbColor: colors.accent,
          onChanged: (v) => context
              .read<EventEditorBloc>()
              .add(EventEditorOnlineToggled(v)),
        ),
      ],
    );
  }
}

class _LocationModeRow extends StatelessWidget {
  const _LocationModeRow({required this.mode});
  final EventLocationMode mode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pill(
          label: 'Bowling center',
          active: mode == EventLocationMode.center,
          onTap: () => context.read<EventEditorBloc>().add(
                const EventEditorLocationModeChanged(
                  EventLocationMode.center,
                ),
              ),
        ),
        _Pill(
          label: 'Custom address',
          active: mode == EventLocationMode.custom,
          onTap: () => context.read<EventEditorBloc>().add(
                const EventEditorLocationModeChanged(
                  EventLocationMode.custom,
                ),
              ),
        ),
      ],
    );
  }
}

class _CenterPicker extends StatefulWidget {
  const _CenterPicker({required this.currentId, required this.currentLabel});
  final int? currentId;
  final String currentLabel;

  @override
  State<_CenterPicker> createState() => _CenterPickerState();
}

class _CenterPickerState extends State<_CenterPicker> {
  late final _controller =
      TextEditingController(text: widget.currentLabel);
  final _search = getIt<SearchRepository>();

  Timer? _debounce;
  List<CenterSearchResult> _suggestions = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
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
    return Column(
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
        if (_suggestions.isNotEmpty) ...[
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
                      setState(() => _suggestions = const []);
                      context.read<EventEditorBloc>().add(
                            EventEditorCenterSelected(
                              id: c.id,
                              label: c.name,
                            ),
                          );
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
        if (widget.currentId != null) ...[
          const SizedBox(height: 4),
          Text(
            'Selected: ${widget.currentLabel}',
            style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
          ),
        ],
      ],
    );
  }
}

class _AddressPicker extends StatefulWidget {
  const _AddressPicker({required this.currentLabel, required this.hasPick});
  final String currentLabel;
  final bool hasPick;

  @override
  State<_AddressPicker> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<_AddressPicker> {
  late final _controller =
      TextEditingController(text: widget.currentLabel);
  final _geocoder = getIt<GeocoderService>();

  Timer? _debounce;
  List<GeocodeSuggestion> _suggestions = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInput(
          controller: _controller,
          hint: 'Search an address…',
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
        if (_suggestions.isNotEmpty) ...[
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
                      setState(() => _suggestions = const []);
                      context.read<EventEditorBloc>().add(
                            EventEditorAddressSelected(
                              address: s.displayName,
                              latitude: s.latitude,
                              longitude: s.longitude,
                              zipcode:
                                  s.zipCode.isEmpty ? null : s.zipCode,
                            ),
                          );
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
        if (widget.hasPick && _suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Saved address pinned to coordinates.',
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section card + pill
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
