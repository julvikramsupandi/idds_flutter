import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Satu tombol di [IddsButtonGroup].
@immutable
class IddsButtonGroupOption<T> {
  /// Membuat pilihan.
  const IddsButtonGroupOption({required this.value, required this.label, this.enabled = true});

  /// Nilai pilihan.
  final T value;

  /// Isi tombol, biasanya [Text].
  final Widget label;

  /// Apakah bisa dipilih.
  final bool enabled;
}

/// Deretan tombol yang tersambung untuk memilih satu dari beberapa nilai
/// (segmented control).
///
/// ```dart
/// IddsButtonGroup<String>(
///   value: _period,
///   onChanged: (v) => setState(() => _period = v),
///   options: const [
///     IddsButtonGroupOption(value: 'harian', label: Text('Harian')),
///     IddsButtonGroupOption(value: 'bulanan', label: Text('Bulanan')),
///   ],
/// )
/// ```
class IddsButtonGroup<T> extends StatelessWidget {
  /// Membuat grup tombol.
  const IddsButtonGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  /// Pilihan yang tersedia.
  final List<IddsButtonGroupOption<T>> options;

  /// Nilai terpilih.
  final T? value;

  /// Dipanggil dengan nilai baru. `null` membuat seluruh grup nonaktif.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double width = iddsScreenWidth(context);
    final bool compactable = theme.compactOnSmallScreens;
    final bool small = compactable && width < IddsBreakpoint.md;
    final bool medium = compactable && !small && width < IddsBreakpoint.lg;
    final double height = small ? 32 : 40;
    final double paddingH = small ? 12 : (medium ? 14 : 16);
    final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
    final bool groupEnabled = onChanged != null;

    // Container (bukan DecoratedBox) agar isi berada di dalam garis tepi.
    final Widget group = Container(
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: radius,
        border: Border.all(color: c.strokePrimary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IddsRadius.lg - 1),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < options.length; i++) ...<Widget>[
                if (i > 0) Container(width: 1, color: c.strokePrimary),
                _Segment<T>(
                  option: options[i],
                  selected: options[i].value == value,
                  onTap: groupEnabled && options[i].enabled ? () => onChanged!(options[i].value) : null,
                  height: height,
                  paddingH: paddingH,
                  fontSize: small ? IddsFontSize.xs : IddsFontSize.sm,
                  lineHeight: small ? IddsLineHeight.xs : IddsLineHeight.sm,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Opacity(
        opacity: groupEnabled ? 1 : 0.6,
        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: group),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.height,
    required this.paddingH,
    required this.fontSize,
    required this.lineHeight,
  });

  final IddsButtonGroupOption<T> option;
  final bool selected;
  final VoidCallback? onTap;
  final double height;
  final double paddingH;
  final double fontSize;
  final double lineHeight;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool dark = theme.isDark;

    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      onTap: onTap,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) {
          final bool highlighted = selected || state.hovered || state.focused;
          // Terang: latar primary-25, teks warna brand.
          // Gelap: latar warna brand, teks onPrimary (CSS: primary-25, yang
          // hilang di atas brand Neutral yang warna utamanya putih).
          final Color background = state.pressed
              ? (dark ? c.primaryMain : c.backgroundTertiary)
              : highlighted
                  ? (dark ? c.primaryMain : c.primary.shade25)
                  : c.backgroundPrimary;
          final Color foreground = selected || (dark && highlighted)
              ? (dark ? c.onPrimary : c.primaryMain)
              : c.contentSecondary;

          return Opacity(
            opacity: onTap == null && !selected ? 0.5 : 1,
            child: AnimatedContainer(
              duration: IddsDuration.base,
              curve: IddsCurves.standard,
              height: height,
              padding: EdgeInsets.symmetric(horizontal: paddingH),
              decoration: BoxDecoration(
                color: background,
                border: state.focused
                    ? Border.all(color: dark ? c.primary.shade25 : c.primary.shade600, width: 2)
                    : null,
              ),
              child: Center(
                widthFactor: 1,
                child: DefaultTextStyle(
                  style: theme.textStyle(
                    fontSize: fontSize,
                    lineHeight: lineHeight,
                    fontWeight: IddsFontWeight.semibold,
                    color: foreground,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  child: IconTheme(
                    data: IconThemeData(size: 16, color: foreground),
                    child: option.label,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
