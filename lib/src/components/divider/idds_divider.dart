import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Variasi jarak [IddsDivider].
enum IddsDividerVariant {
  /// Selebar/setinggi penuh (bawaan).
  fullWidth,

  /// Menjorok 16px di awal.
  inset,

  /// Menjorok 16px di kedua ujung.
  middle,
}

/// Garis pemisah 1px (Divider IDDS), mendatar atau tegak, bisa dengan teks
/// di tengah.
///
/// ```dart
/// const IddsDivider()
/// const IddsDivider(label: Text('atau'))
/// const IddsDivider.vertical(height: 16)
/// ```
class IddsDivider extends StatelessWidget {
  /// Membuat garis mendatar.
  const IddsDivider({
    super.key,
    this.variant = IddsDividerVariant.fullWidth,
    this.light = false,
    this.spacing = 0,
    this.label,
  })  : axis = Axis.horizontal,
        height = null;

  /// Membuat garis tegak. Bila [height] `null`, garis setinggi wadah
  /// (pakai di dalam `IntrinsicHeight` atau wadah bertinggi tetap).
  const IddsDivider.vertical({
    super.key,
    this.variant = IddsDividerVariant.fullWidth,
    this.light = false,
    this.spacing = 0,
    this.height = 16,
  })  : axis = Axis.vertical,
        label = null;

  /// Arah garis.
  final Axis axis;

  /// Variasi jarak.
  final IddsDividerVariant variant;

  /// Warna lebih terang (`stroke-secondary`).
  final bool light;

  /// Jarak di kedua sisi garis (atas-bawah untuk garis mendatar).
  final double spacing;

  /// Teks di tengah garis mendatar.
  final Widget? label;

  /// Tinggi garis tegak.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final Color color = light ? c.strokeSecondary : c.strokePrimary;
    final double start = variant == IddsDividerVariant.fullWidth ? 0 : IddsSpacing.s16;
    final double end = variant == IddsDividerVariant.middle ? IddsSpacing.s16 : 0;

    if (axis == Axis.vertical) {
      return ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.only(left: spacing, right: spacing, top: start, bottom: end),
          child: Container(width: 1, height: height, color: color),
        ),
      );
    }

    final Widget line = Container(height: 1, color: color);
    Widget child;
    if (label == null) {
      child = ExcludeSemantics(child: line);
    } else {
      final bool small = iddsScreenWidth(context) < IddsBreakpoint.sm;
      child = Row(
        children: <Widget>[
          Expanded(child: line),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s16),
            child: DefaultTextStyle(
              style: theme.textStyle(
                fontSize: small ? IddsFontSize.xs : IddsFontSize.sm,
                lineHeight: small ? IddsLineHeight.xs : IddsLineHeight.sm,
                color: c.contentSecondary,
              ),
              child: label!,
            ),
          ),
          Expanded(child: line),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: start, right: end, top: spacing, bottom: spacing),
      child: child,
    );
  }
}
