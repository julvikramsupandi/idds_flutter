import 'dart:math' as math;

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_overlay_route.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Lebar [IddsModal].
enum IddsModalSize {
  /// 480px (bawaan).
  sm(480),

  /// 640px.
  md(640),

  /// 800px.
  lg(800),

  /// 1000px.
  xl(1000),

  /// Hampir selebar dan setinggi layar.
  full(double.infinity);

  const IddsModalSize(this.width);

  /// Lebar di layar lebar.
  final double width;
}

/// Menampilkan modal di atas halaman dan menunggu hingga ditutup.
///
/// [builder] biasanya mengembalikan [IddsModal]. Nilai yang dikirim lewat
/// `Navigator.pop(context, nilai)` menjadi hasil `Future`.
///
/// ```dart
/// final bool? hapus = await showIddsModal<bool>(
///   context: context,
///   builder: (context) => IddsModal(
///     title: const Text('Hapus dokumen?'),
///     actions: [
///       IddsButton(hierarchy: IddsButtonHierarchy.secondary,
///           onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
///       IddsButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
///     ],
///     child: const Text('Dokumen yang dihapus tidak bisa dikembalikan.'),
///   ),
/// );
/// ```
Future<T?> showIddsModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Tutup',
  bool useRootNavigator = true,
  RouteSettings? settings,
}) {
  return iddsPushOverlayRoute<T>(
    context,
    (Widget Function(Widget) wrapTheme) => IddsOverlayRoute<T>(
      settings: settings,
      barrierDismissible: barrierDismissible,
      // CSS: rgba(0, 0, 0, .6) + blur 2px.
      barrierColor: const Color(0x99000000),
      barrierLabel: barrierLabel,
      transitionDuration: IddsDuration.slow,
      reverseTransitionDuration: IddsDuration.slow,
      pageBuilder: (BuildContext context) => wrapTheme(Builder(builder: builder)),
      transitionBuilder: (BuildContext context, Animation<double> animation, Widget child) {
        // CSS: dari scale(.9) translateY(-20px) dan transparan.
        final Animation<double> curved = CurvedAnimation(parent: animation, curve: Curves.ease);
        return FadeTransition(
          opacity: curved,
          child: AnimatedBuilder(
            animation: curved,
            builder: (BuildContext context, Widget? child) => Transform.translate(
              offset: Offset(0, -20 * (1 - curved.value)),
              child: Transform.scale(scale: 0.9 + 0.1 * curved.value, child: child),
            ),
            child: child,
          ),
        );
      },
    ),
    useRootNavigator: useRootNavigator,
  );
}

/// Kotak dialog IDDS: judul dengan tombol tutup, isi yang bisa digulir, dan
/// tombol aksi di bawah. Tampilkan dengan [showIddsModal].
class IddsModal extends StatelessWidget {
  /// Membuat modal.
  const IddsModal({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.actionsAlignment = MainAxisAlignment.end,
    this.size = IddsModalSize.sm,
    this.onClose,
    this.showHeader = true,
    this.showCloseButton = true,
    this.bodyPadding,
    this.closeLabel = 'Tutup',
  });

  /// Isi modal. Digulir otomatis bila lebih tinggi dari layar.
  final Widget child;

  /// Judul.
  final Widget? title;

  /// Tombol di bagian bawah, misalnya "Batal" dan "Simpan".
  final List<Widget>? actions;

  /// Posisi tombol aksi. Bawaan: kanan.
  final MainAxisAlignment actionsAlignment;

  /// Lebar.
  final IddsModalSize size;

  /// Dipanggil oleh tombol tutup dan tombol Esc. Bawaan: menutup route
  /// (`Navigator.maybePop`).
  final VoidCallback? onClose;

  /// Tampilkan bagian judul dan tombol tutup.
  final bool showHeader;

  /// Tampilkan tombol tutup (X) di bagian judul.
  final bool showCloseButton;

  /// Jarak isi dari tepi. Bawaan: 16px atas-bawah, 24px kiri-kanan.
  final EdgeInsetsGeometry? bodyPadding;

  /// Label pembaca layar tombol tutup.
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final Size screen = MediaQuery.sizeOf(context);
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);
    final VoidCallback close = onClose ?? () => Navigator.maybePop(context);
    // CSS: margin 16px; 8px di layar < 640px; 4px di layar ≤ 480px.
    final double margin = screen.width <= 480
        ? IddsSpacing.s4
        : screen.width < IddsBreakpoint.sm
            ? IddsSpacing.s8
            : IddsSpacing.s16;
    final bool full = size == IddsModalSize.full;
    final double maxWidth = screen.width - 2 * margin;
    final double width = full ? maxWidth : math.min(size.width, maxWidth);
    final double maxHeight = full ? screen.height - 2 * margin : screen.height * 0.9;
    final BorderSide divider = BorderSide(color: c.strokePrimary);

    final Widget dialog = Container(
      width: width,
      height: full ? maxHeight : null,
      constraints: BoxConstraints(maxHeight: math.max(0, maxHeight - viewInsets.bottom)),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(IddsRadius.xl),
        border: Border.all(color: c.strokePrimary),
        boxShadow: IddsShadow.xl,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IddsRadius.xl - 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (showHeader && (title != null || showCloseButton))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s24, vertical: IddsSpacing.s16),
                decoration: BoxDecoration(border: Border(bottom: divider)),
                child: Row(
                  spacing: IddsSpacing.s16,
                  children: <Widget>[
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: DefaultTextStyle(
                          style: theme.textStyle(
                            fontSize: IddsFontSize.lg,
                            lineHeight: IddsLineHeight.base,
                            fontWeight: IddsFontWeight.semibold,
                            color: c.contentPrimary,
                          ),
                          child: title ?? const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    if (showCloseButton) IddsCloseButton(label: closeLabel, size: 24, onTap: close),
                  ],
                ),
              ),
            Flexible(
              fit: full ? FlexFit.tight : FlexFit.loose,
              child: SingleChildScrollView(
                padding: bodyPadding ?? const EdgeInsets.symmetric(horizontal: IddsSpacing.s24, vertical: IddsSpacing.s16),
                child: DefaultTextStyle(
                  style: theme.textStyle(
                    fontSize: IddsFontSize.sm,
                    lineHeight: IddsLineHeight.sm,
                    color: c.contentPrimary,
                  ),
                  child: child,
                ),
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(IddsSpacing.s24, IddsSpacing.s16, IddsSpacing.s24, IddsSpacing.s24),
                decoration: BoxDecoration(border: Border(top: divider)),
                child: Wrap(
                  alignment: switch (actionsAlignment) {
                    MainAxisAlignment.start => WrapAlignment.start,
                    MainAxisAlignment.center => WrapAlignment.center,
                    MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
                    MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
                    MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
                    MainAxisAlignment.end => WrapAlignment.end,
                  },
                  spacing: IddsSpacing.s16,
                  runSpacing: IddsSpacing.s8,
                  children: actions!,
                ),
              ),
          ],
        ),
      ),
    );

    return IddsDismissOnEscape(
      onDismiss: close,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(margin).add(EdgeInsets.only(bottom: viewInsets.bottom)),
          child: Center(child: Semantics(namesRoute: true, explicitChildNodes: true, child: dialog)),
        ),
      ),
    );
  }
}

/// Menutup dengan tombol Esc. Fokus otomatis dipindahkan ke dalam [child]
/// agar Esc dan Tab bekerja tanpa harus mengklik lebih dulu. Internal.
class IddsDismissOnEscape extends StatelessWidget {
  /// Membuat pembungkus.
  const IddsDismissOnEscape({super.key, required this.onDismiss, required this.child});

  /// Dipanggil saat Esc ditekan.
  final VoidCallback onDismiss;

  /// Isi.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): onDismiss,
      },
      child: Focus(autofocus: true, skipTraversal: true, child: child),
    );
  }
}

/// Tombol X untuk menutup modal/drawer. Internal.
class IddsCloseButton extends StatelessWidget {
  /// Membuat tombol tutup.
  const IddsCloseButton({super.key, required this.label, required this.onTap, this.size = 20, this.boxSize});

  /// Label pembaca layar.
  final String label;

  /// Dipanggil saat ditekan.
  final VoidCallback onTap;

  /// Ukuran ikon.
  final double size;

  /// Ukuran area tekan (bawaan: ukuran ikon).
  final double? boxSize;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(IddsRadius.base),
          rings: <(double, Color)>[(2.0, c.primary.shade500)],
          child: Container(
            width: boxSize ?? size,
            height: boxSize ?? size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // CSS drawer: hover neutral-100; dark mode memakai latar tersier.
              color: boxSize != null && (state.hovered || state.focused) ? c.backgroundTertiary : null,
              borderRadius: BorderRadius.circular(IddsRadius.base),
            ),
            child: IddsIcon(
              IddsIcons.x,
              size: size,
              color: state.hovered ? c.contentPrimary : c.contentSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
