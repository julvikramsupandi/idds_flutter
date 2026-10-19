import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_popover.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../dropdown/idds_dropdown_trigger.dart';
import '../text_field/idds_text_field.dart' show IddsTextFieldStatus;

/// Waktu dalam sehari (jam 0–23, menit, detik).
@immutable
class IddsTime implements Comparable<IddsTime> {
  /// Membuat waktu.
  const IddsTime(this.hour, this.minute, [this.second = 0])
      : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60),
        assert(second >= 0 && second < 60);

  /// Waktu dari [DateTime].
  factory IddsTime.fromDateTime(DateTime t) => IddsTime(t.hour, t.minute, t.second);

  /// Waktu sekarang.
  factory IddsTime.now() => IddsTime.fromDateTime(DateTime.now());

  /// Membaca `HH:mm` atau `HH:mm:ss`. `null` bila tidak valid.
  static IddsTime? tryParse(String text) {
    final RegExpMatch? m = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(text.trim());
    if (m == null) return null;
    final int h = int.parse(m.group(1)!);
    final int min = int.parse(m.group(2)!);
    final int s = m.group(3) == null ? 0 : int.parse(m.group(3)!);
    if (h > 23 || min > 59 || s > 59) return null;
    return IddsTime(h, min, s);
  }

  /// Jam (0–23).
  final int hour;

  /// Menit.
  final int minute;

  /// Detik.
  final int second;

  /// Jumlah detik sejak tengah malam.
  int get inSeconds => hour * 3600 + minute * 60 + second;

  /// Format `HH:mm`, `HH:mm:ss`, atau 12 jam `h:mm AM`.
  String format({bool showSeconds = false, bool use12Hours = false}) {
    String two(int v) => v.toString().padLeft(2, '0');
    final String sec = showSeconds ? ':${two(second)}' : '';
    if (!use12Hours) return '${two(hour)}:${two(minute)}$sec';
    final int h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h:${two(minute)}$sec ${hour < 12 ? 'AM' : 'PM'}';
  }

  /// Salinan dengan perubahan.
  IddsTime copyWith({int? hour, int? minute, int? second}) =>
      IddsTime(hour ?? this.hour, minute ?? this.minute, second ?? this.second);

  @override
  int compareTo(IddsTime other) => inSeconds.compareTo(other.inSeconds);

  @override
  bool operator ==(Object other) => other is IddsTime && other.inSeconds == inSeconds;

  @override
  int get hashCode => inSeconds;

  @override
  String toString() => format(showSeconds: true);
}

/// Kolom pilih waktu (Time Picker IDDS): jam, menit, dan opsional detik
/// atau AM/PM, dengan tombol "Sekarang" dan "Pilih".
///
/// Pilihan di panel baru disimpan setelah "Pilih" ditekan; menekan di luar
/// atau Esc membatalkannya.
class IddsTimePicker extends StatefulWidget {
  /// Membuat time picker.
  const IddsTimePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.required = false,
    this.placeholder = 'Pilih waktu',
    this.helperText,
    this.status = IddsTextFieldStatus.neutral,
    this.statusMessage,
    this.size = IddsDropdownSize.md,
    this.showSeconds = false,
    this.use12Hours = false,
    this.hourStep = 1,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.minTime,
    this.maxTime,
    this.showNowButton = true,
    this.nowLabel = 'Sekarang',
    this.confirmLabel = 'Pilih',
    this.clearLabel = 'Hapus waktu',
    this.width,
  });

  /// Waktu terpilih.
  final IddsTime? value;

  /// Dipanggil dengan waktu baru, atau `null` saat dihapus. `null` membuat
  /// kolom nonaktif.
  final ValueChanged<IddsTime?>? onChanged;

  /// Label di atas kolom.
  final Widget? label;

  /// Tampilkan tanda wajib (*).
  final bool required;

  /// Teks saat kosong.
  final String placeholder;

  /// Teks bantuan.
  final String? helperText;

  /// Status (warna garis tepi dan pesan).
  final IddsTextFieldStatus status;

  /// Pesan status.
  final String? statusMessage;

  /// Ukuran kolom.
  final IddsDropdownSize size;

  /// Tampilkan kolom detik.
  final bool showSeconds;

  /// Format 12 jam dengan AM/PM.
  final bool use12Hours;

  /// Langkah pilihan jam.
  final int hourStep;

  /// Langkah pilihan menit, misalnya 15 untuk 00, 15, 30, 45.
  final int minuteStep;

  /// Langkah pilihan detik.
  final int secondStep;

  /// Waktu paling awal yang bisa dipilih.
  final IddsTime? minTime;

  /// Waktu paling akhir yang bisa dipilih.
  final IddsTime? maxTime;

  /// Tampilkan tombol "Sekarang".
  final bool showNowButton;

  /// Teks tombol sekarang.
  final String nowLabel;

  /// Teks tombol konfirmasi.
  final String confirmLabel;

  /// Label pembaca layar tombol hapus.
  final String clearLabel;

  /// Lebar kolom. Bila `null`, mengikuti lebar yang tersedia.
  final double? width;

  @override
  State<IddsTimePicker> createState() => _IddsTimePickerState();
}

class _IddsTimePickerState extends State<IddsTimePicker> {
  static const double _itemExtent = 36;

  bool _open = false;
  IddsTime _draft = const IddsTime(0, 0);
  final FocusNode _triggerFocus = FocusNode(debugLabel: 'IddsTimePicker');

  bool get _enabled => widget.onChanged != null;

  @override
  void didUpdateWidget(IddsTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && _open) _open = false;
  }

  @override
  void dispose() {
    _triggerFocus.dispose();
    super.dispose();
  }

  bool _allowed(IddsTime t) {
    if (widget.minTime != null && t.compareTo(widget.minTime!) < 0) return false;
    if (widget.maxTime != null && t.compareTo(widget.maxTime!) > 0) return false;
    return true;
  }

  IddsTime _clamp(IddsTime t) {
    if (widget.minTime != null && t.compareTo(widget.minTime!) < 0) return widget.minTime!;
    if (widget.maxTime != null && t.compareTo(widget.maxTime!) > 0) return widget.maxTime!;
    return t;
  }

  void _toggle() {
    if (_open) {
      _close();
      return;
    }
    setState(() {
      _draft = _clamp(widget.value ?? (widget.minTime ?? const IddsTime(0, 0)));
      _open = true;
    });
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
  }

  void _commit(IddsTime time) {
    widget.onChanged?.call(time);
    _close();
    _triggerFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final IddsDropdownMetrics m = IddsDropdownMetrics.of(context, widget.size);
    final IddsTime? value = widget.value;
    final String? text = value?.format(showSeconds: widget.showSeconds, use12Hours: widget.use12Hours);
    final bool hasError = widget.status == IddsTextFieldStatus.error;
    final Color statusColor = switch (widget.status) {
      IddsTextFieldStatus.error => c.negative.shade600,
      IddsTextFieldStatus.success => c.positive.shade600,
      IddsTextFieldStatus.warning => c.warning.shade500,
      IddsTextFieldStatus.neutral => c.strokePrimary,
    };

    Widget fieldFor(double panelWidth) {
      final Widget trigger = Semantics(
        button: true,
        enabled: _enabled,
        value: text ?? '',
        hint: text == null ? widget.placeholder : null,
        onTap: _enabled ? _toggle : null,
        child: IddsInteractive(
          focusNode: _triggerFocus,
          onTap: _enabled ? _toggle : null,
          builder: (BuildContext context, IddsInteractionState state) {
            final bool active = state.focused || _open;
            final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
            final Color border = widget.status != IddsTextFieldStatus.neutral
                ? statusColor
                : active
                    ? c.strokeTertiary
                    : c.strokePrimary;
            return Opacity(
              opacity: _enabled ? 1 : 0.6,
              child: IddsInsetRing(
                visible: state.enabled && active,
                borderRadius: radius,
                inset: 1,
                rings: <(double, Color)>[
                  (2.0, c.backgroundPrimary),
                  (1.0, widget.status == IddsTextFieldStatus.neutral ? c.contentPrimary : statusColor),
                ],
                child: AnimatedContainer(
                  duration: IddsDuration.base,
                  height: m.height,
                  padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12 - 1),
                  decoration: BoxDecoration(
                    color: !_enabled
                        ? c.backgroundSecondary
                        : state.hovered && !_open
                            ? c.backgroundSecondary
                            : c.backgroundPrimary,
                    borderRadius: radius,
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    spacing: IddsSpacing.s8,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          text ?? widget.placeholder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textStyle(
                            fontSize: m.fontSize,
                            lineHeight: m.lineHeight,
                            color: text == null ? c.contentTertiary : c.contentPrimary,
                          ),
                        ),
                      ),
                      if (text != null && _enabled)
                        Semantics(
                          button: true,
                          label: widget.clearLabel,
                          onTap: () => widget.onChanged!(null),
                          excludeSemantics: true,
                          child: IddsInteractive(
                            onTap: () => widget.onChanged!(null),
                            builder: (BuildContext context, IddsInteractionState s) => IddsIcon(
                              IddsIcons.x,
                              size: 16,
                              color: s.hovered ? c.contentPrimary : c.contentSecondary,
                            ),
                          ),
                        ),
                      IddsIcon(IddsIcons.clock, size: 20, color: c.contentTertiary),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

      return IddsPopover(
        open: _open,
        onDismiss: _close,
        // Lebar tetap selebar kolom: kolom jam memakai ListView.
        width: panelWidth,
        matchAnchorWidth: false,
        maxHeight: 320,
        panelBuilder: (BuildContext context) => _buildPanel(context),
        child: trigger,
      );
    }

    final String? message = widget.statusMessage ?? widget.helperText;
    Widget column(double panelWidth) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.label != null) IddsFieldLabel(label: widget.label!, required: widget.required, small: m.small),
            fieldFor(panelWidth),
            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: IddsSpacing.s4),
                child: Text(
                  message,
                  style: theme.textStyle(
                    fontSize: IddsFontSize.xs,
                    lineHeight: IddsLineHeight.xs,
                    color: hasError
                        ? c.negative.shade500
                        : widget.status == IddsTextFieldStatus.success
                            ? c.positive.shade600
                            : widget.status == IddsTextFieldStatus.warning
                                ? c.warning.shade600
                                : c.contentSecondary,
                  ),
                ),
              ),
          ],
        );

    if (widget.width != null) return SizedBox(width: widget.width, child: column(math.max(widget.width!, 200)));
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (!constraints.hasBoundedWidth) return SizedBox(width: 240, child: column(240));
        return column(math.max(constraints.maxWidth, 200));
      },
    );
  }

  Widget _buildPanel(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool pm = _draft.hour >= 12;

    List<int> range(int count, int step) => <int>[for (int i = 0; i < count; i += math.max(1, step)) i];
    String two(int v) => v.toString().padLeft(2, '0');

    final List<int> hours = widget.use12Hours
        ? <int>[for (final int h in range(24, widget.hourStep)) if ((h >= 12) == pm) h]
        : range(24, widget.hourStep);

    final List<Widget> columns = <Widget>[
      _TimeColumn(
        label: 'Jam',
        values: hours,
        selected: _draft.hour,
        itemExtent: _itemExtent,
        labelOf: (int h) => widget.use12Hours ? '${h % 12 == 0 ? 12 : h % 12}' : two(h),
        enabledOf: (int h) => _allowed(_draft.copyWith(hour: h, minute: 0, second: 0)) ||
            _allowed(_draft.copyWith(hour: h, minute: 59, second: 59)),
        onSelect: (int h) => setState(() => _draft = _clamp(_draft.copyWith(hour: h))),
      ),
      _TimeColumn(
        label: 'Menit',
        values: range(60, widget.minuteStep),
        selected: _draft.minute,
        itemExtent: _itemExtent,
        labelOf: two,
        enabledOf: (int v) => _allowed(_draft.copyWith(minute: v, second: 0)) || _allowed(_draft.copyWith(minute: v, second: 59)),
        onSelect: (int v) => setState(() => _draft = _clamp(_draft.copyWith(minute: v))),
      ),
      if (widget.showSeconds)
        _TimeColumn(
          label: 'Detik',
          values: range(60, widget.secondStep),
          selected: _draft.second,
          itemExtent: _itemExtent,
          labelOf: two,
          enabledOf: (int v) => _allowed(_draft.copyWith(second: v)),
          onSelect: (int v) => setState(() => _draft = _draft.copyWith(second: v)),
        ),
      if (widget.use12Hours)
        _TimeColumn(
          label: 'AM/PM',
          values: const <int>[0, 1],
          selected: pm ? 1 : 0,
          itemExtent: _itemExtent,
          labelOf: (int v) => v == 0 ? 'AM' : 'PM',
          enabledOf: (int v) => true,
          onSelect: (int v) => setState(() {
            final int h = _draft.hour % 12 + (v == 1 ? 12 : 0);
            _draft = _clamp(_draft.copyWith(hour: h));
          }),
        ),
    ];

    final IddsTime now = _clamp(IddsTime.now());
    return IddsPopoverSurface(
      shadow: IddsShadow.lg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 224,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < columns.length; i++) ...<Widget>[
                  if (i > 0) Container(width: 1, color: c.strokePrimary),
                  Expanded(child: columns[i]),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12, vertical: IddsSpacing.s8),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.strokePrimary))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              spacing: IddsSpacing.s8,
              children: <Widget>[
                if (widget.showNowButton)
                  _PanelButton(label: widget.nowLabel, primary: false, onTap: () => _commit(now)),
                _PanelButton(label: widget.confirmLabel, primary: true, onTap: () => _commit(_draft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatefulWidget {
  const _TimeColumn({
    required this.label,
    required this.values,
    required this.selected,
    required this.itemExtent,
    required this.labelOf,
    required this.enabledOf,
    required this.onSelect,
  });

  final String label;
  final List<int> values;
  final int selected;
  final double itemExtent;
  final String Function(int value) labelOf;
  final bool Function(int value) enabledOf;
  final ValueChanged<int> onSelect;

  @override
  State<_TimeColumn> createState() => _TimeColumnState();
}

class _TimeColumnState extends State<_TimeColumn> {
  late final ScrollController _scroll = ScrollController(
    // Pilihan awal tampil di bagian atas daftar.
    initialScrollOffset: math.max(0, widget.values.indexOf(widget.selected)) * widget.itemExtent,
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      container: true,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(IddsSpacing.s4),
        itemExtent: widget.itemExtent,
        itemCount: widget.values.length,
        itemBuilder: (BuildContext context, int i) {
          final int v = widget.values[i];
          return _TimeOption(
            label: widget.labelOf(v),
            selected: v == widget.selected,
            enabled: widget.enabledOf(v),
            onTap: () => widget.onSelect(v),
          );
        },
      ),
    );
  }
}

class _TimeOption extends StatelessWidget {
  const _TimeOption({required this.label, required this.selected, required this.enabled, required this.onTap});

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: enabled ? onTap : null,
        mouseCursor: SystemMouseCursors.click,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(IddsRadius.md),
          rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.strokeTertiary)],
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // CSS: terpilih berlatar content-primary dengan teks putih
              // (`--ina-white` ikut berbalik di dark mode).
              color: selected
                  ? (enabled ? c.contentPrimary : c.backgroundTertiary)
                  : state.hovered
                      ? c.backgroundSecondary
                      : null,
              borderRadius: BorderRadius.circular(IddsRadius.md),
            ),
            child: Text(
              label,
              style: theme.textStyle(
                fontSize: IddsFontSize.sm,
                lineHeight: IddsLineHeight.sm,
                color: !enabled
                    ? c.contentTertiary
                    : selected
                        ? c.white
                        : c.contentPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({required this.label, required this.primary, required this.onTap});

  final String label;
  final bool primary;
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
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(IddsRadius.md),
          rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.strokeTertiary)],
          child: Opacity(
            opacity: primary && state.hovered ? 0.7 : 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: primary ? IddsSpacing.s12 : IddsSpacing.s8, vertical: IddsSpacing.s4),
              decoration: BoxDecoration(
                color: primary
                    ? c.contentPrimary
                    : state.hovered
                        ? c.backgroundSecondary
                        : null,
                borderRadius: BorderRadius.circular(IddsRadius.md),
              ),
              child: Text(
                label,
                style: theme.textStyle(
                  fontSize: IddsFontSize.sm,
                  lineHeight: IddsLineHeight.sm,
                  fontWeight: IddsFontWeight.medium,
                  // CSS: teks putih tetap; di dark mode diganti warna latar
                  // agar terbaca di atas content-primary yang terang.
                  color: primary ? c.backgroundPrimary : c.contentPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
