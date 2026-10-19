import 'package:flutter/services.dart' show HardwareKeyboard, KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey, SystemMouseCursors;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_date_utils.dart';
import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Cara [IddsCalendar] memilih tanggal.
enum IddsCalendarMode {
  /// Satu tanggal.
  single,

  /// Rentang: tekan tanggal awal, lalu tanggal akhir.
  range,

  /// Banyak tanggal; menekan tanggal terpilih membatalkannya.
  multiple,
}

enum _View { days, months, years }

/// Kalender bulanan IDDS, dipakai di dalam panel [IddsDatePicker] dan bisa
/// juga ditampilkan langsung di halaman.
///
/// [selected] berisi tanggal terpilih:
/// - [IddsCalendarMode.single]: kosong atau satu tanggal.
/// - [IddsCalendarMode.range]: kosong, `[awal]`, atau `[awal, akhir]`.
/// - [IddsCalendarMode.multiple]: tanggal-tanggal terpilih.
///
/// Navigasi keyboard: panah (hari/minggu), Page Up/Down (bulan; dengan
/// Shift: tahun), Home/End (awal/akhir minggu), Enter/Spasi (pilih).
class IddsCalendar extends StatefulWidget {
  /// Membuat kalender.
  const IddsCalendar({
    super.key,
    required this.mode,
    required this.selected,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.selectableDayPredicate,
    this.initialMonth,
    this.currentDate,
    this.firstDayOfWeek = DateTime.sunday,
    this.monthCount,
    this.autofocus = false,
    this.focusNode,
  }) : assert(firstDayOfWeek >= DateTime.monday && firstDayOfWeek <= DateTime.sunday);

  /// Cara memilih.
  final IddsCalendarMode mode;

  /// Tanggal terpilih (lihat penjelasan kelas).
  final List<DateTime> selected;

  /// Dipanggil dengan daftar tanggal terpilih yang baru. `null` membuat
  /// kalender hanya-baca.
  final ValueChanged<List<DateTime>>? onChanged;

  /// Tanggal paling awal yang bisa dipilih.
  final DateTime? firstDate;

  /// Tanggal paling akhir yang bisa dipilih.
  final DateTime? lastDate;

  /// Aturan tambahan; kembalikan `false` untuk menonaktifkan tanggal.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Bulan yang pertama ditampilkan. Bawaan: bulan tanggal terpilih, atau
  /// bulan ini.
  final DateTime? initialMonth;

  /// Tanggal "hari ini". Bawaan: `DateTime.now()`.
  final DateTime? currentDate;

  /// Hari pertama dalam minggu, `DateTime.sunday` (bawaan, sama seperti IDDS)
  /// sampai `DateTime.saturday`.
  final int firstDayOfWeek;

  /// Jumlah bulan yang ditampilkan berdampingan (1 atau 2). Bawaan: 2 untuk
  /// rentang/banyak tanggal di layar ≥ 768px, selain itu 1.
  final int? monthCount;

  /// Langsung fokus ke grid tanggal.
  final bool autofocus;

  /// Focus node grid tanggal.
  final FocusNode? focusNode;

  @override
  State<IddsCalendar> createState() => _IddsCalendarState();
}

class _IddsCalendarState extends State<IddsCalendar> {
  static const double _cellWidth = 40;
  static const double _columnGap = IddsSpacing.s24;
  static const int _yearsPerPage = 20;

  late DateTime _month;
  late DateTime _focused;
  DateTime? _hover;
  _View _view = _View.days;
  int _viewColumn = 0;
  late int _yearPageStart;
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: 'IddsCalendar'));

  DateTime get _today => iddsDateOnly(widget.currentDate ?? DateTime.now());

  List<DateTime> get _selected => <DateTime>[for (final DateTime d in widget.selected) iddsDateOnly(d)];

  @override
  void initState() {
    super.initState();
    final List<DateTime> selected = _selected;
    DateTime anchor = selected.isNotEmpty ? selected.first : (widget.initialMonth ?? _today);
    if (selected.isEmpty && widget.initialMonth == null) {
      if (widget.firstDate != null && anchor.isBefore(widget.firstDate!)) anchor = widget.firstDate!;
      if (widget.lastDate != null && anchor.isAfter(widget.lastDate!)) anchor = widget.lastDate!;
    }
    _month = DateTime(anchor.year, anchor.month);
    _focused = selected.isNotEmpty ? selected.first : iddsDateOnly(anchor);
    _yearPageStart = _pageStartFor(_month.year);
  }

  @override
  void dispose() {
    _ownFocus?.dispose();
    super.dispose();
  }

  int _pageStartFor(int year) => year - ((year - 1900) % _yearsPerPage);

  int _columns(BuildContext context) {
    if (widget.monthCount != null) return widget.monthCount!.clamp(1, 2);
    if (widget.mode == IddsCalendarMode.single) return 1;
    return iddsScreenWidth(context) >= IddsBreakpoint.md ? 2 : 1;
  }

  bool _selectable(DateTime day) {
    if (widget.firstDate != null && day.isBefore(iddsDateOnly(widget.firstDate!))) return false;
    if (widget.lastDate != null && day.isAfter(iddsDateOnly(widget.lastDate!))) return false;
    return widget.selectableDayPredicate?.call(day) ?? true;
  }

  bool _monthHasSelectable(DateTime month) {
    final DateTime first = DateTime(month.year, month.month);
    final DateTime last = DateTime(month.year, month.month, iddsDaysInMonth(month.year, month.month));
    if (widget.firstDate != null && last.isBefore(iddsDateOnly(widget.firstDate!))) return false;
    if (widget.lastDate != null && first.isAfter(iddsDateOnly(widget.lastDate!))) return false;
    return true;
  }

  void _select(DateTime day) {
    final ValueChanged<List<DateTime>>? onChanged = widget.onChanged;
    if (onChanged == null || !_selectable(day)) return;
    final List<DateTime> selected = _selected;
    setState(() {
      _focused = day;
      _hover = null;
    });
    switch (widget.mode) {
      case IddsCalendarMode.single:
        onChanged(<DateTime>[day]);
      case IddsCalendarMode.multiple:
        final bool had = selected.any((DateTime d) => iddsIsSameDay(d, day));
        onChanged(had
            ? <DateTime>[for (final DateTime d in selected) if (!iddsIsSameDay(d, day)) d]
            : <DateTime>[...selected, day]);
      case IddsCalendarMode.range:
        if (selected.length == 1) {
          final DateTime start = selected.first;
          onChanged(day.isBefore(start) ? <DateTime>[day, start] : <DateTime>[start, day]);
        } else {
          onChanged(<DateTime>[day]);
        }
    }
  }

  void _showMonth(DateTime month) => setState(() => _month = DateTime(month.year, month.month));

  void _moveFocus(DateTime day, int columns) {
    final DateTime d = iddsDateOnly(day);
    final DateTime lastVisible = iddsAddMonths(_month, columns - 1);
    DateTime month = _month;
    if (d.isBefore(_month)) {
      month = DateTime(d.year, d.month);
    } else if (d.isAfter(DateTime(lastVisible.year, lastVisible.month, iddsDaysInMonth(lastVisible.year, lastVisible.month)))) {
      month = iddsAddMonths(DateTime(d.year, d.month), -(columns - 1));
    }
    setState(() {
      _focused = d;
      _month = month;
      if (_pendingStart != null) _hover = d;
    });
  }

  /// Tanggal awal rentang yang menunggu tanggal akhir.
  DateTime? get _pendingStart =>
      widget.mode == IddsCalendarMode.range && widget.selected.length == 1 ? iddsDateOnly(widget.selected.first) : null;

  KeyEventResult _onKey(FocusNode node, KeyEvent event, int columns) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (_view != _View.days) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    final bool shift = HardwareKeyboard.instance.isShiftPressed;
    final int offset = (_focused.weekday - widget.firstDayOfWeek + 7) % 7;
    DateTime? target;
    if (key == LogicalKeyboardKey.arrowLeft) {
      target = iddsAddDays(_focused, -1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      target = iddsAddDays(_focused, 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      target = iddsAddDays(_focused, -7);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      target = iddsAddDays(_focused, 7);
    } else if (key == LogicalKeyboardKey.home) {
      target = iddsAddDays(_focused, -offset);
    } else if (key == LogicalKeyboardKey.end) {
      target = iddsAddDays(_focused, 6 - offset);
    } else if (key == LogicalKeyboardKey.pageUp || key == LogicalKeyboardKey.pageDown) {
      final int delta = (key == LogicalKeyboardKey.pageUp ? -1 : 1) * (shift ? 12 : 1);
      final DateTime m = iddsAddMonths(_focused, delta);
      target = DateTime(m.year, m.month, _focused.day.clamp(1, iddsDaysInMonth(m.year, m.month)));
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _select(_focused);
      return KeyEventResult.handled;
    }
    if (target == null) return KeyEventResult.ignored;
    _moveFocus(target, columns);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final int columns = _columns(context);
    final bool small = iddsIsCompact(context, IddsBreakpoint.sm);
    final double width = _cellWidth * 7 * columns + _columnGap * (columns - 1);

    final Widget content = switch (_view) {
      _View.days => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: _columnGap,
          children: <Widget>[
            for (int i = 0; i < columns; i++) _buildMonthColumn(context, i, columns, small),
          ],
        ),
      _View.months => _buildMonthPicker(context, columns),
      _View.years => _buildYearPicker(context, columns),
    };

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focus,
        autofocus: widget.autofocus,
        onFocusChange: (_) => setState(() {}),
        onKeyEvent: (FocusNode node, KeyEvent event) => _onKey(node, event, columns),
        child: SizedBox(width: width, child: content),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime month, int column, int columns) {
    final bool first = column == 0;
    final bool last = column == columns - 1;
    final DateTime prev = iddsAddMonths(_month, -1);
    final DateTime next = iddsAddMonths(_month, columns);
    return SizedBox(
      height: 40,
      child: Row(
        children: <Widget>[
          if (first)
            _NavButton(
              icon: IddsIcons.chevronLeft,
              label: 'Bulan sebelumnya',
              onTap: _monthHasSelectable(prev) ? () => _showMonth(prev) : null,
            )
          else
            const SizedBox(width: 28),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: IddsSpacing.s6,
              children: <Widget>[
                _HeaderButton(
                  label: IddsDateNames.months[month.month - 1],
                  semanticLabel: 'Pilih bulan',
                  onTap: () => setState(() {
                    _view = _View.months;
                    _viewColumn = column;
                  }),
                ),
                _HeaderButton(
                  label: '${month.year}',
                  semanticLabel: 'Pilih tahun',
                  onTap: () => setState(() {
                    _view = _View.years;
                    _viewColumn = column;
                    _yearPageStart = _pageStartFor(month.year);
                  }),
                ),
              ],
            ),
          ),
          if (last)
            _NavButton(
              icon: IddsIcons.chevronRight,
              label: 'Bulan berikutnya',
              onTap: _monthHasSelectable(next) ? () => _showMonth(iddsAddMonths(_month, 1)) : null,
            )
          else
            const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildMonthColumn(BuildContext context, int column, int columns, bool small) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final DateTime month = iddsAddMonths(_month, column);
    final double cellHeight = small ? 32 : 40;
    final int lead = (DateTime(month.year, month.month).weekday - widget.firstDayOfWeek + 7) % 7;
    final int days = iddsDaysInMonth(month.year, month.month);
    final int rows = ((lead + days) / 7).ceil();
    final DateTime gridStart = iddsAddDays(DateTime(month.year, month.month), -lead);

    final List<DateTime> selected = _selected;
    final DateTime? pending = _pendingStart;
    final bool complete = widget.mode == IddsCalendarMode.range && selected.length == 2;
    final DateTime? rangeStart = complete ? selected[0] : null;
    final DateTime? rangeEnd = complete ? selected[1] : null;
    DateTime? previewStart;
    DateTime? previewEnd;
    if (pending != null && _hover != null) {
      previewStart = _hover!.isBefore(pending) ? _hover : pending;
      previewEnd = _hover!.isBefore(pending) ? pending : _hover;
    }
    final bool showRing = _focus.hasFocus && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

    final TextStyle headerStyle = theme.textStyle(
      fontSize: small ? IddsFontSize.xs2 : IddsFontSize.xs,
      lineHeight: IddsLineHeight.xs,
      fontWeight: IddsFontWeight.medium,
      color: c.contentTertiary,
    );

    return SizedBox(
      width: _cellWidth * 7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(context, month, column, columns),
          const SizedBox(height: IddsSpacing.s12),
          ExcludeSemantics(
            child: Row(
              children: <Widget>[
                for (int i = 0; i < 7; i++)
                  SizedBox(
                    width: _cellWidth,
                    height: cellHeight,
                    child: Center(
                      child: Text(
                        IddsDateNames.shortWeekdays[(widget.firstDayOfWeek - 1 + i) % 7],
                        style: headerStyle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (int r = 0; r < rows; r++)
            Row(
              children: <Widget>[
                for (int i = 0; i < 7; i++)
                  () {
                    final DateTime day = iddsAddDays(gridStart, r * 7 + i);
                    final bool isSelected = selected.any((DateTime d) => iddsIsSameDay(d, day));
                    final bool inRange = (rangeStart != null && day.isAfter(rangeStart) && day.isBefore(rangeEnd!)) ||
                        (previewStart != null && day.isAfter(previewStart) && day.isBefore(previewEnd!));
                    final bool previewEdge = previewEnd != null && iddsIsSameDay(day, _hover) && !isSelected;
                    return _DayCell(
                      day: day,
                      width: _cellWidth,
                      height: cellHeight,
                      small: small,
                      outside: day.month != month.month,
                      today: iddsIsSameDay(day, _today),
                      selected: isSelected,
                      inRange: inRange,
                      previewEdge: previewEdge,
                      enabled: widget.onChanged != null && _selectable(day),
                      focusRing: showRing && iddsIsSameDay(day, _focused),
                      onTap: () => _select(day),
                      onHover: (bool hovering) {
                        if (pending == null) return;
                        if (hovering) {
                          setState(() => _hover = day);
                        } else if (iddsIsSameDay(_hover, day)) {
                          setState(() => _hover = null);
                        }
                      },
                    );
                  }(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker(BuildContext context, int columns) {
    final DateTime shown = iddsAddMonths(_month, _viewColumn);
    return _PickerGrid(
      title: '${shown.year}',
      crossAxisCount: 3,
      items: <_PickerItem>[
        for (int m = 1; m <= 12; m++)
          _PickerItem(
            label: IddsDateNames.shortMonths[m - 1],
            semanticLabel: IddsDateNames.months[m - 1],
            selected: m == shown.month,
            current: m == _today.month && shown.year == _today.year,
            enabled: _monthHasSelectable(DateTime(shown.year, m)),
            onTap: () => setState(() {
              _month = iddsAddMonths(DateTime(shown.year, m), -_viewColumn);
              _view = _View.days;
            }),
          ),
      ],
      onBack: () => setState(() => _view = _View.days),
    );
  }

  Widget _buildYearPicker(BuildContext context, int columns) {
    final DateTime shown = iddsAddMonths(_month, _viewColumn);
    final int start = _yearPageStart;
    final int end = start + _yearsPerPage - 1;
    bool yearEnabled(int y) =>
        (widget.firstDate == null || y >= widget.firstDate!.year) && (widget.lastDate == null || y <= widget.lastDate!.year);
    return _PickerGrid(
      title: '$start – $end',
      crossAxisCount: 4,
      onPrevious: start > 1900 ? () => setState(() => _yearPageStart -= _yearsPerPage) : null,
      onNext: end < 2100 ? () => setState(() => _yearPageStart += _yearsPerPage) : null,
      items: <_PickerItem>[
        for (int y = start; y <= end; y++)
          _PickerItem(
            label: '$y',
            selected: y == shown.year,
            current: y == _today.year,
            enabled: yearEnabled(y),
            onTap: () => setState(() {
              _month = iddsAddMonths(DateTime(y, shown.month), -_viewColumn);
              _view = _View.days;
            }),
          ),
      ],
      onBack: () => setState(() => _view = _View.days),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.width,
    required this.height,
    required this.small,
    required this.outside,
    required this.today,
    required this.selected,
    required this.inRange,
    required this.previewEdge,
    required this.enabled,
    required this.focusRing,
    required this.onTap,
    required this.onHover,
  });

  final DateTime day;
  final double width;
  final double height;
  final bool small;
  final bool outside;
  final bool today;
  final bool selected;
  final bool inRange;
  final bool previewEdge;
  final bool enabled;
  final bool focusRing;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    // CSS dark mode: hover memakai background-secondary.
    final Color hoverColor = theme.isDark ? c.backgroundSecondary : c.backgroundTertiary;
    final Color foreground = selected
        ? c.onPrimary
        : (!enabled || outside)
            ? c.contentTertiary
            : c.contentPrimary;

    Widget cell(bool hovered) {
      final Color? background = selected
          ? c.primaryMain
          : (inRange || previewEdge || (hovered && enabled))
              ? (inRange ? c.backgroundTertiary : hoverColor)
              : null;
      final BorderRadius radius = inRange && !selected ? BorderRadius.zero : BorderRadius.circular(IddsRadius.lg);
      final Widget number = Text(
        '${day.day}',
        style: theme.textStyle(
          fontSize: small ? IddsFontSize.xs2 : IddsFontSize.xs,
          lineHeight: IddsLineHeight.xs,
          fontWeight: today ? IddsFontWeight.bold : IddsFontWeight.medium,
          color: foreground,
        ),
      );
      return IddsInsetRing(
        visible: focusRing,
        borderRadius: radius,
        rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.strokeTertiary)],
        child: AnimatedContainer(
          duration: IddsDuration.fast,
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: background, borderRadius: radius),
          child: today
              // CSS: hari ini diberi garis 2px di atas angka.
              ? Container(
                  padding: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: selected ? c.onPrimary : c.contentPrimary, width: 2)),
                  ),
                  child: number,
                )
              : number,
        ),
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: iddsFormatDate(day, 'EEEE, d MMMM yyyy'),
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: _Hoverable(
        enabled: enabled,
        onHover: onHover,
        onTap: onTap,
        builder: cell,
      ),
    );
  }
}

/// Area yang bisa ditekan dan mendeteksi hover, tanpa ikut urutan fokus
/// (fokus keyboard dikelola oleh grid).
class _Hoverable extends StatefulWidget {
  const _Hoverable({required this.enabled, required this.onTap, required this.builder, this.onHover});

  final bool enabled;
  final VoidCallback onTap;
  final ValueChanged<bool>? onHover;
  final Widget Function(bool hovered) builder;

  @override
  State<_Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<_Hoverable> {
  bool _hovered = false;

  void _set(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHover?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: widget.enabled ? (_) => _set(true) : null,
      onExit: (_) => _set(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: widget.builder(widget.enabled && _hovered),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, required this.onTap});

  final IddsIconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Semantics(
      button: true,
      label: label,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(IddsRadius.base),
          rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.strokeTertiary)],
          child: Opacity(
            opacity: state.enabled ? 1 : 0.4,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: state.hovered ? (theme.isDark ? c.backgroundSecondary : c.backgroundTertiary) : null,
                borderRadius: BorderRadius.circular(IddsRadius.base),
              ),
              child: IddsIcon(icon, size: 20, color: state.hovered ? c.contentPrimary : c.contentSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.label, required this.semanticLabel, required this.onTap});

  final String label;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final BorderRadius radius = BorderRadius.circular(IddsRadius.md);
    return Semantics(
      button: true,
      label: '$semanticLabel, $label',
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: radius,
          inset: 1,
          rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.contentPrimary)],
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s6),
            decoration: BoxDecoration(
              color: state.hovered ? c.backgroundSecondary : c.backgroundPrimary,
              borderRadius: radius,
              border: Border.all(color: state.focused ? c.strokeTertiary : c.strokePrimary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: IddsSpacing.s4,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textStyle(
                    fontSize: IddsFontSize.xs,
                    lineHeight: IddsLineHeight.xs,
                    fontWeight: IddsFontWeight.medium,
                    color: c.contentPrimary,
                  ),
                ),
                IddsIcon(IddsIcons.chevronDown, size: 14, color: c.contentSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerItem {
  const _PickerItem({
    required this.label,
    required this.selected,
    required this.current,
    required this.enabled,
    required this.onTap,
    this.semanticLabel,
  });

  final String label;
  final String? semanticLabel;
  final bool selected;
  final bool current;
  final bool enabled;
  final VoidCallback onTap;
}

/// Grid pilihan bulan atau tahun yang menggantikan grid tanggal.
class _PickerGrid extends StatelessWidget {
  const _PickerGrid({
    required this.title,
    required this.crossAxisCount,
    required this.items,
    required this.onBack,
    this.onPrevious,
    this.onNext,
  });

  final String title;
  final int crossAxisCount;
  final List<_PickerItem> items;
  final VoidCallback onBack;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final int rows = (items.length / crossAxisCount).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 40,
          child: Row(
            children: <Widget>[
              if (onPrevious != null || onNext != null)
                _NavButton(icon: IddsIcons.chevronLeft, label: 'Sebelumnya', onTap: onPrevious)
              else
                const SizedBox(width: 28),
              Expanded(
                child: Center(
                  child: _HeaderButton(label: title, semanticLabel: 'Kembali ke kalender', onTap: onBack),
                ),
              ),
              if (onPrevious != null || onNext != null)
                _NavButton(icon: IddsIcons.chevronRight, label: 'Berikutnya', onTap: onNext)
              else
                const SizedBox(width: 28),
            ],
          ),
        ),
        const SizedBox(height: IddsSpacing.s12),
        for (int r = 0; r < rows; r++)
          Padding(
            padding: const EdgeInsets.only(bottom: IddsSpacing.s4),
            child: Row(
              spacing: IddsSpacing.s4,
              children: <Widget>[
                for (int i = r * crossAxisCount; i < (r + 1) * crossAxisCount; i++)
                  Expanded(
                    child: i < items.length ? _PickerCell(item: items[i]) : const SizedBox(),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PickerCell extends StatelessWidget {
  const _PickerCell({required this.item});

  final _PickerItem item;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
    return Semantics(
      button: true,
      selected: item.selected,
      enabled: item.enabled,
      label: item.semanticLabel ?? item.label,
      onTap: item.enabled ? item.onTap : null,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: item.enabled ? item.onTap : null,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: radius,
          rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.strokeTertiary)],
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.selected
                  ? c.primaryMain
                  : state.hovered
                      ? (theme.isDark ? c.backgroundSecondary : c.backgroundTertiary)
                      : null,
              borderRadius: radius,
            ),
            child: Text(
              item.label,
              style: theme.textStyle(
                fontSize: IddsFontSize.xs,
                lineHeight: IddsLineHeight.xs,
                fontWeight: item.current || item.selected ? IddsFontWeight.semibold : IddsFontWeight.medium,
                color: item.selected
                    ? c.onPrimary
                    : item.enabled
                        ? c.contentPrimary
                        : c.contentTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
