import 'package:flutter/widgets.dart';

import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_primitives.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Gaya isian [IddsBadge].
enum IddsBadgeType {
  /// Latar muda, teks berwarna.
  soft,

  /// Latar pekat, teks terang.
  fill,
}

/// Warna [IddsBadge].
enum IddsBadgeVariant {
  /// Warna brand aktif.
  brand,

  /// Biru (guide).
  info,

  /// Kuning (warning).
  warning,

  /// Hijau (positive).
  success,

  /// Merah (negative).
  error,

  /// Abu-abu.
  neutral,
}

/// Ukuran [IddsBadge].
enum IddsBadgeSize {
  /// Font 12px.
  sm,

  /// Font 14px (bawaan).
  md,

  /// Font 14px, sama dengan [md] di `@idds/styles`.
  lg,

  /// Font 16px.
  xl,
}

/// Radius sudut [IddsBadge].
enum IddsBadgeRounded {
  /// 2px.
  sm,

  /// 4px.
  md,

  /// 8px.
  lg,

  /// Bentuk pil (bawaan).
  full,
}

/// Label kecil untuk status atau kategori.
///
/// ```dart
/// const IddsBadge(variant: IddsBadgeVariant.success, child: Text('Aktif'))
/// ```
class IddsBadge extends StatelessWidget {
  /// Membuat badge.
  const IddsBadge({
    super.key,
    required this.child,
    this.type = IddsBadgeType.soft,
    this.variant = IddsBadgeVariant.info,
    this.size = IddsBadgeSize.md,
    this.rounded = IddsBadgeRounded.full,
    this.prefixIcon,
    this.suffixIcon,
  });

  /// Isi badge, biasanya [Text].
  final Widget child;

  /// Gaya isian.
  final IddsBadgeType type;

  /// Warna.
  final IddsBadgeVariant variant;

  /// Ukuran.
  final IddsBadgeSize size;

  /// Radius sudut.
  final IddsBadgeRounded rounded;

  /// Ikon di kiri.
  final Widget? prefixIcon;

  /// Ikon di kanan.
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final (Color background, Color foreground) = _colors(theme);
    final (double fontSize, double lineHeight, double paddingH) = switch (size) {
      IddsBadgeSize.sm => (IddsFontSize.xs, 14.0, IddsSpacing.s8),
      IddsBadgeSize.md || IddsBadgeSize.lg => (IddsFontSize.sm, IddsLineHeight.sm, IddsSpacing.s12),
      IddsBadgeSize.xl => (IddsFontSize.base, IddsLineHeight.base, IddsSpacing.s14),
    };
    final double radius = switch (rounded) {
      IddsBadgeRounded.sm => IddsRadius.sm,
      IddsBadgeRounded.md => IddsRadius.base,
      IddsBadgeRounded.lg => IddsRadius.lg,
      IddsBadgeRounded.full => IddsRadius.full,
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48),
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: IddsSpacing.s4, horizontal: paddingH),
          child: DefaultTextStyle(
            style: theme.textStyle(
              fontSize: fontSize,
              lineHeight: lineHeight,
              fontWeight: IddsFontWeight.medium,
              color: foreground,
            ),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: IconTheme(
              data: IconThemeData(size: fontSize + 2, color: foreground),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: IddsSpacing.s4,
                children: <Widget>[
                  if (prefixIcon != null) prefixIcon!,
                  child,
                  if (suffixIcon != null) suffixIcon!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _colors(IddsThemeData theme) {
    final IddsColors c = theme.colors;
    final bool soft = type == IddsBadgeType.soft;
    return switch (variant) {
      // Penyesuaian dari CSS agar tetap terbaca di dark mode:
      // - soft: latar primary-100 tidak berubah antar mode, jadi teksnya
      //   memakai warna utama mode terang (CSS: primary-primary).
      // - fill: teks memakai onPrimary (CSS: primary-25).
      IddsBadgeVariant.brand =>
        soft ? (c.primary.shade100, theme.brand.primaryMainLight) : (c.primaryMain, c.onPrimary),
      IddsBadgeVariant.info => soft ? (c.guide.shade100, c.guide.shade600) : (c.guide.shade500, c.guide.shade50),
      IddsBadgeVariant.warning =>
        soft ? (c.warning.shade100, c.warning.shade600) : (c.warning.shade400, c.warning.shade800),
      IddsBadgeVariant.success =>
        soft ? (c.positive.shade100, c.positive.shade600) : (c.positive.shade600, c.positive.shade50),
      IddsBadgeVariant.error =>
        soft ? (c.negative.shade100, c.negative.shade600) : (c.negative.shade600, c.negative.shade50),
      // soft: CSS memakai neutral-800 yang hilang di atas latar gelap;
      // content-primary bernilai sama di mode terang.
      IddsBadgeVariant.neutral => soft
          ? (c.backgroundSecondary, c.contentPrimary)
          : (IddsPrimitives.neutral.shade500, IddsPrimitives.neutral25),
    };
  }
}
