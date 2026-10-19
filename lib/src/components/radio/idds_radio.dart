import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Ukuran [IddsRadio] dan [IddsRadioGroup].
enum IddsRadioSize {
  /// Lingkaran 16px, teks 12px.
  sm,

  /// Lingkaran 20px, teks 14px (bawaan).
  md,

  /// Lingkaran 24px, teks 16px.
  lg,
}

/// Posisi label terhadap lingkaran radio.
enum IddsRadioLabelPosition {
  /// Label di kanan (bawaan).
  right,

  /// Label di kiri.
  left,

  /// Label di kiri, lingkaran di ujung kanan (memenuhi lebar).
  between,
}

/// Satu pilihan di [IddsRadioGroup].
@immutable
class IddsRadioOption<T> {
  /// Membuat pilihan.
  const IddsRadioOption({required this.value, required this.label, this.enabled = true});

  /// Nilai yang dikirim ke `onChanged`.
  final T value;

  /// Teks pilihan.
  final String label;

  /// Apakah pilihan ini bisa dipilih.
  final bool enabled;
}

class _RadioMetrics {
  const _RadioMetrics(this.field, this.dot, this.fontSize);

  factory _RadioMetrics.of(BuildContext context, IddsRadioSize size) {
    // Di layar < 640px, md turun ke ukuran sm dan lg turun ke md.
    final bool compact = iddsIsCompact(context, IddsBreakpoint.sm);
    final IddsRadioSize effective = !compact
        ? size
        : switch (size) {
            IddsRadioSize.lg => IddsRadioSize.md,
            _ => IddsRadioSize.sm,
          };
    return switch (effective) {
      IddsRadioSize.sm => const _RadioMetrics(16, 8, IddsFontSize.xs),
      IddsRadioSize.md => const _RadioMetrics(20, 11, IddsFontSize.sm),
      IddsRadioSize.lg => const _RadioMetrics(24, 14, IddsFontSize.base),
    };
  }

  final double field;
  final double dot;
  final double fontSize;
}

/// Satu tombol radio dengan label opsional.
///
/// Untuk daftar pilihan lengkap dengan judul dan teks bantuan, pakai
/// [IddsRadioGroup].
class IddsRadio<T> extends StatelessWidget {
  /// Membuat radio.
  const IddsRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.size = IddsRadioSize.md,
    this.labelPosition = IddsRadioLabelPosition.right,
    this.error = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// Nilai radio ini.
  final T value;

  /// Nilai yang sedang terpilih di grup.
  final T? groupValue;

  /// Dipanggil dengan [value] saat dipilih. `null` membuat radio nonaktif.
  final ValueChanged<T>? onChanged;

  /// Teks pilihan.
  final String? label;

  /// Ukuran.
  final IddsRadioSize size;

  /// Posisi label.
  final IddsRadioLabelPosition labelPosition;

  /// Tampilkan garis tepi merah.
  final bool error;

  /// Focus node opsional.
  final FocusNode? focusNode;

  /// Langsung mendapat fokus.
  final bool autofocus;

  /// Apakah radio ini terpilih.
  bool get selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final _RadioMetrics m = _RadioMetrics.of(context, size);
    final bool enabled = onChanged != null;
    final VoidCallback? onTap = enabled ? () => onChanged!(value) : null;

    return Semantics(
      container: true,
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (BuildContext context, IddsInteractionState state) {
          final Color border = !enabled
              ? c.strokePrimary
              : error
                  ? c.negative.shade500
                  : c.strokeTertiary;
          final Widget field = AnimatedContainer(
            duration: IddsDuration.base,
            curve: IddsCurves.standard,
            width: m.field,
            height: m.field,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? c.backgroundPrimary : c.backgroundSecondary,
              border: Border.all(color: border),
              boxShadow: state.focused
                  ? <BoxShadow>[
                      // CSS: 0 0 0 1px #fff, 0 0 0 2px content-primary.
                      BoxShadow(color: c.contentPrimary, spreadRadius: 2),
                      const BoxShadow(color: Color(0xFFFFFFFF), spreadRadius: 1),
                    ]
                  : state.hovered
                      ? const <BoxShadow>[BoxShadow(color: Color(0xFF737373), blurRadius: 3)]
                      : null,
            ),
            child: AnimatedScale(
              duration: IddsDuration.base,
              curve: IddsCurves.standard,
              scale: selected ? 1.0 : 0.0,
              child: Container(
                width: m.dot,
                height: m.dot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled ? c.strokeTertiary : c.strokePrimary,
                ),
              ),
            ),
          );

          if (label == null) return field;

          final Widget text = Text(
            label!,
            style: theme.textStyle(fontSize: m.fontSize, lineHeight: m.fontSize * 1.5),
          );
          final bool reversed = labelPosition != IddsRadioLabelPosition.right;
          final bool between = labelPosition == IddsRadioLabelPosition.between;

          return AnimatedContainer(
            duration: IddsDuration.base,
            curve: IddsCurves.standard,
            padding: const EdgeInsets.all(IddsSpacing.s8),
            decoration: BoxDecoration(
              // CSS: neutral-50, yang terlalu terang di dark mode.
              color: state.hovered ? c.backgroundSecondary : null,
              borderRadius: BorderRadius.circular(IddsRadius.md),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Flexible hanya aman bila lebar dibatasi.
                final bool bounded = constraints.hasBoundedWidth;
                final Widget textWidget = bounded ? Flexible(child: text) : text;
                return Row(
                  mainAxisSize: between && bounded ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: between ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
                  spacing: IddsSpacing.s8,
                  children: reversed ? <Widget>[textWidget, field] : <Widget>[field, textWidget],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Grup pilihan radio dengan judul, teks bantuan, dan status error.
///
/// ```dart
/// IddsRadioGroup<String>(
///   label: 'Jenis kelamin',
///   value: _gender,
///   onChanged: (v) => setState(() => _gender = v),
///   options: const [
///     IddsRadioOption(value: 'L', label: 'Laki-laki'),
///     IddsRadioOption(value: 'P', label: 'Perempuan'),
///   ],
/// )
/// ```
class IddsRadioGroup<T> extends StatelessWidget {
  /// Membuat grup radio.
  const IddsRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.label,
    this.size = IddsRadioSize.md,
    this.direction = Axis.vertical,
    this.labelPosition = IddsRadioLabelPosition.right,
    this.required = false,
    this.error = false,
    this.helperText,
  });

  /// Pilihan yang tersedia.
  final List<IddsRadioOption<T>> options;

  /// Nilai terpilih.
  final T? value;

  /// Dipanggil dengan nilai baru. `null` membuat seluruh grup nonaktif.
  final ValueChanged<T>? onChanged;

  /// Judul grup.
  final String? label;

  /// Ukuran.
  final IddsRadioSize size;

  /// Susunan pilihan: vertikal (bawaan) atau horizontal.
  final Axis direction;

  /// Posisi label tiap pilihan.
  final IddsRadioLabelPosition labelPosition;

  /// Tampilkan tanda wajib (*) pada judul.
  final bool required;

  /// Tampilkan status error pada judul, lingkaran, dan teks bantuan.
  final bool error;

  /// Teks bantuan di bawah pilihan.
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final _RadioMetrics m = _RadioMetrics.of(context, size);
    final bool compact = iddsIsCompact(context, IddsBreakpoint.sm);

    final List<Widget> items = <Widget>[
      for (final IddsRadioOption<T> option in options)
        IddsRadio<T>(
          value: option.value,
          groupValue: value,
          onChanged: option.enabled ? onChanged : null,
          label: option.label,
          size: size,
          labelPosition: labelPosition,
          error: error,
        ),
    ];

    return Semantics(
      container: true,
      label: label,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (label != null) ...<Widget>[
            ExcludeSemantics(
              child: Text.rich(
                TextSpan(
                  text: label,
                  children: <InlineSpan>[
                    if (required) TextSpan(text: ' *', style: TextStyle(color: c.negative.shade500)),
                  ],
                ),
                style: theme.textStyle(
                  fontSize: m.fontSize,
                  lineHeight: m.fontSize * 1.5,
                  fontWeight: IddsFontWeight.medium,
                  color: error ? c.negative.shade500 : c.contentPrimary,
                ),
              ),
            ),
            const SizedBox(height: IddsSpacing.s8),
          ],
          if (direction == Axis.vertical)
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: IddsSpacing.s8,
              children: items,
            )
          else
            Wrap(
              spacing: compact ? IddsSpacing.s8 : IddsSpacing.s16,
              runSpacing: IddsSpacing.s8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: items,
            ),
          if (helperText != null) ...<Widget>[
            const SizedBox(height: IddsSpacing.s4),
            Text(
              helperText!,
              style: theme.textStyle(
                fontSize: IddsFontSize.xs,
                lineHeight: IddsLineHeight.xs,
                color: error ? c.negative.shade500 : c.contentSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
