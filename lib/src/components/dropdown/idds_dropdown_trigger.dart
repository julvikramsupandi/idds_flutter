import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Ukuran pemicu dropdown ([IddsSelect], [IddsMultiSelect], [IddsActionMenu]).
/// Tinggi sama di semua lebar layar: [sm] 40, [md] 44, [lg] 48, seragam
/// dengan [IddsTextFieldSize].
///
/// Kotak pemicu tidak ikut mode compact (lihat
/// [IddsThemeData.compactOnSmallScreens]): IDDS menetapkan tinggi minimum
/// 40px dan memasangkan tinggi input dengan tombol dan text field (44px),
/// sedangkan versi sebelumnya menurunkan `md` menjadi 36px di HP.
enum IddsDropdownSize {
  /// Kecil.
  sm(40),

  /// Sedang (bawaan).
  md(44),

  /// Besar.
  lg(48);

  const IddsDropdownSize(this.height);

  /// Tinggi pemicu di semua lebar layar.
  final double height;
}

/// Ukuran turunan dari [IddsDropdownSize] dan lebar layar. Internal.
@immutable
class IddsDropdownMetrics {
  /// Menghitung ukuran.
  factory IddsDropdownMetrics.of(BuildContext context, IddsDropdownSize size) {
    final bool small = iddsIsCompact(context, IddsBreakpoint.sm);
    final bool medium = iddsIsCompact(context, IddsBreakpoint.md);
    return IddsDropdownMetrics._(
      height: size.height,
      horizontalPadding:
          size == IddsDropdownSize.sm ? IddsSpacing.s12 : IddsSpacing.s16,
      fontSize: medium ? IddsFontSize.xs : IddsFontSize.sm,
      lineHeight: medium ? IddsLineHeight.xs : IddsLineHeight.sm,
      iconSize: size == IddsDropdownSize.sm ? 16 : 20,
      optionMinHeight: small
          ? 48
          : switch (size) {
              IddsDropdownSize.sm => 36,
              IddsDropdownSize.md => 40,
              IddsDropdownSize.lg => 52,
            },
      small: small,
    );
  }

  const IddsDropdownMetrics._({
    required this.height,
    required this.horizontalPadding,
    required this.fontSize,
    required this.lineHeight,
    required this.iconSize,
    required this.optionMinHeight,
    required this.small,
  });

  /// Tinggi pemicu.
  final double height;

  /// Padding kiri-kanan pemicu.
  final double horizontalPadding;

  /// Ukuran font pemicu dan opsi.
  final double fontSize;

  /// Tinggi baris teks.
  final double lineHeight;

  /// Ukuran ikon chevron.
  final double iconSize;

  /// Tinggi minimal satu opsi.
  final double optionMinHeight;

  /// Layar < 640px.
  final bool small;
}

/// Kotak pemicu dropdown: garis tepi, cincin fokus, dan chevron yang
/// berputar saat terbuka. Internal.
class IddsDropdownTriggerBox extends StatelessWidget {
  /// Membuat kotak pemicu.
  const IddsDropdownTriggerBox({
    super.key,
    required this.state,
    required this.open,
    required this.metrics,
    required this.child,
    this.error = false,
    this.prefix,
  });

  /// State interaksi.
  final IddsInteractionState state;

  /// Panel sedang terbuka.
  final bool open;

  /// Ukuran.
  final IddsDropdownMetrics metrics;

  /// Isi (teks nilai atau placeholder).
  final Widget child;

  /// Status error.
  final bool error;

  /// Widget di kiri teks.
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool active = state.focused || open;
    final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
    final Color border = error
        ? c.negative.shade500
        : active
            ? c.strokeTertiary
            : c.strokePrimary;
    final Color ring = error ? c.negative.shade500 : c.contentPrimary;

    return Opacity(
      opacity: state.enabled ? 1 : 0.6,
      child: IddsInsetRing(
        visible: state.enabled && active,
        borderRadius: radius,
        inset: 1,
        // CSS: inset 0 0 0 2px background-primary, inset 0 0 0 3px content-primary.
        rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, ring)],
        child: AnimatedContainer(
          duration: IddsDuration.base,
          curve: IddsCurves.standard,
          height: metrics.height,
          padding:
              EdgeInsets.symmetric(horizontal: metrics.horizontalPadding - 1),
          decoration: BoxDecoration(
            color: state.hovered && !open
                ? c.backgroundSecondary
                : c.backgroundPrimary,
            borderRadius: radius,
            border: Border.all(color: border),
          ),
          child: IconTheme(
            data: IconThemeData(
                size: metrics.iconSize, color: c.contentSecondary),
            child: Row(
              spacing: IddsSpacing.s8,
              children: <Widget>[
                if (prefix != null) prefix!,
                Expanded(
                  child: DefaultTextStyle(
                    style: theme.textStyle(
                      fontSize: metrics.fontSize,
                      lineHeight: metrics.lineHeight,
                      color: c.contentPrimary,
                    ),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    child: child,
                  ),
                ),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: IddsDuration.base,
                  curve: IddsCurves.standard,
                  child: IddsIcon(IddsIcons.chevronDown,
                      size: metrics.iconSize, color: c.contentSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Label di atas kolom, dengan tanda wajib (*). Internal.
class IddsFieldLabel extends StatelessWidget {
  /// Membuat label.
  const IddsFieldLabel(
      {super.key,
      required this.label,
      required this.required,
      required this.small});

  /// Isi label.
  final Widget label;

  /// Tampilkan tanda wajib.
  final bool required;

  /// Layar kecil.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: IddsSpacing.s8),
      child: DefaultTextStyle(
        style: theme.textStyle(
          fontSize: small ? IddsFontSize.xs : IddsFontSize.sm,
          lineHeight: small ? IddsLineHeight.xs : IddsLineHeight.sm,
          fontWeight: IddsFontWeight.medium,
          color: theme.colors.contentPrimary,
        ),
        child: Row(
          children: <Widget>[
            Flexible(child: label),
            if (required) ...<Widget>[
              const SizedBox(width: IddsSpacing.s4),
              Text('*',
                  style: TextStyle(color: theme.colors.negative.shade500)),
            ],
          ],
        ),
      ),
    );
  }
}
