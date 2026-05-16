import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Bottom sheet that lets the user pick where the image should come from.
/// Returns the chosen [ImageSource] or null on cancel. Designed for
/// profile-picture / cover-photo flows but reusable anywhere we need a
/// "Take photo / Choose from gallery" prompt.
Future<ImageSource?> showImageSourceSheet(
  BuildContext context, {
  String title = 'Update photo',
}) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      final colors = sheetCtx.colors;
      return SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.bgSurfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderDefault),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.sm,
                  AppSpacing.base,
                  AppSpacing.sm,
                ),
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              _SourceTile(
                icon: LucideIcons.camera,
                label: 'Take photo',
                onTap: () =>
                    Navigator.of(sheetCtx).pop(ImageSource.camera),
              ),
              _SourceTile(
                icon: LucideIcons.image,
                label: 'Choose from gallery',
                onTap: () =>
                    Navigator.of(sheetCtx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.accent),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
