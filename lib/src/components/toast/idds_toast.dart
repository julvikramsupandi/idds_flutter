import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Jenis [showIddsToast]; menentukan warna dan ikon.
enum IddsToastState {
  /// Informasi biasa (ikon info).
  normal,

  /// Kesalahan atau peringatan (merah).
  destructive,

  /// Berhasil (hijau).
  positive,
}

/// Gaya [showIddsToast].
enum IddsToastStyle {
  /// Latar penuh berwarna (bawaan).
  solid,

  /// Latar muda dengan garis tepi.
  outline,
}

/// Posisi tumpukan toast di layar.
enum IddsToastPosition {
  /// Kanan atas (bawaan).
  topRight,

  /// Kiri atas.
  topLeft,

  /// Tengah atas.
  topCenter,

  /// Kanan bawah.
  bottomRight,

  /// Kiri bawah.
  bottomLeft,

  /// Tengah bawah.
  bottomCenter,

  /// Tengah kiri.
  centerLeft,

  /// Tengah kanan.
  centerRight;

  bool get _isBottom => this == bottomRight || this == bottomLeft || this == bottomCenter;
}

/// Pengendali toast yang sedang tampil.
class IddsToastController {
  IddsToastController._(this._entry);

  final _ToastEntry _entry;

  /// Toast masih tampil.
  bool get isOpen => !_entry.closing && _entry.manager._entries.contains(_entry);

  /// Menutup toast.
  void close() => _entry.manager._close(_entry);
}

/// Menampilkan toast (notifikasi singkat) di atas semua halaman.
///
/// Toast tertutup otomatis setelah [duration] (bawaan 5 detik; `null` =
/// tetap tampil sampai ditutup), atau saat tombol X ditekan. Beberapa toast
/// di posisi yang sama ditumpuk.
///
/// ```dart
/// showIddsToast(
///   context: context,
///   title: const Text('Data berhasil disimpan'),
///   state: IddsToastState.positive,
/// );
/// ```
IddsToastController showIddsToast({
  required BuildContext context,
  required Widget title,
  Widget? description,
  IddsToastState state = IddsToastState.normal,
  IddsToastStyle style = IddsToastStyle.solid,
  IddsToastPosition position = IddsToastPosition.topRight,
  Duration? duration = const Duration(seconds: 5),
  Widget? action,
  VoidCallback? onClose,
  String closeLabel = 'Tutup notifikasi',
}) {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final _ToastManager manager = _ToastManager.of(overlay);
  final _ToastEntry entry = _ToastEntry(
    manager: manager,
    theme: IddsTheme.of(context),
    title: title,
    description: description,
    state: state,
    style: style,
    position: position,
    action: action,
    onClose: onClose,
    closeLabel: closeLabel,
  );
  manager._add(entry, duration);
  return IddsToastController._(entry);
}

/// Menutup semua toast yang sedang tampil.
void dismissAllIddsToasts(BuildContext context) {
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final _ToastManager? manager = _ToastManager._managers[overlay];
  if (manager == null) return;
  for (final _ToastEntry e in List<_ToastEntry>.of(manager._entries)) {
    manager._close(e);
  }
}

class _ToastEntry {
  _ToastEntry({
    required this.manager,
    required this.theme,
    required this.title,
    required this.description,
    required this.state,
    required this.style,
    required this.position,
    required this.action,
    required this.onClose,
    required this.closeLabel,
  });

  final _ToastManager manager;
  final IddsThemeData theme;
  final Widget title;
  final Widget? description;
  final IddsToastState state;
  final IddsToastStyle style;
  final IddsToastPosition position;
  final Widget? action;
  final VoidCallback? onClose;
  final String closeLabel;
  final Key key = UniqueKey();
  Timer? timer;
  bool closing = false;
}

/// Satu [OverlayEntry] per [Overlay] yang menampung semua toast.
class _ToastManager {
  _ToastManager(this.overlay);

  static final Expando<_ToastManager> _managers = Expando<_ToastManager>('IddsToast');

  static _ToastManager of(OverlayState overlay) => _managers[overlay] ??= _ToastManager(overlay);

  final OverlayState overlay;
  final List<_ToastEntry> _entries = <_ToastEntry>[];
  OverlayEntry? _overlayEntry;

  void _add(_ToastEntry entry, Duration? duration) {
    _entries.add(entry);
    if (duration != null) entry.timer = Timer(duration, () => _close(entry));
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(builder: _build);
      overlay.insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  /// Memulai animasi keluar; entri dihapus oleh [_remove].
  void _close(_ToastEntry entry) {
    if (entry.closing || !_entries.contains(entry)) return;
    entry.closing = true;
    entry.timer?.cancel();
    _overlayEntry?.markNeedsBuild();
  }

  void _remove(_ToastEntry entry) {
    if (!_entries.remove(entry)) return;
    entry.onClose?.call();
    if (_entries.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry?.markNeedsBuild();
    }
  }

  Widget _build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final EdgeInsets safe = MediaQuery.paddingOf(context);
    // CSS: wadah 16px dari tepi layar, padding 8px, jarak antar toast 8px.
    const double inset = IddsSpacing.s16 + IddsSpacing.s8;
    final double maxWidth = math.max(0, screen.width - 2 * inset);

    return Stack(
      children: <Widget>[
        for (final IddsToastPosition p in IddsToastPosition.values)
          if (_entries.any((_ToastEntry e) => e.position == p))
            Positioned(
              top: switch (p) {
                IddsToastPosition.topLeft || IddsToastPosition.topRight || IddsToastPosition.topCenter => inset + safe.top,
                IddsToastPosition.centerLeft || IddsToastPosition.centerRight => 0,
                _ => null,
              },
              bottom: switch (p) {
                IddsToastPosition.bottomLeft ||
                IddsToastPosition.bottomRight ||
                IddsToastPosition.bottomCenter =>
                  inset + safe.bottom,
                IddsToastPosition.centerLeft || IddsToastPosition.centerRight => 0,
                _ => null,
              },
              left: switch (p) {
                IddsToastPosition.topRight || IddsToastPosition.bottomRight || IddsToastPosition.centerRight => null,
                IddsToastPosition.topCenter || IddsToastPosition.bottomCenter => 0,
                _ => inset,
              },
              right: switch (p) {
                IddsToastPosition.topLeft || IddsToastPosition.bottomLeft || IddsToastPosition.centerLeft => null,
                IddsToastPosition.topCenter || IddsToastPosition.bottomCenter => 0,
                _ => inset,
              },
              child: Align(
                alignment: switch (p) {
                  IddsToastPosition.topCenter => Alignment.topCenter,
                  IddsToastPosition.bottomCenter => Alignment.bottomCenter,
                  IddsToastPosition.centerLeft => Alignment.centerLeft,
                  IddsToastPosition.centerRight => Alignment.centerRight,
                  _ => Alignment.center,
                },
                widthFactor: p == IddsToastPosition.topCenter || p == IddsToastPosition.bottomCenter ? null : 1,
                heightFactor: p == IddsToastPosition.centerLeft || p == IddsToastPosition.centerRight ? null : 1,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: math.max(0, screen.height - 2 * inset)),
                  child: SingleChildScrollView(
                    reverse: p._isBottom,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: switch (p) {
                        IddsToastPosition.topLeft || IddsToastPosition.bottomLeft || IddsToastPosition.centerLeft =>
                          CrossAxisAlignment.start,
                        IddsToastPosition.topCenter || IddsToastPosition.bottomCenter => CrossAxisAlignment.center,
                        _ => CrossAxisAlignment.end,
                      },
                      spacing: IddsSpacing.s8,
                      children: <Widget>[
                        // Sama seperti versi web: toast baru ditambahkan menjauhi
                        // tepi layar (di bawah untuk posisi atas, di atas untuk
                        // posisi bawah).
                        for (final _ToastEntry e in p._isBottom
                            ? _entries.reversed.where((_ToastEntry e) => e.position == p)
                            : _entries.where((_ToastEntry e) => e.position == p))
                          IddsTheme(
                            key: e.key,
                            data: e.theme,
                            child: _ToastView(entry: e, maxWidth: maxWidth),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.entry, required this.maxWidth});

  final _ToastEntry entry;
  final double maxWidth;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(vsync: this, duration: IddsDuration.slow)..forward();

  @override
  void didUpdateWidget(_ToastView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkClosing();
  }

  @override
  void initState() {
    super.initState();
    _checkClosing();
  }

  void _checkClosing() {
    if (!widget.entry.closing || _fade.status == AnimationStatus.reverse) return;
    _fade.reverse().whenComplete(() => widget.entry.manager._remove(widget.entry));
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ToastEntry e = widget.entry;
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double screen = MediaQuery.sizeOf(context).width;
    final bool small = screen < IddsBreakpoint.sm;
    final bool large = screen >= IddsBreakpoint.lg;
    final bool solid = e.style == IddsToastStyle.solid;

    final (Color background, Color border, Color foreground) = switch ((e.state, solid)) {
      (IddsToastState.normal, true) => (c.baseBlack, c.baseBlack, c.baseWhite),
      (IddsToastState.destructive, true) => (c.negative.shade500, c.negative.shade500, c.baseWhite),
      (IddsToastState.positive, true) => (c.positive.shade600, c.positive.shade600, c.baseWhite),
      (IddsToastState.normal, false) => (c.baseWhite, c.baseBlack, c.baseBlack),
      (IddsToastState.destructive, false) => (c.negative.shade50, c.negative.shade500, c.negative.shade500),
      (IddsToastState.positive, false) => (c.positive.shade50, c.positive.shade600, c.positive.shade600),
    };
    final IddsIconData icon = switch (e.state) {
      IddsToastState.normal => IddsIcons.infoCircle,
      IddsToastState.destructive => IddsIcons.alertCircle,
      IddsToastState.positive => IddsIcons.circleCheck,
    };

    final Widget toast = Container(
      constraints: BoxConstraints(
        minWidth: math.min(358, widget.maxWidth),
        maxWidth: widget.maxWidth,
        minHeight: small ? 40 : (large ? 52 : 48),
      ),
      padding: EdgeInsets.all((small ? IddsSpacing.s12 : IddsSpacing.s16) - 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(IddsRadius.lg),
        border: Border.all(color: border),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x140A0D12), offset: Offset(0, 12), blurRadius: 16, spreadRadius: -4),
          BoxShadow(color: Color(0x080A0D12), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -2),
        ],
      ),
      // Lebar mengikuti isi (minimal 358px); teks mengisi sisa ruang sehingga
      // tombol X selalu rata kanan.
      child: Row(
        children: <Widget>[
          // CSS: ikon selalu putih; pada gaya outline ikon mengikuti warna
          // teks agar terlihat di latar terang.
          IddsIcon(icon, size: 20, color: foreground),
          const SizedBox(width: IddsSpacing.s8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                  style: theme.textStyle(
                    fontSize: large ? IddsFontSize.sm : IddsFontSize.xs,
                    lineHeight: (large ? IddsFontSize.sm : IddsFontSize.xs) * 1.4,
                    fontWeight: IddsFontWeight.medium,
                    color: foreground,
                  ),
                  child: IconTheme(data: IconThemeData(size: 16, color: foreground), child: e.title),
                ),
                if (e.description != null) ...<Widget>[
                  const SizedBox(height: IddsSpacing.s4),
                  DefaultTextStyle(
                    style: theme.textStyle(
                      fontSize: IddsFontSize.xs2,
                      lineHeight: IddsFontSize.xs2 * 1.4,
                      color: foreground,
                    ),
                    child: e.description!,
                  ),
                ],
              ],
            ),
          ),
          if (e.action != null) ...<Widget>[
            const SizedBox(width: IddsSpacing.s12),
            e.action!,
          ],
          const SizedBox(width: IddsSpacing.s8),
          Semantics(
            button: true,
            label: e.closeLabel,
            onTap: () => e.manager._close(e),
            excludeSemantics: true,
            child: IddsInteractive(
              onTap: () => e.manager._close(e),
              builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
                visible: state.focused,
                borderRadius: BorderRadius.circular(IddsRadius.sm),
                rings: <(double, Color)>[(1.5, foreground)],
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: IddsIcon(IddsIcons.x, size: 16, strokeWidth: state.hovered ? 3 : 2, color: foreground),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fade, curve: Curves.easeInOut),
      child: Semantics(liveRegion: true, container: true, child: IntrinsicWidth(child: toast)),
    );
  }
}
