import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../router/route_names.dart';

/// Drop-in leading widget for any [AppBar] on a non-tab screen. Always
/// shows an arrow — pops the route if there's anything to pop, otherwise
/// falls back to [RouteNames.home].
///
/// Use this everywhere instead of relying on `AppBar.automaticallyImplyLeading`,
/// which silently disappears when the user entered the route via
/// `context.go` (since `Navigator.canPop` is then false).
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.fallbackRoute = RouteNames.home,
    this.tooltip = 'Back',
  });

  /// Where to send the user when there is no route to pop. Defaults to
  /// the home tab — adjust per screen when "back" should land somewhere
  /// more contextual (e.g. a thread-detail might fall back to the
  /// messages list).
  final String fallbackRoute;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: const Icon(LucideIcons.arrowLeft),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(fallbackRoute);
        }
      },
    );
  }
}
