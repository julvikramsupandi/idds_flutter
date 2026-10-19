import 'package:flutter/services.dart' show KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey, SystemMouseCursors;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_popover.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import 'idds_dropdown_trigger.dart';

/// Jenis [IddsActionMenuItem]; menentukan warna teks.
enum IddsActionMenuItemType {
  /// Warna teks biasa.
  normal,

  /// Merah, untuk aksi berbahaya seperti hapus.
  danger,

  /// Kuning tua.
  warning,

  /// Hijau.
  success,
}

/// Lebar minimal panel [IddsActionMenu].
enum IddsActionMenuWidth {
  /// Minimal 160px dan selebar pemicu.
  auto,

  /// Minimal 120px.
  sm,

  /// Minimal 160px.
  md,

  /// Minimal 200px.
  lg,

  /// Minimal 240px.
  xl,

  /// Selebar pemicu.
  full,
}

/// Isi [IddsActionMenu]: [IddsActionMenuItem], [IddsActionMenuDivider],
/// atau [IddsActionMenuHeader].
@immutable
sealed class IddsActionMenuEntry {
  const IddsActionMenuEntry();
}

/// Satu aksi di [IddsActionMenu].
class IddsActionMenuItem extends IddsActionMenuEntry {
  /// Membuat aksi.
  const IddsActionMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.type = IddsActionMenuItemType.normal,
  });

  /// Teks aksi.
  final String label;

  /// Dipanggil saat dipilih; menu ditutup lebih dulu. `null` membuat aksi
  /// nonaktif.
  final VoidCallback? onTap;

  /// Ikon di kiri teks.
  final Widget? icon;

  /// Jenis aksi.
  final IddsActionMenuItemType type;
}

/// Garis pemisah di [IddsActionMenu].
class IddsActionMenuDivider extends IddsActionMenuEntry {
  /// Membuat pemisah.
  const IddsActionMenuDivider();
}

/// Judul kelompok di [IddsActionMenu].
class IddsActionMenuHeader extends IddsActionMenuEntry {
  /// Membuat judul kelompok.
  const IddsActionMenuHeader(this.label);

  /// Teks judul (ditampilkan huruf kapital).
  final String label;
}

/// Tombol yang membuka daftar aksi (Action Dropdown IDDS).
///
/// ```dart
/// IddsActionMenu(
///   label: 'Aksi',
///   items: [
///     IddsActionMenuItem(label: 'Ubah', onTap: _edit),
///     const IddsActionMenuDivider(),
///     IddsActionMenuItem(label: 'Hapus', onTap: _delete, type: IddsActionMenuItemType.danger),
///   ],
/// )
/// ```
///
/// Gunakan [triggerBuilder] untuk memakai pemicu sendiri, misalnya
/// [IddsButton] berikon.
class IddsActionMenu extends StatefulWidget {
  /// Membuat menu aksi.
  const IddsActionMenu({
    super.key,
    required this.items,
    this.label = 'Aksi',
    this.prefix,
    this.placement = IddsPopoverPlacement.bottomStart,
    this.width = IddsActionMenuWidth.auto,
    this.size = IddsDropdownSize.sm,
    this.enabled = true,
    this.maxHeight = 300,
    this.triggerBuilder,
  });

  /// Aksi-aksi.
  final List<IddsActionMenuEntry> items;

  /// Teks pemicu bawaan.
  final String label;

  /// Widget di kiri teks pemicu bawaan.
  final Widget? prefix;

  /// Posisi panel.
  final IddsPopoverPlacement placement;

  /// Lebar minimal panel.
  final IddsActionMenuWidth width;

  /// Ukuran pemicu bawaan.
  final IddsDropdownSize size;

  /// Apakah menu bisa dibuka.
  final bool enabled;

  /// Tinggi maksimal panel; lebihnya bisa digulir.
  final double maxHeight;

  /// Pemicu kustom. [toggle] membuka/menutup menu (`null` bila nonaktif).
  final Widget Function(BuildContext context, bool open, VoidCallback? toggle)? triggerBuilder;

  @override
  State<IddsActionMenu> createState() => _IddsActionMenuState();
}

class _IddsActionMenuState extends State<IddsActionMenu> {
  bool _open = false;
  int _highlight = -1;
  bool _keyboardNav = false;
  final FocusNode _triggerFocus = FocusNode(debugLabel: 'IddsActionMenu');
  final FocusNode _menuFocus = FocusNode(debugLabel: 'IddsActionMenu panel');

  @override
  void didUpdateWidget(IddsActionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _open) _open = false;
  }

  @override
  void dispose() {
    _triggerFocus.dispose();
    _menuFocus.dispose();
    super.dispose();
  }

  bool _selectable(int i) {
    final IddsActionMenuEntry e = widget.items[i];
    return e is IddsActionMenuItem && e.onTap != null;
  }

  void _toggle() => _open ? _close() : _openMenu();

  void _openMenu() {
    setState(() {
      _open = true;
      _highlight = -1;
      _keyboardNav = false;
    });
  }

  void _close() {
    if (!_open) return;
    final bool refocus = _menuFocus.hasFocus;
    setState(() => _open = false);
    if (refocus && widget.triggerBuilder == null) _triggerFocus.requestFocus();
  }

  void _activate(IddsActionMenuItem item) {
    if (item.onTap == null) return;
    _close();
    item.onTap!();
  }

  void _move(int delta) {
    final int n = widget.items.length;
    if (n == 0) return;
    int i = _highlight < 0 && delta < 0 ? n : _highlight;
    for (int step = 0; step < n; step++) {
      i = (i + delta) % n;
      if (i < 0) i += n;
      if (_selectable(i)) {
        setState(() {
          _highlight = i;
          _keyboardNav = true;
        });
        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
    } else if (key == LogicalKeyboardKey.home) {
      _highlight = -1;
      _move(1);
    } else if (key == LogicalKeyboardKey.end) {
      _highlight = -1;
      _move(-1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      if (_highlight >= 0 && _selectable(_highlight)) _activate(widget.items[_highlight] as IddsActionMenuItem);
    } else if (key == LogicalKeyboardKey.tab) {
      _close();
      return KeyEventResult.ignored;
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final IddsDropdownMetrics m = IddsDropdownMetrics.of(context, widget.size);
    final VoidCallback? toggle = widget.enabled ? _toggle : null;

    final Widget trigger = widget.triggerBuilder?.call(context, _open, toggle) ??
        Semantics(
          button: true,
          enabled: widget.enabled,
          label: widget.label,
          onTap: toggle,
          excludeSemantics: true,
          child: IddsInteractive(
            focusNode: _triggerFocus,
            onTap: toggle,
            builder: (BuildContext context, IddsInteractionState state) => IntrinsicWidth(
              child: IddsDropdownTriggerBox(
                state: state,
                open: _open,
                metrics: m,
                prefix: widget.prefix,
                child: Text(widget.label),
              ),
            ),
          ),
        );

    final double? minWidth = switch (widget.width) {
      IddsActionMenuWidth.auto => 160,
      IddsActionMenuWidth.sm => 120,
      IddsActionMenuWidth.md => 160,
      IddsActionMenuWidth.lg => 200,
      IddsActionMenuWidth.xl => 240,
      IddsActionMenuWidth.full => null,
    };

    return IddsPopover(
      open: _open,
      onDismiss: _close,
      placement: widget.placement,
      matchAnchorWidth: widget.width == IddsActionMenuWidth.auto || widget.width == IddsActionMenuWidth.full,
      minWidth: minWidth,
      maxHeight: widget.maxHeight,
      panelBuilder: _buildMenu,
      child: trigger,
    );
  }

  Widget _buildMenu(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool compact = iddsIsCompact(context, IddsBreakpoint.md + 1);
    return _FocusOnMount(
      node: _menuFocus,
      child: Focus(
        focusNode: _menuFocus,
        onKeyEvent: _onKey,
        child: IddsPopoverSurface(
          shadow: IddsShadow.lg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: IddsSpacing.s4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < widget.items.length; i++)
                  switch (widget.items[i]) {
                    final IddsActionMenuItem item => _MenuItem(
                        item: item,
                        compact: compact,
                        highlighted: i == _highlight,
                        focusRing: i == _highlight && _keyboardNav,
                        onHover: () {
                          if (_highlight != i || _keyboardNav) {
                            setState(() {
                              _highlight = i;
                              _keyboardNav = false;
                            });
                          }
                        },
                        onTap: () => _activate(item),
                      ),
                    IddsActionMenuDivider _ => Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: IddsSpacing.s4, horizontal: IddsSpacing.s16),
                        color: c.strokePrimary,
                      ),
                    final IddsActionMenuHeader header => Padding(
                        padding: const EdgeInsets.fromLTRB(IddsSpacing.s16, IddsSpacing.s8, IddsSpacing.s16, IddsSpacing.s4),
                        child: Text(
                          header.label.toUpperCase(),
                          style: theme.textStyle(
                            fontSize: IddsFontSize.xs,
                            lineHeight: IddsLineHeight.xs,
                            fontWeight: IddsFontWeight.medium,
                            color: c.contentSecondary,
                          ),
                        ),
                      ),
                  },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FocusOnMount extends StatefulWidget {
  const _FocusOnMount({required this.node, required this.child});

  final FocusNode node;
  final Widget child;

  @override
  State<_FocusOnMount> createState() => _FocusOnMountState();
}

class _FocusOnMountState extends State<_FocusOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.node.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.item,
    required this.compact,
    required this.highlighted,
    required this.focusRing,
    required this.onHover,
    required this.onTap,
  });

  final IddsActionMenuItem item;
  final bool compact;
  final bool highlighted;
  final bool focusRing;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool enabled = item.onTap != null;
    final bool dark = theme.isDark;

    // CSS memakai warna 600 dan latar 100. Di dark mode latar 100 terlalu
    // terang, jadi dipakai latar netral dan warna 400 agar tetap terbaca.
    Color foreground = switch (item.type) {
      IddsActionMenuItemType.normal => c.contentPrimary,
      IddsActionMenuItemType.danger => dark ? c.negative.shade400 : c.negative.shade600,
      IddsActionMenuItemType.warning => dark ? c.warning.shade400 : c.warning.shade600,
      IddsActionMenuItemType.success => dark ? c.positive.shade400 : c.positive.shade600,
    };
    Color? background;
    if (enabled && focusRing) {
      // CSS :focus: latar primary-100, teks primary-600.
      background = dark ? c.backgroundTertiary : c.primary.shade100;
      if (item.type == IddsActionMenuItemType.normal) foreground = dark ? c.contentPrimary : c.primary.shade600;
    } else if (enabled && highlighted) {
      background = item.type == IddsActionMenuItemType.danger && !dark ? c.negative.shade100 : c.backgroundSecondary;
    }

    return Semantics(
      button: true,
      enabled: enabled,
      label: item.label,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: enabled ? (_) => onHover() : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Container(
              color: background,
              padding: EdgeInsets.symmetric(horizontal: IddsSpacing.s16, vertical: compact ? IddsSpacing.s12 : IddsSpacing.s8),
              child: IconTheme(
                data: IconThemeData(size: 16, color: foreground),
                child: Row(
                  spacing: IddsSpacing.s8,
                  children: <Widget>[
                    if (item.icon != null) item.icon!,
                    Expanded(
                      child: Text(
                        item.label,
                        style: theme.textStyle(
                          fontSize: compact ? IddsFontSize.base : IddsFontSize.sm,
                          lineHeight: compact ? IddsLineHeight.base : IddsLineHeight.sm,
                          color: foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
