import 'dart:async' show scheduleMicrotask;
import 'dart:math' as math;

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../tokens/idds_colors.g.dart';
import '../tokens/idds_dimension_tokens.g.dart';
import 'idds_theme.dart';

/// Posisi panel [IddsPopover] terhadap anchor-nya.
enum IddsPopoverPlacement {
  /// Di bawah, rata kiri (bawaan).
  bottomStart,

  /// Di bawah, rata kanan.
  bottomEnd,

  /// Di atas, rata kiri.
  topStart,

  /// Di atas, rata kanan.
  topEnd;

  bool get _isTop => this == topStart || this == topEnd;

  bool get _isEnd => this == bottomEnd || this == topEnd;

  IddsPopoverPlacement get _flipped => switch (this) {
        bottomStart => topStart,
        bottomEnd => topEnd,
        topStart => bottomStart,
        topEnd => bottomEnd,
      };
}

/// Panel melayang yang menempel pada widget anchor, dasar untuk Dropdown,
/// menu aksi, dan Date Picker.
///
/// - Panel otomatis pindah ke sisi seberang bila ruang di sisi yang diminta
///   tidak cukup, dan tingginya dibatasi agar tetap di dalam layar.
/// - Menekan di luar anchor dan panel, atau tombol Esc, memanggil
///   [onDismiss].
/// - Muncul dan hilang dengan animasi fade + geser singkat.
///
/// Status buka/tutup dikendalikan oleh pemanggil lewat [open].
///
/// Membutuhkan [Overlay] di atasnya (disediakan oleh `MaterialApp`,
/// `CupertinoApp`, atau `WidgetsApp` yang memiliki Navigator).
class IddsPopover extends StatefulWidget {
  /// Membuat popover.
  const IddsPopover({
    super.key,
    required this.open,
    required this.onDismiss,
    required this.panelBuilder,
    required this.child,
    this.placement = IddsPopoverPlacement.bottomStart,
    this.gap = IddsSpacing.s4,
    this.matchAnchorWidth = true,
    this.minWidth,
    this.width,
    this.maxHeight = 600,
  });

  /// Apakah panel ditampilkan.
  final bool open;

  /// Dipanggil saat pengguna menekan di luar atau menekan Esc.
  final VoidCallback onDismiss;

  /// Membangun isi panel.
  final WidgetBuilder panelBuilder;

  /// Widget anchor.
  final Widget child;

  /// Posisi yang diinginkan.
  final IddsPopoverPlacement placement;

  /// Jarak antara anchor dan panel.
  final double gap;

  /// Lebar panel minimal selebar anchor.
  final bool matchAnchorWidth;

  /// Lebar minimal panel.
  final double? minWidth;

  /// Lebar tetap panel. Bila `null`, panel selebar isinya.
  final double? width;

  /// Tinggi maksimal panel (tetap dibatasi ruang di layar).
  final double maxHeight;

  @override
  State<IddsPopover> createState() => _IddsPopoverState();
}

class _IddsPopoverState extends State<IddsPopover> with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final Object _tapGroup = Object();
  final GlobalKey _panelKey = GlobalKey();

  /// Induk fokus pemicu dan panel, untuk melepas fokus saat pengguna
  /// mengeklik di luar.
  final FocusNode _focus = FocusNode(canRequestFocus: false, skipTraversal: true, debugLabel: 'IddsPopover');

  /// Geseran horizontal agar panel tidak keluar dari tepi layar.
  double _dx = 0;
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: IddsDuration.base,
  );

  @override
  void initState() {
    super.initState();
    if (widget.open) _show();
  }

  @override
  void didUpdateWidget(IddsPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.open != oldWidget.open) {
      widget.open ? _show() : _hide();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _show() {
    // Ditunda ke akhir frame: OverlayPortal tidak boleh diubah selama build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.open) return;
      _portal.show();
      _animation.forward();
    });
  }

  Future<void> _hide() async {
    await _animation.reverse();
    if (mounted && !widget.open) _portal.hide();
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    // Bergantung pada MediaQuery agar posisi dihitung ulang saat ukuran layar berubah.
    MediaQuery.maybeSizeOf(overlayContext);
    final RenderBox? anchor = context.findRenderObject() as RenderBox?;
    final RenderBox? overlayBox = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (anchor == null || !anchor.hasSize || overlayBox == null) return const SizedBox.shrink();

    final Offset topLeft = anchor.localToGlobal(Offset.zero, ancestor: overlayBox);
    final Rect anchorRect = topLeft & anchor.size;
    final Size screen = overlayBox.size;
    const double margin = IddsSpacing.s8;
    final double spaceBelow = screen.height - anchorRect.bottom - widget.gap - margin;
    final double spaceAbove = anchorRect.top - widget.gap - margin;

    // Pindah ke sisi seberang bila sisi yang diminta sempit (< 200px atau
    // kurang dari tinggi maksimal) dan sisi seberang lebih lega.
    IddsPopoverPlacement placement = widget.placement;
    final double wanted = math.min(widget.maxHeight, 200);
    final double primary = placement._isTop ? spaceAbove : spaceBelow;
    final double secondary = placement._isTop ? spaceBelow : spaceAbove;
    if (primary < wanted && secondary > primary) placement = placement._flipped;
    final bool top = placement._isTop;
    final bool end = placement._isEnd;
    final double available = math.max(0, top ? spaceAbove : spaceBelow);

    final double minWidth = math.max(widget.minWidth ?? 0, widget.matchAnchorWidth ? anchorRect.width : 0);
    final double maxWidth = screen.width - 2 * margin;

    Widget panel = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: math.min(minWidth, maxWidth),
        maxWidth: widget.width ?? maxWidth,
        maxHeight: math.min(widget.maxHeight, available),
      ),
      child: widget.width == null ? IntrinsicWidth(child: widget.panelBuilder(overlayContext)) : SizedBox(width: widget.width, child: widget.panelBuilder(overlayContext)),
    );

    panel = KeyedSubtree(key: _panelKey, child: panel);
    WidgetsBinding.instance.addPostFrameCallback((_) => _clampHorizontally(margin));

    final Animation<double> curved = CurvedAnimation(parent: _animation, curve: Curves.easeOut);
    panel = FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, top ? 0.03 : -0.03), end: Offset.zero).animate(curved),
        child: panel,
      ),
    );

    return Stack(
      children: <Widget>[
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: top ? (end ? Alignment.topRight : Alignment.topLeft) : (end ? Alignment.bottomRight : Alignment.bottomLeft),
          followerAnchor: top ? (end ? Alignment.bottomRight : Alignment.bottomLeft) : (end ? Alignment.topRight : Alignment.topLeft),
          offset: Offset(_dx, top ? -widget.gap : widget.gap),
          child: TapRegion(
            groupId: _tapGroup,
            child: _DismissOnEscape(enabled: true, onDismiss: widget.onDismiss, child: panel),
          ),
        ),
      ],
    );
  }

  /// Mengukur panel setelah tata letak; bila keluar dari tepi kiri/kanan
  /// layar, panel digeser (panel masih transparan saat muncul, jadi tidak
  /// terlihat melompat).
  void _clampHorizontally(double margin) {
    if (!mounted || !widget.open) return;
    final RenderBox? box = _panelKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? overlayBox = Overlay.maybeOf(context)?.context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || overlayBox == null) return;
    final double left = box.localToGlobal(Offset.zero, ancestor: overlayBox).dx - _dx;
    final double width = box.size.width;
    final double screen = overlayBox.size.width;
    double dx = 0;
    if (left + width > screen - margin) dx = screen - margin - width - left;
    if (left + dx < margin) dx = margin - left;
    if ((dx - _dx).abs() > 0.5) setState(() => _dx = dx);
  }

  /// Klik di luar pemicu dan panel: tutup panel lalu lepas fokus, seperti
  /// browser. Tanpa ini pemicu tetap berfokus (garis aktif) setelah panel
  /// ditutup, karena komponen mengembalikan fokus ke pemicu saat menutup.
  void _handleTapOutside(PointerDownEvent event) {
    final bool hadFocus = _focus.hasFocus;
    if (widget.open) widget.onDismiss();
    if (!hadFocus && !widget.open) return;
    // Ditunda sampai perpindahan fokus dari onDismiss diterapkan.
    scheduleMicrotask(() {
      if (mounted && _focus.hasFocus) _focus.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: TapRegion(
        groupId: _tapGroup,
        onTapOutside: _handleTapOutside,
        child: Focus(
          focusNode: _focus,
          includeSemantics: false,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: _buildOverlay,
            // Selalu dibungkus (aksi hanya aktif saat terbuka) agar subtree
            // anchor tidak dibuat ulang ketika panel dibuka/ditutup.
            child: _DismissOnEscape(enabled: widget.open, onDismiss: widget.onDismiss, child: widget.child),
          ),
        ),
      ),
    );
  }
}

class _DismissOnEscape extends StatelessWidget {
  const _DismissOnEscape({required this.enabled, required this.onDismiss, required this.child});

  final bool enabled;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: _DismissAction(enabled, onDismiss),
        },
        child: child,
      ),
    );
  }
}

/// Kotak panel standar IDDS untuk dropdown: latar, garis tepi, sudut 8px,
/// dan bayangan.
class IddsPopoverSurface extends StatelessWidget {
  /// Membuat permukaan panel.
  const IddsPopoverSurface({super.key, required this.child, this.shadow, this.radius = IddsRadius.lg, this.padding});

  /// Isi panel.
  final Widget child;

  /// Radius sudut.
  final double radius;

  /// Jarak isi dari tepi.
  final EdgeInsetsGeometry? padding;

  /// Bayangan. Bawaan: bayangan panel Select Dropdown IDDS.
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: c.strokePrimary),
        boxShadow: shadow ??
            const <BoxShadow>[
              BoxShadow(color: Color(0x1A000000), offset: Offset(0, 10), blurRadius: 25, spreadRadius: -5),
              BoxShadow(color: Color(0x0A000000), offset: Offset(0, 10), blurRadius: 10, spreadRadius: -5),
            ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(radius - 1), child: child),
    );
  }
}

/// Saat nonaktif, Esc diteruskan ke widget di atasnya (mis. dialog).
class _DismissAction extends Action<DismissIntent> {
  _DismissAction(this.enabled, this.onDismiss);

  final bool enabled;
  final VoidCallback onDismiss;

  @override
  bool isEnabled(DismissIntent intent) => enabled;

  @override
  void invoke(DismissIntent intent) => onDismiss();
}
