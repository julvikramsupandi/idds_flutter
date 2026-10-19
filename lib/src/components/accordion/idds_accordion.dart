import 'package:flutter/foundation.dart' show immutable, setEquals;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Membuka/menutup [child] dengan animasi tinggi dan transparansi
/// (Collapse IDDS). Saat tertutup, isi tetap tersimpan tetapi tidak bisa
/// difokuskan dan tidak dibaca pembaca layar.
class IddsCollapse extends StatefulWidget {
  /// Membuat collapse.
  const IddsCollapse({
    super.key,
    required this.open,
    required this.child,
    this.duration = IddsDuration.slow,
    this.curve = Curves.ease,
    this.fade = true,
  });

  /// Terbuka.
  final bool open;

  /// Isi.
  final Widget child;

  /// Lama animasi.
  final Duration duration;

  /// Kurva animasi.
  final Curve curve;

  /// Ikut memudar saat menutup.
  final bool fade;

  @override
  State<IddsCollapse> createState() => _IddsCollapseState();
}

class _IddsCollapseState extends State<IddsCollapse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.open ? 1 : 0,
  );
  late final CurvedAnimation _curved = CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void didUpdateWidget(IddsCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
    _curved.curve = widget.curve;
    if (widget.open != oldWidget.open) widget.open ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final bool closed = _controller.isDismissed;
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: _curved.value,
            child: Visibility(
              visible: !closed,
              maintainState: true,
              child: widget.fade ? Opacity(opacity: _curved.value, child: child) : child!,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Satu bagian yang bisa dibuka/ditutup, dengan garis di bawahnya
/// (Accordion IDDS).
///
/// Bisa dipakai sendiri (status disimpan sendiri, awalnya [initiallyOpen])
/// atau dikendalikan lewat [open] dan [onChanged]. Untuk sekumpulan
/// accordion, gunakan [IddsAccordionGroup].
class IddsAccordion extends StatefulWidget {
  /// Membuat accordion.
  const IddsAccordion({
    super.key,
    required this.title,
    required this.child,
    this.open,
    this.initiallyOpen = false,
    this.onChanged,
    this.enabled = true,
  });

  /// Judul; menekan judul membuka/menutup isi.
  final Widget title;

  /// Isi.
  final Widget child;

  /// Status terbuka (mode terkendali).
  final bool? open;

  /// Status awal bila [open] `null`.
  final bool initiallyOpen;

  /// Dipanggil dengan status baru.
  final ValueChanged<bool>? onChanged;

  /// Apakah bisa dibuka/ditutup.
  final bool enabled;

  @override
  State<IddsAccordion> createState() => _IddsAccordionState();
}

class _IddsAccordionState extends State<IddsAccordion> {
  late bool _open = widget.initiallyOpen;

  bool get _isOpen => widget.open ?? _open;

  void _toggle() {
    final bool next = !_isOpen;
    if (widget.open == null) setState(() => _open = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double screen = iddsScreenWidth(context);
    final bool open = _isOpen;
    final double titleSize = screen >= IddsBreakpoint.md ? IddsFontSize.sm : IddsFontSize.xs;
    final double iconSize = screen >= IddsBreakpoint.xl
        ? 24
        : screen >= IddsBreakpoint.lg
            ? 20
            : screen >= IddsBreakpoint.md
                ? 18
                : screen >= IddsBreakpoint.sm
                    ? 16
                    : 14;
    final bool large = screen >= IddsBreakpoint.lg;

    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.strokePrimary))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            button: true,
            expanded: open,
            enabled: widget.enabled,
            child: IddsInteractive(
              onTap: widget.enabled ? _toggle : null,
              builder: (BuildContext context, IddsInteractionState state) {
                final Color color = widget.enabled ? c.contentPrimary : c.contentTertiary;
                final Widget header = Padding(
                  padding: const EdgeInsets.symmetric(vertical: IddsSpacing.s16),
                  child: Row(
                    spacing: IddsSpacing.s12,
                    children: <Widget>[
                      Expanded(
                        child: DefaultTextStyle(
                          style: theme
                              .textStyle(
                                fontSize: titleSize,
                                lineHeight: titleSize + 6,
                                fontWeight: IddsFontWeight.semibold,
                                color: color,
                              )
                              .copyWith(
                                decoration: state.hovered ? TextDecoration.underline : TextDecoration.none,
                                decorationColor: color,
                              ),
                          child: widget.title,
                        ),
                      ),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: IddsDuration.base,
                        child: IddsIcon(IddsIcons.chevronDown, size: iconSize, color: color),
                      ),
                    ],
                  ),
                );
                // CSS fokus: latar neutral-100 (latar tersier di dark mode)
                // dan garis 2px primary-600 di dalam.
                return Opacity(
                  opacity: widget.enabled ? 1 : 0.6,
                  child: IddsInsetRing(
                    visible: state.focused,
                    borderRadius: BorderRadius.circular(IddsRadius.lg),
                    rings: <(double, Color)>[(2.0, c.primary.shade600)],
                    child: Container(
                      decoration: BoxDecoration(
                        color: state.focused ? c.backgroundTertiary : null,
                        borderRadius: BorderRadius.circular(IddsRadius.lg),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: state.focused ? IddsSpacing.s8 : 0),
                      child: header,
                    ),
                  ),
                );
              },
            ),
          ),
          IddsCollapse(
            open: open,
            child: Padding(
              padding: const EdgeInsets.only(bottom: IddsSpacing.s16),
              child: DefaultTextStyle(
                style: theme.textStyle(
                  fontSize: large ? IddsFontSize.sm : IddsFontSize.xs,
                  lineHeight: large ? IddsLineHeight.sm : IddsLineHeight.xs,
                  color: c.contentPrimary,
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu item [IddsAccordionGroup].
@immutable
class IddsAccordionItem {
  /// Membuat item.
  const IddsAccordionItem({required this.title, required this.child, this.enabled = true});

  /// Judul.
  final Widget title;

  /// Isi.
  final Widget child;

  /// Apakah bisa dibuka.
  final bool enabled;
}

/// Sekumpulan [IddsAccordion]. Bawaan hanya satu yang terbuka; membuka
/// yang lain menutup yang sebelumnya. Panah atas/bawah memindahkan fokus
/// antar judul.
class IddsAccordionGroup extends StatefulWidget {
  /// Membuat grup.
  const IddsAccordionGroup({
    super.key,
    required this.items,
    this.multipleOpen = false,
    this.initiallyOpen = const <int>{},
    this.openIndexes,
    this.onChanged,
  });

  /// Item-item.
  final List<IddsAccordionItem> items;

  /// Boleh membuka lebih dari satu.
  final bool multipleOpen;

  /// Indeks yang terbuka di awal (mode tidak terkendali).
  final Set<int> initiallyOpen;

  /// Indeks yang terbuka (mode terkendali).
  final Set<int>? openIndexes;

  /// Dipanggil dengan indeks yang terbuka.
  final ValueChanged<Set<int>>? onChanged;

  @override
  State<IddsAccordionGroup> createState() => _IddsAccordionGroupState();
}

class _IddsAccordionGroupState extends State<IddsAccordionGroup> {
  late Set<int> _open = <int>{...widget.initiallyOpen};

  Set<int> get _current => widget.openIndexes ?? _open;

  void _set(int index, bool open) {
    final Set<int> next = widget.multipleOpen ? <int>{..._current} : <int>{};
    if (open) {
      next.add(index);
    } else {
      next.remove(index);
    }
    if (setEquals(next, _current)) return;
    if (widget.openIndexes == null) setState(() => _open = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final Set<int> open = _current;
    return FocusTraversalGroup(
      child: Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowDown): NextFocusIntent(),
          SingleActivator(LogicalKeyboardKey.arrowUp): PreviousFocusIntent(),
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int i = 0; i < widget.items.length; i++)
              IddsAccordion(
                title: widget.items[i].title,
                enabled: widget.items[i].enabled,
                open: open.contains(i),
                onChanged: (bool value) => _set(i, value),
                child: widget.items[i].child,
              ),
          ],
        ),
      ),
    );
  }
}

/// Accordion bergaya kartu: kotak bergaris tepi dengan ikon chevron di kiri
/// judul (Accordion Card IDDS).
class IddsAccordionCard extends StatefulWidget {
  /// Membuat accordion kartu.
  const IddsAccordionCard({
    super.key,
    required this.title,
    required this.child,
    this.open,
    this.initiallyOpen = false,
    this.onChanged,
  });

  /// Judul.
  final Widget title;

  /// Isi.
  final Widget child;

  /// Status terbuka (mode terkendali).
  final bool? open;

  /// Status awal bila [open] `null`.
  final bool initiallyOpen;

  /// Dipanggil dengan status baru.
  final ValueChanged<bool>? onChanged;

  @override
  State<IddsAccordionCard> createState() => _IddsAccordionCardState();
}

class _IddsAccordionCardState extends State<IddsAccordionCard> {
  late bool _open = widget.initiallyOpen;

  bool get _isOpen => widget.open ?? _open;

  void _toggle() {
    final bool next = !_isOpen;
    if (widget.open == null) setState(() => _open = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool open = _isOpen;
    final bool wide = iddsScreenWidth(context) >= IddsBreakpoint.sm;

    return Container(
      padding: const EdgeInsets.all(IddsSpacing.s16 - 1),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(IddsRadius.lg),
        border: Border.all(color: c.strokePrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            button: true,
            expanded: open,
            child: IddsInteractive(
              onTap: _toggle,
              builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
                visible: state.focused,
                borderRadius: BorderRadius.circular(IddsRadius.base),
                // CSS: outline 2px guide-500.
                rings: <(double, Color)>[(2.0, c.guide.shade500)],
                child: Row(
                  children: <Widget>[
                    AnimatedContainer(
                      duration: IddsDuration.fast,
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: state.hovered ? c.backgroundTertiary : c.backgroundSecondary,
                        borderRadius: BorderRadius.circular(IddsRadius.lg),
                      ),
                      child: AnimatedRotation(
                        turns: open ? 0 : 0.5,
                        duration: IddsDuration.base,
                        child: IddsIcon(IddsIcons.chevronUp, size: 20, color: c.contentSecondary),
                      ),
                    ),
                    const SizedBox(width: IddsSpacing.s16),
                    Expanded(
                      child: DefaultTextStyle(
                        style: theme.textStyle(
                          fontSize: wide ? IddsFontSize.base : IddsFontSize.sm,
                          lineHeight: wide ? IddsLineHeight.base : IddsLineHeight.sm,
                          fontWeight: IddsFontWeight.semibold,
                          // CSS hover: warna secondary brand.
                          color: state.hovered ? c.secondary.shade600 : c.contentPrimary,
                        ),
                        child: widget.title,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IddsCollapse(
            open: open,
            duration: const Duration(milliseconds: 500),
            fade: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s16, vertical: IddsSpacing.s12),
              child: DefaultTextStyle(
                style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentPrimary),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
