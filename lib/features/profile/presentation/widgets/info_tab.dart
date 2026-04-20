import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/profile.dart';

/// Bento grid of profile info blocks. Read-only for now; tapping an
/// editable block will open an editor in a later step.
class ProfileInfoTab extends StatelessWidget {
  const ProfileInfoTab({
    super.key,
    required this.profile,
    required this.isSelf,
  });

  final Profile profile;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bio card — spans full width
        if (profile.bio != null && profile.bio!.isNotEmpty) _BioCard(bio: profile.bio!),
        if (profile.bio != null && profile.bio!.isNotEmpty)
          const SizedBox(height: AppSpacing.md),
        // Game stats row
        if (profile.average != null ||
            profile.highGame != null ||
            profile.highSeries != null ||
            profile.experience != null)
          _GameStatsCard(profile: profile),
        if (profile.average != null ||
            profile.highGame != null ||
            profile.highSeries != null ||
            profile.experience != null)
          const SizedBox(height: AppSpacing.md),
        // Bento grid — 2 cols on phones, responsive to tablets
        LayoutBuilder(
          builder: (context, constraints) {
            final twoCols = constraints.maxWidth >= 360;
            final fields = _infoFields(profile, colors);
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: fields.map((f) {
                final w = twoCols
                    ? (constraints.maxWidth - AppSpacing.md) / 2
                    : constraints.maxWidth;
                return SizedBox(width: w, child: _InfoCard(field: f));
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  List<_InfoField> _infoFields(Profile p, dynamic colors) {
    return [
      if (p.gender != null)
        _InfoField(
          icon: LucideIcons.user,
          label: 'Gender',
          value: p.gender!,
        ),
      if (p.birthdate != null)
        _InfoField(
          icon: LucideIcons.cake,
          label: 'Birthday',
          value: p.age != null ? '${p.birthdate}  (age ${p.age})' : p.birthdate!,
        ),
      if (p.nickname != null && p.nickname!.isNotEmpty)
        _InfoField(
          icon: LucideIcons.atSign,
          label: 'Nickname',
          value: p.nickname!,
        ),
      if (p.homeCenter != null && p.homeCenter!.isNotEmpty)
        _InfoField(
          icon: LucideIcons.mapPin,
          label: 'Home center',
          value: p.homeCenter!,
        ),
      if (p.address != null && p.address!.isNotEmpty)
        _InfoField(
          icon: LucideIcons.mapPin,
          label: 'Location',
          value: p.zipCode == null
              ? p.address!
              : '${p.address!} · ${p.zipCode}',
        ),
      if (p.hasBallHandling)
        _InfoField(
          icon: LucideIcons.target,
          label: 'Ball handling',
          value: [p.handedness, p.ballCarry, p.grip]
              .where((e) => e != null && e.isNotEmpty)
              .cast<String>()
              .join(' · '),
        ),
      if (p.contactEmail != null && p.contactEmail!.isNotEmpty)
        _InfoField(
          icon: LucideIcons.mail,
          label: 'Contact email',
          value: p.contactEmail!,
        ),
      if (p.isCoach)
        _InfoField(
          icon: LucideIcons.graduationCap,
          label: 'Role',
          value: 'Coach',
          accent: true,
        ),
    ];
  }
}

class _InfoField {
  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool accent;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.field});

  final _InfoField field;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.accentSubtle,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(field.icon, size: 14, color: colors.accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                field.label.toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            field.value,
            style: AppTextStyles.body.copyWith(
              color: field.accent ? colors.accent : colors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BioCard extends StatelessWidget {
  const _BioCard({required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BIO',
            style: AppTextStyles.label.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            bio,
            style: AppTextStyles.body.copyWith(
              color: colors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameStatsCard extends StatelessWidget {
  const _GameStatsCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stats = <_Stat>[
      if (profile.average != null)
        _Stat(
          'Average',
          profile.average!.toStringAsFixed(0),
          LucideIcons.chartLine,
          colors.accent,
        ),
      if (profile.highGame != null)
        _Stat(
          'High Game',
          '${profile.highGame}',
          LucideIcons.trendingUp,
          const Color(0xFFEAB308),
        ),
      if (profile.highSeries != null)
        _Stat(
          'High Series',
          '${profile.highSeries}',
          LucideIcons.trophy,
          const Color(0xFFF97316),
        ),
      if (profile.experience != null)
        _Stat(
          'Experience',
          '${profile.experience} yr',
          LucideIcons.timer,
          const Color(0xFF3B82F6),
        ),
    ];
    if (stats.isEmpty) return const SizedBox.shrink();

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.md,
              AppSpacing.base,
              AppSpacing.sm,
            ),
            child: Text(
              'GAME STATS',
              style: AppTextStyles.label.copyWith(color: colors.textTertiary),
            ),
          ),
          Divider(height: 1, color: colors.borderDefault),
          // 2×2 grid — width-adaptive so narrow phones never overflow. On
          // tablets (>=520dp) we flatten to a single row for compactness.
          LayoutBuilder(
            builder: (ctx, cs) {
              final useRow = cs.maxWidth >= 520;
              if (useRow) {
                return IntrinsicHeight(
                  child: Row(
                    children: [
                      for (var i = 0; i < stats.length; i++) ...[
                        Expanded(child: _StatCell(stat: stats[i])),
                        if (i < stats.length - 1)
                          VerticalDivider(
                            width: 1,
                            color: colors.borderDefault,
                          ),
                      ],
                    ],
                  ),
                );
              }
              // 2 columns per row, wrap to multiple rows as needed.
              final rows = <Widget>[];
              for (var i = 0; i < stats.length; i += 2) {
                final left = stats[i];
                final right = i + 1 < stats.length ? stats[i + 1] : null;
                rows.add(
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(child: _StatCell(stat: left)),
                        VerticalDivider(
                          width: 1,
                          color: colors.borderDefault,
                        ),
                        Expanded(
                          child: right == null
                              ? const SizedBox.shrink()
                              : _StatCell(stat: right),
                        ),
                      ],
                    ),
                  ),
                );
                if (i + 2 < stats.length) {
                  rows.add(Divider(height: 1, color: colors.borderDefault));
                }
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Stat {
  _Stat(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat.icon, size: 16, color: stat.color),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              stat.value,
              maxLines: 1,
              style: AppTextStyles.numberLarge.copyWith(
                color: colors.textPrimary,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label.toUpperCase(),
            style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
