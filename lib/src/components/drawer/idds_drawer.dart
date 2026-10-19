import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/idds_overlay_route.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../modal/idds_modal.dart' show IddsCloseButton, IddsDismissOnEscape;

/// Sisi munculnya drawer.
enum IddsDrawerPosition {
  /// Kanan (bawaan).
  right,

  /// Kiri.
  left,

  /// Atas.
  top,

  /// Bawah.
  bottom,
}

/// Menampilkan drawer (panel geser dari tepi layar) dan menunggu hingga
/// ditutup.
///
/// Di layar ≥ 641px drawer kiri/kanan setinggi layar dengan lebar [width]
/// (bawaan 420px), sedangkan drawer atas/bawah selebar layar dengan tinggi
/// 60%. Di layar lebih kecil, drawer kiri/kanan/bawah tampil sebagai panel
/// dari bawah setinggi 45% layar, sama seperti versi web.
///
/// ```dart
/// showIddsDrawer<void>(
///   context: context,
///   builder: (context) => IddsDrawer(
///     title: const Text('Filter'),
///     actions: [IddsButton(onPressed: () => Navigator.pop(context), child: const Text('Terapkan'))],
///     child: const FilterForm(),
///   ),
/// );
/// ```
Future<T?> showIddsDrawer<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  IddsDrawerPosition position = IddsDrawerPosition.right,
  double width = 420,
  double? height,
  bool barrierDismissible = true,
  String barrierLabel = 'Tutup panel',
  bool useRootNavigator = true,
  RouteSettings? settings,
}) {
  return iddsPushOverlayRoute<T>(
    context,
    (Widget Function(Widget) wrapTheme) => IddsOverlayRoute<T>(
      settings: settings,
      barrierDismissible: barrierDismissible,
      // CSS: rgba(31, 31, 31, .48) + blur 2px.
      barrierColor: const Color(0x7A1F1F1F),
      barrierLabel: barrierLabel,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: IddsDuration.slow,
      pageBuilder: (BuildContext context) => wrapTheme(
        _DrawerPanel(position: position, width: width, height: height, child: Builder(builder: builder)),
      ),
      transitionBuilder: (BuildContext context, Animation<double> animation, Widget child) {
        final IddsDrawerPosition side = _effectivePosition(context, position);
        // CSS: cubic-bezier(.16, 1, .3, 1) masuk, (.4, 0, .2, 1) keluar.
        final Animation<double> curved = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.16, 1, 0.3, 1),
          reverseCurve: const Cubic(0.4, 0, 0.2, 1),
        );
        final Offset begin = switch (side) {
          IddsDrawerPosition.right => const Offset(1, 0),
          IddsDrawerPosition.left => const Offset(-1, 0),
          IddsDrawerPosition.top => const Offset(0, -1),
          IddsDrawerPosition.bottom => const Offset(0, 1),
        };
        return SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curved),
          child: child,
        );
      },
    ),
    useRootNavigator: useRootNavigator,
  );
}

/// Di layar ≤ 640px drawer kiri/kanan menjadi panel dari bawah.
IddsDrawerPosition _effectivePosition(BuildContext context, IddsDrawerPosition position) {
  final double width = MediaQuery.sizeOf(context).width;
  if (width <= 640 && (position == IddsDrawerPosition.left || position == IddsDrawerPosition.right)) {
    return IddsDrawerPosition.bottom;
  }
  return position;
}

/// Wadah drawer: ukuran, posisi, sudut, dan bayangan.
class _DrawerPanel extends StatelessWidget {
  const _DrawerPanel({required this.position, required this.width, required this.height, required this.child});

  final IddsDrawerPosition position;
  final double width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final Size screen = MediaQuery.sizeOf(context);
    final bool small = screen.width <= 640;
    final IddsDrawerPosition side = _effectivePosition(context, position);
    const Radius r = Radius.circular(IddsRadius.lg);

    // Sudut membulat hanya di sisi yang menghadap halaman.
    final BorderRadius radius = switch (side) {
      IddsDrawerPosition.right => const BorderRadius.only(topLeft: r, bottomLeft: r),
      IddsDrawerPosition.left => const BorderRadius.only(topRight: r, bottomRight: r),
      IddsDrawerPosition.top => const BorderRadius.only(bottomLeft: r, bottomRight: r),
      IddsDrawerPosition.bottom => const BorderRadius.only(topLeft: r, topRight: r),
    };
    final bool horizontal = side == IddsDrawerPosition.left || side == IddsDrawerPosition.right;
    final double panelWidth = horizontal ? math.min(width, screen.width) : screen.width;
    final double panelHeight = horizontal
        ? screen.height
        : (height ??
            (small
                // CSS: 45vh, minimal 280px, maksimal 90vh.
                ? math.min(math.max(screen.height * 0.45, 280), screen.height * 0.9)
                : screen.height * 0.6));

    return Align(
      alignment: switch (side) {
        IddsDrawerPosition.right => Alignment.centerRight,
        IddsDrawerPosition.left => Alignment.centerLeft,
        IddsDrawerPosition.top => Alignment.topCenter,
        IddsDrawerPosition.bottom => Alignment.bottomCenter,
      },
      child: Container(
        width: panelWidth,
        height: math.min(panelHeight, screen.height),
        decoration: BoxDecoration(color: c.backgroundPrimary, borderRadius: radius, boxShadow: IddsShadow.xl),
        child: ClipRRect(
          borderRadius: radius,
          child: _DrawerScope(small: small, child: child),
        ),
      ),
    );
  }
}

/// Memberi tahu [IddsDrawer] bahwa ia tampil di layar kecil.
class _DrawerScope extends InheritedWidget {
  const _DrawerScope({required this.small, required super.child});

  final bool small;

  static bool smallOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DrawerScope>()?.small ??
      MediaQuery.sizeOf(context).width <= 640;

  @override
  bool updateShouldNotify(_DrawerScope oldWidget) => oldWidget.small != small;
}

/// Isi drawer IDDS: judul dengan tombol tutup, isi yang bisa digulir, dan
/// tombol aksi di bawah. Tampilkan dengan [showIddsDrawer].
class IddsDrawer extends StatelessWidget {
  /// Membuat isi drawer.
  const IddsDrawer({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.actionsAlignment = MainAxisAlignment.end,
    this.onClose,
    this.showCloseButton = true,
    this.padding = const EdgeInsets.all(IddsSpacing.s16),
    this.closeLabel = 'Tutup panel',
  });

  /// Isi drawer.
  final Widget child;

  /// Judul, biasanya [Text]; bisa juga berisi logo atau ikon. Teks
  /// mendapat gaya judul bawaan dan ikon mengikuti warna teks.
  final Widget? title;

  /// Tombol di bagian bawah.
  final List<Widget>? actions;

  /// Posisi tombol aksi. Bawaan: kanan.
  final MainAxisAlignment actionsAlignment;

  /// Dipanggil oleh tombol tutup dan tombol Esc. Bawaan: menutup route.
  final VoidCallback? onClose;

  /// Tampilkan tombol tutup.
  final bool showCloseButton;

  /// Jarak isi dari tepi.
  final EdgeInsetsGeometry padding;

  /// Label pembaca layar tombol tutup.
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool small = _DrawerScope.smallOf(context);
    final VoidCallback close = onClose ?? () => Navigator.maybePop(context);
    final BorderSide divider = BorderSide(color: c.strokePrimary);

    return IddsDismissOnEscape(
      onDismiss: close,
      child: Semantics(
        explicitChildNodes: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null || showCloseButton)
              Container(
                padding: const EdgeInsets.all(IddsSpacing.s16),
                decoration: BoxDecoration(border: Border(bottom: divider)),
                child: Row(
                  spacing: IddsSpacing.s12,
                  children: <Widget>[
                    Expanded(
                      child: Semantics(
                        header: true,
                        // Judul menjadi nama route bagi pembaca layar.
                        namesRoute: title != null,
                        child: DefaultTextStyle(
                          style: theme.textStyle(
                            fontSize: small ? IddsFontSize.base : IddsFontSize.lg,
                            lineHeight: small ? IddsLineHeight.base : IddsLineHeight.lg,
                            fontWeight: IddsFontWeight.semibold,
                            color: c.contentPrimary,
                          ),
                          child: IconTheme(
                            data: IconThemeData(size: small ? 20 : 24, color: c.contentPrimary),
                            child: title ?? const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                    if (showCloseButton) IddsCloseButton(label: closeLabel, size: 20, boxSize: 32, onTap: close),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: padding,
                child: DefaultTextStyle(
                  style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentPrimary),
                  child: child,
                ),
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: EdgeInsets.fromLTRB(
                  IddsSpacing.s16,
                  IddsSpacing.s16,
                  IddsSpacing.s16,
                  IddsSpacing.s16 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(border: Border(top: divider)),
                child: Row(
                  mainAxisAlignment: actionsAlignment,
                  spacing: actionsAlignment == MainAxisAlignment.spaceBetween ? 0 : IddsSpacing.s8,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
