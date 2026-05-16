import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Drop-in image widget for rank/tier badges.
///
/// The backend serves badges as SVG (e.g.
/// `https://logos.bowlersnetwork.com/badges/v3/level_06_explorer_bronze.svg`),
/// and `CachedNetworkImage` throws `Invalid image data` on those because
/// its codec can't decode vector data. This widget sniffs the URL: `.svg`
/// → `SvgPicture.network`, everything else → `CachedNetworkImage`.
///
/// Falls back to [placeholder] (or an empty SizedBox) when [url] is null
/// or empty.
class NetworkBadge extends StatelessWidget {
  const NetworkBadge({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.size,
    this.fit = BoxFit.contain,
    this.placeholder,
  });

  final String? url;
  final double? width;
  final double? height;

  /// Convenience: sets both [width] and [height]. Ignored when either is set.
  final double? size;

  final BoxFit fit;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;

    if (url == null || url!.isEmpty) {
      return SizedBox(width: w, height: h, child: placeholder);
    }

    final isSvg = url!.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.network(
        url!,
        width: w,
        height: h,
        fit: fit,
        placeholderBuilder: (_) =>
            SizedBox(width: w, height: h, child: placeholder),
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      width: w,
      height: h,
      fit: fit,
      placeholder: (_, _) =>
          SizedBox(width: w, height: h, child: placeholder),
      errorWidget: (_, _, _) =>
          SizedBox(width: w, height: h, child: placeholder),
    );
  }
}
