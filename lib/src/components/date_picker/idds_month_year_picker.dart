import 'package:flutter/widgets.dart';

import '../../foundation/idds_date_utils.dart';
import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_popover.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../dropdown/idds_dropdown_trigger.dart';

/// Kolom pilih bulan (Month Picker IDDS). Nilai 1 (Januari) sampai 12.
///
/// ```dart
/// IddsMonthPicker(value: _month, onChanged: (m) => setState(() => _month = m))
/// ```
class IddsMonthPicker extends StatelessWidget {
  /// Membuat month picker.
  const IddsMonthPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pilih bulan',
    this.size = IddsDropdownSize.md,
    this.firstMonth,
    this.lastMonth,
    this.showIcon = true,
    this.clearable = false,
    this.shortNames = false,
    this.width,
  });

  /// Bulan terpilih (1–12).
  final int? value;

  /// Dipanggil dengan bulan baru, atau `null` saat dihapus. `null` membuat
  /// kolom nonaktif.
  final ValueChanged<int?>? onChanged;

  /// Teks saat kosong.
  final String placeholder;

  /// Ukuran.
  final IddsDropdownSize size;

  /// Bulan paling awal yang bisa dipilih.
  final int? firstMonth;

  /// Bulan paling akhir yang bisa dipilih.
  final int? lastMonth;

  /// Tampilkan ikon kalender.
  final bool showIcon;

  /// Tampilkan tombol hapus.
  final bool clearable;

  /// Tampilkan nama singkat (Jan, Feb) di kolom.
  final bool shortNames;

  /// Lebar kolom.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final int? v = value;
    return _GridPickerField(
      text: v == null ? null : (shortNames ? IddsDateNames.shortMonths : IddsDateNames.months)[v - 1],
      placeholder: placeholder,
      size: size,
      showIcon: showIcon,
      clearable: clearable,
      width: width,
      onClear: onChanged == null ? null : () => onChanged!(null),
      panelBuilder: onChanged == null
          ? null
          : (BuildContext context, VoidCallback close) => _Grid(
                columns: 3,
                cells: <_Cell>[
                  for (int m = 1; m <= 12; m++)
                    _Cell(
                      label: IddsDateNames.shortMonths[m - 1],
                      semanticLabel: IddsDateNames.months[m - 1],
                      selected: m == v,
                      enabled: (firstMonth == null || m >= firstMonth!) && (lastMonth == null || m <= lastMonth!),
                      onTap: () {
                        onChanged!(m);
                        close();
                      },
                    ),
                ],
              ),
    );
  }
}

/// Kolom pilih tahun (Year Picker IDDS) dengan halaman 20 tahun.
class IddsYearPicker extends StatelessWidget {
  /// Membuat year picker.
  const IddsYearPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pilih tahun',
    this.size = IddsDropdownSize.md,
    this.firstYear = 1900,
    this.lastYear = 2100,
    this.yearsPerPage = 20,
    this.showIcon = true,
    this.clearable = false,
    this.width,
  });

  /// Tahun terpilih.
  final int? value;

  /// Dipanggil dengan tahun baru, atau `null` saat dihapus. `null` membuat
  /// kolom nonaktif.
  final ValueChanged<int?>? onChanged;

  /// Teks saat kosong.
  final String placeholder;

  /// Ukuran.
  final IddsDropdownSize size;

  /// Tahun paling awal.
  final int firstYear;

  /// Tahun paling akhir.
  final int lastYear;

  /// Jumlah tahun per halaman.
  final int yearsPerPage;

  /// Tampilkan ikon kalender.
  final bool showIcon;

  /// Tampilkan tombol hapus.
  final bool clearable;

  /// Lebar kolom.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return _GridPickerField(
      text: value?.toString(),
      placeholder: placeholder,
      size: size,
      showIcon: showIcon,
      clearable: clearable,
      width: width,
      onClear: onChanged == null ? null : () => onChanged!(null),
      panelBuilder: onChanged == null
          ? null
          : (BuildContext context, VoidCallback close) => _YearGrid(
                value: value,
                firstYear: firstYear,
                lastYear: lastYear,
                yearsPerPage: yearsPerPage,
                onSelect: (int y) {
                  onChanged!(y);
                  close();
                },
              ),
    );
  }
}

class _YearGrid extends StatefulWidget {
  const _YearGrid({
    required this.value,
    required this.firstYear,
    required this.lastYear,
    required this.yearsPerPage,
    required this.onSelect,
  });

  final int? value;
  final int firstYear;
  final int lastYear;
  final int yearsPerPage;
  final ValueChanged<int> onSelect;

  @override
  State<_YearGrid> createState() => _YearGridState();
}

class _YearGridState extends State<_YearGrid> {
  late int _start = _pageStart(widget.value ?? DateTime.now().year);

  int _pageStart(int year) {
    final int y = year.clamp(widget.firstYear, widget.lastYear);
    return y - ((y - widget.firstYear) % widget.yearsPerPage);
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final int end = (_start + widget.yearsPerPage - 1).clamp(widget.firstYear, widget.lastYear);
    final bool small = iddsScreenWidth(context) < IddsBreakpoint.sm;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s8, vertical: IddsSpacing.s8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.strokePrimary))),
          child: Row(
            children: <Widget>[
              _NavButton(
                icon: IddsIcons.chevronLeft,
                label: 'Tahun sebelumnya',
                onTap: _start > widget.firstYear ? () => setState(() => _start -= widget.yearsPerPage) : null,
              ),
              Expanded(
                child: Text(
                  '$_start – $end',
                  textAlign: TextAlign.center,
                  style: theme.textStyle(
                    fontSize: IddsFontSize.xs,
                    lineHeight: IddsLineHeight.xs,
                    fontWeight: IddsFontWeight.medium,
                    color: c.contentPrimary,
                  ),
                ),
              ),
              _NavButton(
                icon: IddsIcons.chevronRight,
                label: 'Tahun berikutnya',
                onTap: end < widget.lastYear ? () => setState(() => _start += widget.yearsPerPage) : null,
              ),
            ],
          ),
        ),
        _Grid(
          columns: small ? 3 : 5,
          cells: <_Cell>[
            for (int y = _start; y <= end; y++)
              _Cell(
                label: '$y',
                selected: y == widget.value,
                enabled: true,
                onTap: () => widget.onSelect(y),
              ),
          ],
        ),
      ],
    );
  }
}

/// Kolom pemicu + panel grid bersama untuk Month/Year Picker.
class _GridPickerField extends StatefulWidget {
  const _GridPickerField({
    required this.text,
    required this.placeholder,
    required this.size,
    required this.showIcon,
    required this.clearable,
    required this.width,
    required this.onClear,
    required this.panelBuilder,
  });

  final String? text;
  final String placeholder;
  final IddsDropdownSize size;
  final bool showIcon;
  final bool clearable;
  final double? width;
  final VoidCallback? onClear;
  final Widget Function(BuildContext context, VoidCallback close)? panelBuilder;

  @override
  State<_GridPickerField> createState() => _GridPickerFieldState();
}

class _GridPickerFieldState extends State<_GridPickerField> {
  bool _open = false;
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final IddsDropdownMetrics m = IddsDropdownMetrics.of(context, widget.size);
    final bool enabled = widget.panelBuilder != null;
    final String? text = widget.text;

    final Widget trigger = Semantics(
      button: true,
      enabled: enabled,
      value: text ?? '',
      hint: text == null ? widget.placeholder : null,
      onTap: enabled ? () => setState(() => _open = !_open) : null,
      child: IddsInteractive(
        focusNode: _focus,
        onTap: enabled ? () => setState(() => _open = !_open) : null,
        builder: (BuildContext context, IddsInteractionState state) => IddsDropdownTriggerBox(
          state: state,
          open: _open,
          metrics: m,
          prefix: widget.showIcon ? IddsIcon(IddsIcons.calendar, size: m.iconSize, color: c.contentSecondary) : null,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(text ?? widget.placeholder, style: TextStyle(color: text == null ? c.contentTertiary : null)),
              ),
              if (widget.clearable && text != null && enabled && widget.onClear != null)
                Semantics(
                  button: true,
                  label: 'Hapus',
                  onTap: widget.onClear,
                  excludeSemantics: true,
                  child: IddsInteractive(
                    onTap: widget.onClear,
                    builder: (BuildContext context, IddsInteractionState s) =>
                        IddsIcon(IddsIcons.x, size: 16, color: s.hovered ? c.contentPrimary : c.contentSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    final Widget field = IddsPopover(
      open: _open,
      onDismiss: _close,
      matchAnchorWidth: true,
      minWidth: 240,
      panelBuilder: (BuildContext context) => IddsPopoverSurface(child: widget.panelBuilder!(context, _close)),
      child: trigger,
    );
    if (widget.width != null) return SizedBox(width: widget.width, child: field);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          constraints.hasBoundedWidth ? field : SizedBox(width: 200, child: field),
    );
  }
}

class _Cell {
  const _Cell({required this.label, required this.selected, required this.enabled, required this.onTap, this.semanticLabel});

  final String label;
  final String? semanticLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.cells});

  final int columns;
  final List<_Cell> cells;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final int rows = (cells.length / columns).ceil();
    return Padding(
      padding: const EdgeInsets.all(IddsSpacing.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: IddsSpacing.s4,
        children: <Widget>[
          for (int r = 0; r < rows; r++)
            Row(
              spacing: IddsSpacing.s4,
              children: <Widget>[
                for (int i = r * columns; i < (r + 1) * columns; i++)
                  Expanded(
                    child: i >= cells.length
                        ? const SizedBox()
                        : Semantics(
                            button: true,
                            selected: cells[i].selected,
                            enabled: cells[i].enabled,
                            label: cells[i].semanticLabel ?? cells[i].label,
                            onTap: cells[i].enabled ? cells[i].onTap : null,
                            excludeSemantics: true,
                            child: IddsInteractive(
                              onTap: cells[i].enabled ? cells[i].onTap : null,
                              builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
                                visible: state.focused,
                                borderRadius: BorderRadius.circular(IddsRadius.md),
                                rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.strokeTertiary)],
                                child: Container(
                                  height: 36,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    // CSS: terpilih primary-primary; teks onPrimary (base-white
                                    // tidak terbaca di brand Neutral mode gelap).
                                    color: cells[i].selected
                                        ? c.primaryMain
                                        : !cells[i].enabled
                                            ? c.backgroundSecondary
                                            : state.hovered
                                                ? c.backgroundSecondary
                                                : null,
                                    borderRadius: BorderRadius.circular(IddsRadius.md),
                                  ),
                                  child: Opacity(
                                    opacity: cells[i].enabled ? 1 : 0.4,
                                    child: Text(
                                      cells[i].label,
                                      style: theme.textStyle(
                                        fontSize: IddsFontSize.xs,
                                        lineHeight: IddsLineHeight.xs,
                                        fontWeight: IddsFontWeight.medium,
                                        color: cells[i].selected
                                            ? c.onPrimary
                                            : cells[i].enabled
                                                ? c.contentPrimary
                                                : c.contentTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
              ],
            ),
        ],
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
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: state.hovered || state.focused ? c.backgroundSecondary : null,
            borderRadius: BorderRadius.circular(IddsRadius.base),
            border: state.focused ? Border.all(color: c.contentSecondary, width: 2) : null,
          ),
          child: Opacity(opacity: onTap == null ? 0.5 : 1, child: IddsIcon(icon, size: 20, color: c.contentPrimary)),
        ),
      ),
    );
  }
}
