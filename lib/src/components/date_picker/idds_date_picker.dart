import 'dart:math' as math;

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
import 'idds_calendar.dart';

/// Kolom pilih satu tanggal. Panel tertutup setelah tanggal dipilih.
///
/// ```dart
/// IddsDatePicker(
///   label: const Text('Tanggal lahir'),
///   value: _birthDate,
///   onChanged: (d) => setState(() => _birthDate = d),
///   disableFuture: true,
/// )
/// ```
class IddsDatePicker extends StatelessWidget {
  /// Membuat date picker.
  const IddsDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pilih tanggal',
    this.dateFormat = 'dd/MM/yyyy',
    this.size = IddsDropdownSize.md,
    this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.readOnly = false,
    this.firstDate,
    this.lastDate,
    this.disablePast = false,
    this.disableFuture = false,
    this.selectableDayPredicate,
    this.firstDayOfWeek = DateTime.sunday,
    this.currentDate,
    this.width,
    this.placement = IddsPopoverPlacement.bottomStart,
    this.clearLabel = 'Hapus tanggal terpilih',
  });

  /// Tanggal terpilih.
  final DateTime? value;

  /// Dipanggil dengan tanggal baru, atau `null` saat dihapus. `null`
  /// membuat kolom nonaktif.
  final ValueChanged<DateTime?>? onChanged;

  /// Teks saat kosong.
  final String placeholder;

  /// Pola tampilan tanggal; lihat [iddsFormatDate].
  final String dateFormat;

  /// Ukuran kolom.
  final IddsDropdownSize size;

  /// Label di atas kolom.
  final Widget? label;

  /// Tampilkan tanda wajib (*).
  final bool required;

  /// Teks bantuan.
  final String? helperText;

  /// Pesan error; kolom ditampilkan dalam status error.
  final String? errorText;

  /// Hanya-baca: nilai tampil tetapi panel tidak bisa dibuka.
  final bool readOnly;

  /// Tanggal paling awal yang bisa dipilih.
  final DateTime? firstDate;

  /// Tanggal paling akhir yang bisa dipilih.
  final DateTime? lastDate;

  /// Nonaktifkan tanggal sebelum hari ini.
  final bool disablePast;

  /// Nonaktifkan tanggal setelah hari ini.
  final bool disableFuture;

  /// Aturan tambahan; kembalikan `false` untuk menonaktifkan tanggal.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Hari pertama dalam minggu. Bawaan Minggu, sama seperti IDDS.
  final int firstDayOfWeek;

  /// Tanggal "hari ini". Bawaan: `DateTime.now()`.
  final DateTime? currentDate;

  /// Lebar kolom. Bila `null`, mengikuti lebar yang tersedia.
  final double? width;

  /// Posisi panel.
  final IddsPopoverPlacement placement;

  /// Label pembaca layar untuk tombol hapus.
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<DateTime?>? onChanged = this.onChanged;
    final DateTime? value = this.value;
    return _DateField(
      mode: IddsCalendarMode.single,
      selected: <DateTime>[if (value != null) value],
      text: value == null ? null : iddsFormatDate(value, dateFormat),
      onCalendarChanged: onChanged == null
          ? null
          : (List<DateTime> days, VoidCallback close) {
              onChanged(days.isEmpty ? null : days.first);
              close();
            },
      onClear: onChanged == null ? null : () => onChanged(null),
      common: _Common.from(this),
    );
  }
}

/// Kolom pilih rentang tanggal. Tekan tanggal awal lalu tanggal akhir; panel
/// tertutup saat rentang lengkap.
///
/// Di layar ≥ 768px dua bulan ditampilkan berdampingan.
class IddsDateRangePicker extends StatelessWidget {
  /// Membuat date range picker.
  const IddsDateRangePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pilih rentang tanggal',
    this.dateFormat = 'dd/MM/yyyy',
    this.size = IddsDropdownSize.md,
    this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.readOnly = false,
    this.firstDate,
    this.lastDate,
    this.disablePast = false,
    this.disableFuture = false,
    this.selectableDayPredicate,
    this.firstDayOfWeek = DateTime.sunday,
    this.currentDate,
    this.width,
    this.placement = IddsPopoverPlacement.bottomStart,
    this.clearLabel = 'Hapus tanggal terpilih',
    this.monthCount,
  });

  /// Rentang terpilih. [IddsDateRange.end] `null` berarti baru tanggal awal
  /// yang dipilih.
  final IddsDateRange? value;

  /// Dipanggil dengan rentang baru (termasuk rentang yang baru berisi tanggal
  /// awal), atau `null` saat dihapus. `null` membuat kolom nonaktif.
  final ValueChanged<IddsDateRange?>? onChanged;

  /// Lihat [IddsDatePicker.placeholder].
  final String placeholder;

  /// Lihat [IddsDatePicker.dateFormat].
  final String dateFormat;

  /// Lihat [IddsDatePicker.size].
  final IddsDropdownSize size;

  /// Lihat [IddsDatePicker.label].
  final Widget? label;

  /// Lihat [IddsDatePicker.required].
  final bool required;

  /// Lihat [IddsDatePicker.helperText].
  final String? helperText;

  /// Lihat [IddsDatePicker.errorText].
  final String? errorText;

  /// Lihat [IddsDatePicker.readOnly].
  final bool readOnly;

  /// Lihat [IddsDatePicker.firstDate].
  final DateTime? firstDate;

  /// Lihat [IddsDatePicker.lastDate].
  final DateTime? lastDate;

  /// Lihat [IddsDatePicker.disablePast].
  final bool disablePast;

  /// Lihat [IddsDatePicker.disableFuture].
  final bool disableFuture;

  /// Lihat [IddsDatePicker.selectableDayPredicate].
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Lihat [IddsDatePicker.firstDayOfWeek].
  final int firstDayOfWeek;

  /// Lihat [IddsDatePicker.currentDate].
  final DateTime? currentDate;

  /// Lihat [IddsDatePicker.width].
  final double? width;

  /// Lihat [IddsDatePicker.placement].
  final IddsPopoverPlacement placement;

  /// Lihat [IddsDatePicker.clearLabel].
  final String clearLabel;

  /// Jumlah bulan di panel; lihat [IddsCalendar.monthCount].
  final int? monthCount;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<IddsDateRange?>? onChanged = this.onChanged;
    final IddsDateRange? value = this.value;
    String? text;
    if (value != null) {
      final String start = iddsFormatDate(value.start, dateFormat);
      text = value.end == null ? '$start - ' : '$start - ${iddsFormatDate(value.end!, dateFormat)}';
    }
    return _DateField(
      mode: IddsCalendarMode.range,
      selected: <DateTime>[if (value != null) value.start, if (value?.end != null) value!.end!],
      text: text,
      monthCount: monthCount,
      onCalendarChanged: onChanged == null
          ? null
          : (List<DateTime> days, VoidCallback close) {
              if (days.isEmpty) {
                onChanged(null);
                return;
              }
              final IddsDateRange range = IddsDateRange(start: days.first, end: days.length > 1 ? days[1] : null);
              onChanged(range);
              if (range.isComplete) close();
            },
      onClear: onChanged == null ? null : () => onChanged(null),
      common: _Common.fromRange(this),
    );
  }
}

/// Kolom pilih banyak tanggal. Panel tetap terbuka; menekan tanggal terpilih
/// membatalkannya.
///
/// Teks kolom berisi tanggal yang dipisah koma (sampai 3), lalu "n tanggal
/// dipilih".
class IddsMultiDatePicker extends StatelessWidget {
  /// Membuat multi date picker.
  const IddsMultiDatePicker({
    super.key,
    required this.values,
    required this.onChanged,
    this.placeholder = 'Pilih tanggal',
    this.dateFormat = 'dd/MM/yyyy',
    this.size = IddsDropdownSize.md,
    this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.readOnly = false,
    this.firstDate,
    this.lastDate,
    this.disablePast = false,
    this.disableFuture = false,
    this.selectableDayPredicate,
    this.firstDayOfWeek = DateTime.sunday,
    this.currentDate,
    this.width,
    this.placement = IddsPopoverPlacement.bottomStart,
    this.clearLabel = 'Hapus tanggal terpilih',
    this.monthCount,
    this.selectionText,
  });

  /// Tanggal terpilih, sesuai urutan dipilih.
  final List<DateTime> values;

  /// Dipanggil dengan daftar baru. `null` membuat kolom nonaktif.
  final ValueChanged<List<DateTime>>? onChanged;

  /// Lihat [IddsDatePicker.placeholder].
  final String placeholder;

  /// Lihat [IddsDatePicker.dateFormat].
  final String dateFormat;

  /// Lihat [IddsDatePicker.size].
  final IddsDropdownSize size;

  /// Lihat [IddsDatePicker.label].
  final Widget? label;

  /// Lihat [IddsDatePicker.required].
  final bool required;

  /// Lihat [IddsDatePicker.helperText].
  final String? helperText;

  /// Lihat [IddsDatePicker.errorText].
  final String? errorText;

  /// Lihat [IddsDatePicker.readOnly].
  final bool readOnly;

  /// Lihat [IddsDatePicker.firstDate].
  final DateTime? firstDate;

  /// Lihat [IddsDatePicker.lastDate].
  final DateTime? lastDate;

  /// Lihat [IddsDatePicker.disablePast].
  final bool disablePast;

  /// Lihat [IddsDatePicker.disableFuture].
  final bool disableFuture;

  /// Lihat [IddsDatePicker.selectableDayPredicate].
  final bool Function(DateTime day)? selectableDayPredicate;

  /// Lihat [IddsDatePicker.firstDayOfWeek].
  final int firstDayOfWeek;

  /// Lihat [IddsDatePicker.currentDate].
  final DateTime? currentDate;

  /// Lihat [IddsDatePicker.width].
  final double? width;

  /// Lihat [IddsDatePicker.placement].
  final IddsPopoverPlacement placement;

  /// Lihat [IddsDatePicker.clearLabel].
  final String clearLabel;

  /// Jumlah bulan di panel; lihat [IddsCalendar.monthCount].
  final int? monthCount;

  /// Teks bila lebih dari 3 tanggal. Bawaan: "n tanggal dipilih".
  final String Function(int count)? selectionText;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<List<DateTime>>? onChanged = this.onChanged;
    String? text;
    if (values.length > 3) {
      text = selectionText?.call(values.length) ?? '${values.length} tanggal dipilih';
    } else if (values.isNotEmpty) {
      text = values.map((DateTime d) => iddsFormatDate(d, dateFormat)).join(', ');
    }
    return _DateField(
      mode: IddsCalendarMode.multiple,
      selected: values,
      text: text,
      monthCount: monthCount,
      onCalendarChanged: onChanged == null ? null : (List<DateTime> days, VoidCallback close) => onChanged(days),
      onClear: onChanged == null ? null : () => onChanged(<DateTime>[]),
      common: _Common.fromMulti(this),
    );
  }
}

/// Pengaturan yang sama di ketiga picker.
class _Common {
  const _Common({
    required this.placeholder,
    required this.size,
    required this.label,
    required this.required,
    required this.helperText,
    required this.errorText,
    required this.readOnly,
    required this.firstDate,
    required this.lastDate,
    required this.disablePast,
    required this.disableFuture,
    required this.selectableDayPredicate,
    required this.firstDayOfWeek,
    required this.currentDate,
    required this.width,
    required this.placement,
    required this.clearLabel,
  });

  _Common.from(IddsDatePicker w)
      : this(
          placeholder: w.placeholder,
          size: w.size,
          label: w.label,
          required: w.required,
          helperText: w.helperText,
          errorText: w.errorText,
          readOnly: w.readOnly,
          firstDate: w.firstDate,
          lastDate: w.lastDate,
          disablePast: w.disablePast,
          disableFuture: w.disableFuture,
          selectableDayPredicate: w.selectableDayPredicate,
          firstDayOfWeek: w.firstDayOfWeek,
          currentDate: w.currentDate,
          width: w.width,
          placement: w.placement,
          clearLabel: w.clearLabel,
        );

  _Common.fromRange(IddsDateRangePicker w)
      : this(
          placeholder: w.placeholder,
          size: w.size,
          label: w.label,
          required: w.required,
          helperText: w.helperText,
          errorText: w.errorText,
          readOnly: w.readOnly,
          firstDate: w.firstDate,
          lastDate: w.lastDate,
          disablePast: w.disablePast,
          disableFuture: w.disableFuture,
          selectableDayPredicate: w.selectableDayPredicate,
          firstDayOfWeek: w.firstDayOfWeek,
          currentDate: w.currentDate,
          width: w.width,
          placement: w.placement,
          clearLabel: w.clearLabel,
        );

  _Common.fromMulti(IddsMultiDatePicker w)
      : this(
          placeholder: w.placeholder,
          size: w.size,
          label: w.label,
          required: w.required,
          helperText: w.helperText,
          errorText: w.errorText,
          readOnly: w.readOnly,
          firstDate: w.firstDate,
          lastDate: w.lastDate,
          disablePast: w.disablePast,
          disableFuture: w.disableFuture,
          selectableDayPredicate: w.selectableDayPredicate,
          firstDayOfWeek: w.firstDayOfWeek,
          currentDate: w.currentDate,
          width: w.width,
          placement: w.placement,
          clearLabel: w.clearLabel,
        );

  final String placeholder;
  final IddsDropdownSize size;
  final Widget? label;
  final bool required;
  final String? helperText;
  final String? errorText;
  final bool readOnly;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool disablePast;
  final bool disableFuture;
  final bool Function(DateTime day)? selectableDayPredicate;
  final int firstDayOfWeek;
  final DateTime? currentDate;
  final double? width;
  final IddsPopoverPlacement placement;
  final String clearLabel;
}

class _DateField extends StatefulWidget {
  const _DateField({
    required this.mode,
    required this.selected,
    required this.text,
    required this.onCalendarChanged,
    required this.onClear,
    required this.common,
    this.monthCount,
  });

  final IddsCalendarMode mode;
  final List<DateTime> selected;
  final String? text;
  final void Function(List<DateTime> days, VoidCallback close)? onCalendarChanged;
  final VoidCallback? onClear;
  final _Common common;
  final int? monthCount;

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  bool _open = false;
  final FocusNode _triggerFocus = FocusNode(debugLabel: 'IddsDatePicker');
  final FocusNode _calendarFocus = FocusNode(debugLabel: 'IddsDatePicker calendar');

  bool get _enabled => widget.onCalendarChanged != null;

  bool get _canOpen => _enabled && !widget.common.readOnly;

  @override
  void didUpdateWidget(_DateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_canOpen && _open) _open = false;
  }

  @override
  void dispose() {
    _triggerFocus.dispose();
    _calendarFocus.dispose();
    super.dispose();
  }

  void _toggle() => _open ? _close() : setState(() => _open = true);

  void _close() {
    if (!_open) return;
    final bool refocus = _calendarFocus.hasFocus;
    setState(() => _open = false);
    if (refocus) _triggerFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final _Common o = widget.common;
    final IddsDropdownMetrics m = IddsDropdownMetrics.of(context, o.size);
    final DateTime today = iddsDateOnly(o.currentDate ?? DateTime.now());
    DateTime? firstDate = o.firstDate == null ? null : iddsDateOnly(o.firstDate!);
    DateTime? lastDate = o.lastDate == null ? null : iddsDateOnly(o.lastDate!);
    if (o.disablePast) firstDate = firstDate == null || firstDate.isBefore(today) ? today : firstDate;
    if (o.disableFuture) lastDate = lastDate == null || lastDate.isAfter(today) ? today : lastDate;
    final bool hasError = o.errorText != null;
    final bool showClear = widget.text != null && _canOpen && widget.onClear != null;

    final Widget trigger = Semantics(
      button: true,
      enabled: _canOpen,
      readOnly: o.readOnly,
      value: widget.text ?? '',
      hint: widget.text == null ? o.placeholder : null,
      onTap: _canOpen ? _toggle : null,
      child: IddsInteractive(
        focusNode: _triggerFocus,
        onTap: _canOpen ? _toggle : null,
        builder: (BuildContext context, IddsInteractionState state) {
          final bool active = state.focused || _open;
          final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
          final Color border = hasError
              ? c.negative.shade500
              : active
                  ? c.strokeTertiary
                  : c.strokePrimary;
          final Color background = !_enabled || o.readOnly
              ? c.backgroundSecondary
              : state.hovered && !_open
                  ? c.backgroundSecondary
                  : c.backgroundPrimary;
          return Opacity(
            opacity: _enabled ? 1 : 0.6,
            child: IddsInsetRing(
              visible: state.enabled && active,
              borderRadius: radius,
              inset: 1,
              rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, hasError ? c.negative.shade500 : c.contentPrimary)],
              child: AnimatedContainer(
                duration: IddsDuration.base,
                curve: IddsCurves.standard,
                height: m.height,
                padding: EdgeInsets.symmetric(horizontal: (m.small ? IddsSpacing.s8 : IddsSpacing.s12) - 1),
                decoration: BoxDecoration(color: background, borderRadius: radius, border: Border.all(color: border)),
                child: Row(
                  spacing: m.small ? 6 : IddsSpacing.s8,
                  children: <Widget>[
                    IddsIcon(IddsIcons.calendar, size: m.small ? 18 : 20, color: c.contentTertiary),
                    Expanded(
                      child: Text(
                        widget.text ?? o.placeholder,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textStyle(
                          fontSize: m.fontSize,
                          lineHeight: m.lineHeight,
                          color: widget.text == null ? c.contentTertiary : c.contentPrimary,
                        ),
                      ),
                    ),
                    if (showClear) _ClearButton(label: o.clearLabel, size: m.small ? 14 : 16, onTap: widget.onClear!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    final Widget popover = IddsPopover(
      open: _open,
      onDismiss: _close,
      placement: o.placement,
      maxHeight: 440,
      panelBuilder: (BuildContext context) => _FocusOnMount(
        node: _calendarFocus,
        child: IddsPopoverSurface(
          radius: IddsRadius.xl,
          padding: EdgeInsets.all(m.small ? IddsSpacing.s12 : IddsSpacing.s16),
          child: SingleChildScrollView(
            child: Center(
              child: IddsCalendar(
                mode: widget.mode,
                selected: widget.selected,
                focusNode: _calendarFocus,
                firstDate: firstDate,
                lastDate: lastDate,
                selectableDayPredicate: o.selectableDayPredicate,
                firstDayOfWeek: o.firstDayOfWeek,
                currentDate: o.currentDate,
                monthCount: widget.monthCount,
                onChanged: widget.onCalendarChanged == null
                    ? null
                    : (List<DateTime> days) => widget.onCalendarChanged!(days, _close),
              ),
            ),
          ),
        ),
      ),
      child: trigger,
    );

    final String? message = o.errorText ?? o.helperText;
    final Widget field = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (o.label != null) IddsFieldLabel(label: o.label!, required: o.required, small: m.small),
        popover,
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: IddsSpacing.s4),
            child: Text(
              message,
              style: theme.textStyle(
                fontSize: IddsFontSize.xs,
                lineHeight: IddsLineHeight.xs,
                color: hasError ? c.negative.shade500 : c.contentSecondary,
              ),
            ),
          ),
      ],
    );

    if (o.width != null) return SizedBox(width: o.width, child: field);
    // CSS: lebar minimal 200px; di dalam Row tanpa batas lebar dipakai 280px.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => constraints.hasBoundedWidth
          ? ConstrainedBox(
              constraints: BoxConstraints(minWidth: math.min(200, constraints.maxWidth)),
              child: field,
            )
          : SizedBox(width: 280, child: field),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.label, required this.size, required this.onTap});

  final String label;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(IddsRadius.sm),
          rings: <(double, Color)>[(2.0, c.contentPrimary)],
          child: IddsIcon(
            IddsIcons.x,
            size: size,
            color: state.hovered ? c.contentPrimary : c.contentSecondary,
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
