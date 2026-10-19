import 'dart:ui' show ImageFilter;

import 'package:flutter/widgets.dart';

/// Route melayang dengan latar gelap ber-blur, dasar Modal dan Drawer.
/// Internal; gunakan `showIddsModal` atau `showIddsDrawer`.
class IddsOverlayRoute<T> extends PopupRoute<T> {
  /// Membuat route.
  IddsOverlayRoute({
    required this.pageBuilder,
    required this.transitionBuilder,
    required this.barrierDismissible,
    required this.barrierColor,
    required this.barrierLabel,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    this.blurSigma = 2,
    super.settings,
  });

  /// Membangun isi route.
  final WidgetBuilder pageBuilder;

  /// Animasi masuk/keluar isi (tanpa latar).
  final Widget Function(BuildContext context, Animation<double> animation, Widget child) transitionBuilder;

  @override
  final bool barrierDismissible;

  @override
  final Color barrierColor;

  @override
  final String barrierLabel;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  /// Blur di belakang latar (CSS `backdrop-filter: blur(2px)`).
  final double blurSigma;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(scopesRoute: true, explicitChildNodes: true, child: pageBuilder(context));
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (blurSigma > 0)
          // Hanya efek visual; ketukan diteruskan ke latar (barrier).
          IgnorePointer(
            child: AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? _) {
                final double sigma = blurSigma * animation.value;
                if (sigma <= 0.01) return const SizedBox.expand();
                return ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
        transitionBuilder(context, animation, child),
      ],
    );
  }
}

/// Memasang route di [Navigator] terdekat (atau root) dengan tema dari
/// [context] ikut terbawa, termasuk bila `IddsTheme` hanya membungkus
/// halaman dan bukan seluruh aplikasi.
Future<T?> iddsPushOverlayRoute<T>(
  BuildContext context,
  IddsOverlayRoute<T> Function(Widget Function(Widget child) wrapTheme) createRoute, {
  bool useRootNavigator = true,
}) {
  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final CapturedThemes themes = InheritedTheme.capture(from: context, to: navigator.context);
  return navigator.push<T>(createRoute(themes.wrap));
}
