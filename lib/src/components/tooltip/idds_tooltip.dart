import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Gaya [IddsTooltip].
enum IddsTooltipVariant {
  /// Gelembung gelap kecil berisi teks (bawaan).
  basic,

  /// Kartu terang berisi judul, keterangan, dan tombol.
  light,

  /// Kartu gelap.
  dark,

  /// Kartu terang dengan gambar di atas.
  media,
}

/// Posisi [IddsTooltip] terhadap widget-nya.
enum IddsTooltipPlacement {
  /// Di atas, di tengah (bawaan).
  top,

  /// Di atas, rata kiri.
  topStart,

  /// Di atas, rata kanan.
  topEnd,

  /// Di bawah, di tengah.
  bottom,

  /// Di bawah, rata kiri.
  bottomStart,

  /// Di bawah, rata kanan.
  bottomEnd,

  /// Di kiri, di tengah.
  left,

  /// Di kiri, rata atas.
  leftStart,

  /// Di kiri, rata bawah.
  leftEnd,

  /// Di kanan, di tengah.
  right,

  /// Di kanan, rata atas.
  rightStart,

  /// Di kanan, rata bawah.
  rightEnd;

  AxisDirection get _side => switch (this) {
        top || topStart || topEnd => AxisDirection.up,
        bottom || bottomStart || bottomEnd => AxisDirection.down,
        left || leftStart || leftEnd => AxisDirection.left,
        right || rightStart || rightEnd => AxisDirection.right,
      };

  /// -1 awal, 0 tengah, 1 akhir.
  int get _align => switch (this) {
        topStart || bottomStart || leftStart || rightStart => -1,
        topEnd || bottomEnd || leftEnd || rightEnd => 1,
        _ => 0,
      };
}

/// Keterangan yang muncul saat widget disorot mouse, difokuskan dengan
/// keyboard, atau ditekan lama di layar sentuh.
///
/// ```dart
/// IddsTooltip(
///   message: 'Unduh dokumen',
///   child: IddsButton(onPressed: _download, child: const Text('Unduh')),
/// )
///
/// IddsTooltip(
///   variant: IddsTooltipVariant.light,
///   title: 'Fitur baru',
///   description: 'Sekarang Anda bisa mengekspor laporan ke PDF.',
///   onNext: _nextTourStep,
///   onClose: () {},
///   child: const Icon(...),
/// )
/// ```
class IddsTooltip extends StatefulWidget {
  /// Membuat tooltip.
  const IddsTooltip({
    super.key,
    required this.child,
    this.message,
    this.title,
    this.description,
    this.image,
    this.content,
    this.variant = IddsTooltipVariant.basic,
    this.placement = IddsTooltipPlacement.top,
    this.showArrow = true,
    this.onClose,
    this.onNext,
    this.closeLabel = 'Tutup',
    this.nextLabel = 'Lanjut',
    this.touchDuration = const Duration(milliseconds: 1500),
  }) : assert(variant != IddsTooltipVariant.basic || message != null || title != null || content != null);

  /// Widget yang diberi tooltip.
  final Widget child;

  /// Teks gelembung untuk gaya [IddsTooltipVariant.basic].
  final String? message;

  /// Judul kartu (gaya light/dark/media). Untuk gaya basic dipakai bila
  /// [message] kosong.
  final String? title;

  /// Keterangan kartu.
  final String? description;

  /// Gambar di atas kartu (gaya media), tinggi 200px.
  final Widget? image;

  /// Isi tambahan di kartu, atau isi gelembung kustom untuk gaya basic.
  final Widget? content;

  /// Gaya.
  final IddsTooltipVariant variant;

  /// Posisi.
  final IddsTooltipPlacement placement;

  /// Tampilkan segitiga penunjuk.
  final bool showArrow;

  /// Kartu: tampilkan tombol X dan "Tutup". Tooltip disembunyikan sampai
  /// disorot lagi.
  final VoidCallback? onClose;

  /// Kartu: tampilkan tombol "Lanjut".
  final VoidCallback? onNext;

  /// Teks tombol tutup.
  final String closeLabel;

  /// Teks tombol lanjut.
  final String nextLabel;

  /// Lama tooltip tampil setelah tekan lama di layar sentuh.
  final Duration touchDuration;

  @override
  State<IddsTooltip> createState() => _IddsTooltipState();
}

class _IddsTooltipState extends State<IddsTooltip> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  late final AnimationController _fade = AnimationController(vsync: this, duration: IddsDuration.base);
  Timer? _hideTimer;
  bool _hovering = false;
  bool _focused = false;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _fade.dispose();
    super.dispose();
  }

  bool get _interactive => widget.variant != IddsTooltipVariant.basic;

  void _show() {
    _hideTimer?.cancel();
    if (!mounted) return;
    if (!_portal.isShowing) _portal.show();
    _fade.forward();
  }

  void _scheduleHide([Duration delay = const Duration(milliseconds: 100)]) {
    _hideTimer?.cancel();
    _hideTimer = Timer(delay, _hideNow);
  }

  void _hideNow() {
    if (!mounted || _hovering || _focused) return;
    _fade.reverse().whenComplete(() {
      if (mounted && _fade.isDismissed) _portal.hide();
    });
  }

  void _forceHide() {
    _hovering = false;
    _focused = false;
    _hideTimer?.cancel();
    _hideNow();
  }

  void _enter() {
    _hovering = true;
    _show();
  }

  void _exit() {
    _hovering = false;
    _scheduleHide();
  }

  Widget _buildOverlay(BuildContext context) {
    final IddsTooltipPlacement p = widget.placement;
    final AxisDirection side = p._side;
    final int align = p._align;

    Alignment cross(int a, {required bool forTarget}) {
      // Titik di tepi target/tooltip yang dipertemukan.
      final double t = a.toDouble();
      return switch (side) {
        AxisDirection.up => Alignment(t, forTarget ? -1 : 1),
        AxisDirection.down => Alignment(t, forTarget ? 1 : -1),
        AxisDirection.left => Alignment(forTarget ? -1 : 1, t),
        AxisDirection.right => Alignment(forTarget ? 1 : -1, t),
      };
    }

    const double gap = 8;
    final Offset offset = switch (side) {
      AxisDirection.up => const Offset(0, -gap),
      AxisDirection.down => const Offset(0, gap),
      AxisDirection.left => const Offset(-gap, 0),
      AxisDirection.right => const Offset(gap, 0),
    };

    final _TooltipBody body = _TooltipBody(
      widget: widget,
      side: side,
      align: align,
      onClose: widget.onClose == null
          ? null
          : () {
              _forceHide();
              widget.onClose!();
            },
      onNext: widget.onNext == null
          ? null
          : () {
              _forceHide();
              widget.onNext!();
            },
    );

    return Stack(
      children: <Widget>[
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: cross(align, forTarget: true),
          followerAnchor: cross(align, forTarget: false),
          offset: offset,
          child: FadeTransition(
            opacity: _fade,
            // Gelembung biasa tidak menghalangi ketukan; kartu bisa disorot
            // dan ditekan tombolnya.
            child: _interactive
                ? MouseRegion(onEnter: (_) => _enter(), onExit: (_) => _exit(), child: body)
                : IgnorePointer(child: body),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? semanticsText = widget.message ?? widget.title;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: Semantics(
          tooltip: semanticsText,
          child: MouseRegion(
            onEnter: (_) => _enter(),
            onExit: (_) => _exit(),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: (bool focused) {
                // Fokus keyboard pada widget di dalamnya.
                _focused = focused && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
                _focused ? _show() : _scheduleHide();
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                excludeFromSemantics: true,
                onLongPress: () {
                  _show();
                  _scheduleHide(widget.touchDuration);
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipBody extends StatelessWidget {
  const _TooltipBody({
    required this.widget,
    required this.side,
    required this.align,
    required this.onClose,
    required this.onNext,
  });

  final IddsTooltip widget;
  final AxisDirection side;
  final int align;
  final VoidCallback? onClose;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final IddsTooltipVariant v = widget.variant;

    // `--ina-black`/`--ina-white` bertukar di dark mode, jadi gelembung
    // selalu kontras dengan halaman.
    final Color bubbleColor = switch (v) {
      IddsTooltipVariant.basic => c.black,
      IddsTooltipVariant.dark => c.contentPrimary,
      _ => c.white,
    };

    Widget card;
    if (v == IddsTooltipVariant.basic) {
      card = Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12, vertical: IddsSpacing.s8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(IddsRadius.md),
          boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x26000000), offset: Offset(0, 2), blurRadius: 8)],
        ),
        child: widget.content ??
            Text(
              widget.message ?? widget.title ?? '',
              textAlign: TextAlign.center,
              style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.white),
            ),
      );
    } else {
      final bool dark = v == IddsTooltipVariant.dark;
      final Color titleColor = dark ? c.white : c.contentPrimary;
      final Color descColor = dark ? c.white.withValues(alpha: 0.7) : c.contentSecondary;
      card = Container(
        width: 320,
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(IddsRadius.lg),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x140A0D12), offset: Offset(0, 12), blurRadius: 16, spreadRadius: -4),
            BoxShadow(color: Color(0x080A0D12), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(IddsRadius.lg),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (v == IddsTooltipVariant.media && widget.image != null)
                    Container(height: 200, color: c.backgroundTertiary, child: widget.image),
                  Padding(
                    padding: const EdgeInsets.all(IddsSpacing.s16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: IddsSpacing.s12,
                      children: <Widget>[
                        if (widget.title != null)
                          Padding(
                            // Ruang untuk tombol X.
                            padding: EdgeInsets.only(right: onClose != null && widget.image == null ? 28 : 0),
                            child: Text(
                              widget.title!,
                              style: theme.textStyle(
                                fontSize: IddsFontSize.base,
                                lineHeight: IddsLineHeight.base,
                                fontWeight: IddsFontWeight.semibold,
                                color: titleColor,
                              ),
                            ),
                          ),
                        if (widget.description != null)
                          Text(
                            widget.description!,
                            style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: descColor),
                          ),
                        if (widget.content != null) widget.content!,
                        if (onClose != null || onNext != null)
                          Padding(
                            padding: const EdgeInsets.only(top: IddsSpacing.s8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              spacing: IddsSpacing.s8,
                              children: <Widget>[
                                if (onClose != null)
                                  _CardAction(label: widget.closeLabel, primary: false, dark: dark, onTap: onClose!),
                                if (onNext != null)
                                  _CardAction(label: widget.nextLabel, primary: true, dark: dark, onTap: onNext!),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (onClose != null)
                Positioned(
                  top: IddsSpacing.s12,
                  right: IddsSpacing.s12,
                  child: _RoundClose(label: widget.closeLabel, dark: dark, onTap: onClose!),
                ),
            ],
          ),
        ),
      );
    }

    if (!widget.showArrow) return Semantics(container: true, child: card);

    final Widget arrow = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (side == AxisDirection.up || side == AxisDirection.down) && align != 0 ? 12 : 0,
        vertical: (side == AxisDirection.left || side == AxisDirection.right) && align != 0 ? 12 : 0,
      ),
      child: CustomPaint(
        size: side == AxisDirection.up || side == AxisDirection.down ? const Size(10, 5) : const Size(5, 10),
        painter: _ArrowPainter(color: bubbleColor, side: side),
      ),
    );
    final CrossAxisAlignment crossAlign = switch (align) {
      -1 => CrossAxisAlignment.start,
      1 => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.center,
    };

    return Semantics(
      container: true,
      child: switch (side) {
        AxisDirection.up => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: crossAlign, children: <Widget>[card, arrow]),
        AxisDirection.down => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: crossAlign, children: <Widget>[arrow, card]),
        AxisDirection.left => Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: crossAlign, children: <Widget>[card, arrow]),
        AxisDirection.right => Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: crossAlign, children: <Widget>[arrow, card]),
      },
    );
  }
}

/// Segitiga penunjuk yang mengarah ke widget.
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color, required this.side});

  final Color color;
  final AxisDirection side;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Path path = switch (side) {
      // Tooltip di atas: ujung segitiga ke bawah.
      AxisDirection.up => Path()
        ..moveTo(0, 0)
        ..lineTo(w, 0)
        ..lineTo(w / 2, h),
      AxisDirection.down => Path()
        ..moveTo(0, h)
        ..lineTo(w, h)
        ..lineTo(w / 2, 0),
      AxisDirection.left => Path()
        ..moveTo(0, 0)
        ..lineTo(0, h)
        ..lineTo(w, h / 2),
      AxisDirection.right => Path()
        ..moveTo(w, 0)
        ..lineTo(w, h)
        ..lineTo(0, h / 2),
    };
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => oldDelegate.color != color || oldDelegate.side != side;
}

class _CardAction extends StatelessWidget {
  const _CardAction({required this.label, required this.primary, required this.dark, required this.onTap});

  final String label;
  final bool primary;
  final bool dark;
  final VoidCallback onTap;

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
        builder: (BuildContext context, IddsInteractionState state) {
          final Color background;
          final Color foreground;
          Color? border;
          if (primary) {
            // CSS: primary-primary, hover primary-700; teks memakai onPrimary
            // agar terbaca di semua brand.
            background = state.hovered && !theme.isDark ? c.primary.shade700 : c.primaryMain;
            foreground = c.onPrimary;
          } else if (dark) {
            background = c.white.withValues(alpha: state.hovered ? 0.2 : 0.1);
            foreground = c.white;
            border = c.white.withValues(alpha: 0.2);
          } else {
            background = state.hovered ? c.backgroundTertiary : c.white;
            foreground = c.contentPrimary;
            border = c.strokePrimary;
          }
          return IddsInsetRing(
            visible: state.focused,
            borderRadius: BorderRadius.circular(IddsRadius.md),
            rings: <(double, Color)>[(2.0, foreground)],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: IddsSpacing.s16, vertical: IddsSpacing.s8 - (border == null ? 0 : 1)),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(IddsRadius.md),
                border: border == null ? null : Border.all(color: border),
              ),
              child: Text(
                label,
                style: theme.textStyle(
                  fontSize: IddsFontSize.sm,
                  lineHeight: IddsLineHeight.sm,
                  fontWeight: IddsFontWeight.medium,
                  color: foreground,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoundClose extends StatelessWidget {
  const _RoundClose({required this.label, required this.dark, required this.onTap});

  final String label;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final Color tint = dark ? c.white : c.contentPrimary;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(12),
          rings: <(double, Color)>[(2.0, tint)],
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tint.withValues(alpha: state.hovered ? 0.2 : 0.08),
            ),
            child: IddsIcon(IddsIcons.x, size: 16, color: tint),
          ),
        ),
      ),
    );
  }
}
