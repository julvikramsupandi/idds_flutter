import 'package:flutter/services.dart' show LogicalKeyboardKey, MouseCursor, SystemMouseCursors;
import 'package:flutter/widgets.dart';

import 'idds_theme.dart';
import 'idds_theme_data.dart';

/// State interaksi yang diteruskan ke builder [IddsInteractive].
@immutable
class IddsInteractionState {
  /// Membuat state.
  const IddsInteractionState({
    required this.enabled,
    this.hovered = false,
    this.focused = false,
    this.pressed = false,
  });

  /// Komponen bisa dipakai.
  final bool enabled;

  /// Kursor berada di atas komponen.
  final bool hovered;

  /// Komponen mendapat fokus keyboard (cincin fokus perlu ditampilkan).
  final bool focused;

  /// Komponen sedang ditekan.
  final bool pressed;
}

/// Kerangka interaksi bersama untuk komponen IDDS: hover, fokus keyboard,
/// tekan, aktivasi lewat Enter/Space, dan kursor mouse.
///
/// Widget ini tidak menambahkan semantics; komponen pemakai yang
/// bertanggung jawab memberi [Semantics] yang sesuai.
class IddsInteractive extends StatefulWidget {
  /// Membuat area interaktif.
  const IddsInteractive({
    super.key,
    required this.onTap,
    required this.builder,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.canRequestFocus = true,
  });

  /// Dipanggil saat ditekan atau diaktifkan dengan keyboard. `null` berarti
  /// nonaktif.
  final VoidCallback? onTap;

  /// Membangun tampilan berdasarkan state interaksi.
  final Widget Function(BuildContext context, IddsInteractionState state) builder;

  /// Focus node opsional.
  final FocusNode? focusNode;

  /// Langsung mendapat fokus.
  final bool autofocus;

  /// Kursor saat aktif. Bawaan: [SystemMouseCursors.click].
  final MouseCursor? mouseCursor;

  /// Apakah bisa menerima fokus keyboard.
  final bool canRequestFocus;

  @override
  State<IddsInteractive> createState() => _IddsInteractiveState();
}

class _IddsInteractiveState extends State<IddsInteractive> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  static final Map<ShortcutActivator, Intent> _shortcuts = <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
  };

  late final Map<Type, Action<Intent>> _actions = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
  };

  bool get _enabled => widget.onTap != null;

  void _activate() {
    if (_enabled) widget.onTap!();
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(IddsInteractive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled) {
      _hovered = false;
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = _enabled;
    return FocusableActionDetector(
      enabled: enabled && widget.canRequestFocus,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      shortcuts: _shortcuts,
      actions: _actions,
      mouseCursor: enabled ? (widget.mouseCursor ?? SystemMouseCursors.click) : SystemMouseCursors.forbidden,
      onShowHoverHighlight: (bool value) => setState(() => _hovered = value),
      onShowFocusHighlight: (bool value) => setState(() => _focused = value),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: enabled ? _activate : null,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        child: widget.builder(
          context,
          IddsInteractionState(
            enabled: enabled,
            hovered: enabled && _hovered,
            focused: enabled && _focused,
            pressed: enabled && _pressed,
          ),
        ),
      ),
    );
  }
}

/// Apakah komponen sebaiknya memakai ukuran kecil: lebar layar di bawah
/// [breakpoint] dan [IddsThemeData.compactOnSmallScreens] aktif.
bool iddsIsCompact(BuildContext context, double breakpoint) {
  final IddsThemeData theme = IddsTheme.of(context);
  if (!theme.compactOnSmallScreens) return false;
  final double? width = MediaQuery.maybeSizeOf(context)?.width;
  return width != null && width < breakpoint;
}

/// Lebar layar saat ini, atau tak hingga bila tidak ada [MediaQuery].
double iddsScreenWidth(BuildContext context) => MediaQuery.maybeSizeOf(context)?.width ?? double.infinity;

/// Menggambar cincin di dalam tepi [child], seperti `box-shadow: inset 0 0 0 Npx`
/// di CSS. [rings] diurutkan dari luar ke dalam: lebar dan warnanya.
class IddsInsetRing extends StatelessWidget {
  /// Membuat cincin dalam.
  const IddsInsetRing({
    super.key,
    required this.child,
    required this.rings,
    required this.borderRadius,
    this.visible = true,
    this.inset = 0,
  });

  /// Konten di bawah cincin.
  final Widget child;

  /// Pasangan (lebar, warna), dari luar ke dalam.
  final List<(double, Color)> rings;

  /// Radius sudut luar.
  final BorderRadius borderRadius;

  /// Tampilkan cincin.
  final bool visible;

  /// Jarak cincin dari tepi luar (mis. tebal border yang sudah ada).
  final double inset;

  @override
  Widget build(BuildContext context) {
    // CustomPaint selalu ada, hanya painter-nya yang berganti. Bila [child]
    // dibungkus/dilepas bergantian, Flutter membuat ulang seluruh subtree
    // (mis. TextField kehilangan koneksi keyboard dan fokusnya).
    return CustomPaint(
      foregroundPainter: visible ? _InsetRingPainter(rings, borderRadius, inset) : null,
      child: child,
    );
  }
}

class _InsetRingPainter extends CustomPainter {
  _InsetRingPainter(this.rings, this.borderRadius, this.inset);

  final List<(double, Color)> rings;
  final BorderRadius borderRadius;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    double offset = inset;
    for (final (double width, Color color) in rings) {
      final RRect outer = borderRadius.toRRect(Offset.zero & size).deflate(offset);
      final RRect inner = outer.deflate(width);
      canvas.drawDRRect(outer, inner, Paint()..color = color);
      offset += width;
    }
  }

  @override
  bool shouldRepaint(_InsetRingPainter old) =>
      old.rings.length != rings.length ||
      old.borderRadius != borderRadius ||
      old.inset != inset ||
      !_sameRings(old.rings, rings);

  static bool _sameRings(List<(double, Color)> a, List<(double, Color)> b) {
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
