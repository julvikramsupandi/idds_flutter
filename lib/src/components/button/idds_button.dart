import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Hierarki visual [IddsButton].
enum IddsButtonHierarchy {
  /// Aksi utama: latar warna brand, teks putih.
  primary,

  /// Aksi sekunder: latar putih dengan garis tepi.
  secondary,

  /// Aksi tersier: tanpa garis tepi, latar muncul saat hover.
  tertiary,

  /// Tampil seperti tautan, tanpa padding.
  link,
}

/// Ukuran [IddsButton]. Tinggi di layar ≥ 640px (dan < 640px):
///
/// | Ukuran | Tinggi | Font |
/// |---|---|---|
/// | [xl2] | 56 (44) | 16 (14) |
/// | [xl] | 48 (44) | 16 (14) |
/// | [lg] | 44 (36) | 14 (12) |
/// | [md] | 40 (32) | 14 (12) |
/// | [sm] | 32 (24) | 12 (10) |
///
/// Tinggi = padding + line-height, sama seperti yang dirender browser untuk
/// `@idds/styles`. (CSS juga menulis `max-height` 48/44/40/32/28 untuk layar
/// kecil, tetapi itu hanya batas atas.)
enum IddsButtonSize {
  /// `2xl` di IDDS web.
  xl2,

  /// `xl`.
  xl,

  /// `lg`.
  lg,

  /// `md` (bawaan).
  md,

  /// `sm`.
  sm,
}

/// Tombol IDDS.
///
/// Mengikuti spesifikasi `.ina-button` di `@idds/styles`: lima ukuran,
/// empat hierarki, state hover/fokus/nonaktif, dan ukuran lebih kecil di
/// layar sempit (lihat [IddsThemeData.compactOnSmallScreens]).
///
/// ```dart
/// IddsButton(
///   onPressed: _save,
///   prefixIcon: const Icon(Icons.save),
///   child: const Text('Simpan'),
/// )
/// ```
///
/// Tombol nonaktif bila [onPressed] bernilai `null`.
class IddsButton extends StatefulWidget {
  /// Membuat tombol.
  const IddsButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.hierarchy = IddsButtonHierarchy.primary,
    this.size = IddsButtonSize.md,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Dipanggil saat tombol ditekan. `null` membuat tombol nonaktif.
  final VoidCallback? onPressed;

  /// Isi tombol, biasanya [Text].
  final Widget child;

  /// Hierarki visual.
  final IddsButtonHierarchy hierarchy;

  /// Ukuran.
  final IddsButtonSize size;

  /// Ikon di kiri [child].
  final Widget? prefixIcon;

  /// Ikon di kanan [child].
  final Widget? suffixIcon;

  /// Focus node opsional.
  final FocusNode? focusNode;

  /// Apakah tombol langsung mendapat fokus.
  final bool autofocus;

  /// Label untuk pembaca layar bila [child] bukan teks.
  final String? semanticLabel;

  /// Apakah tombol aktif.
  bool get enabled => onPressed != null;

  @override
  State<IddsButton> createState() => _IddsButtonState();
}

class _IddsButtonState extends State<IddsButton> {
  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final _Metrics metrics = _Metrics.of(
      widget.size,
      compact: iddsIsCompact(context, IddsBreakpoint.sm),
    );
    final bool isLink = widget.hierarchy == IddsButtonHierarchy.link;

    return Semantics(
      container: true,
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      child: IddsInteractive(
        onTap: widget.onPressed,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (BuildContext context, IddsInteractionState state) {
          final _Style style = _Style.resolve(
            widget.hierarchy,
            theme.colors,
            enabled: state.enabled,
            hovered: state.hovered,
            focused: state.focused,
          );
          final double borderWidth = style.border == null ? 0 : 1;
          final EdgeInsets padding = isLink
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(
                  vertical: metrics.paddingVertical - borderWidth,
                  horizontal: metrics.paddingHorizontal - borderWidth,
                );
          final TextStyle textStyle = theme
              .textStyle(
                fontSize: metrics.fontSize,
                lineHeight: metrics.lineHeight,
                fontWeight: IddsFontWeight.medium,
                color: style.foreground,
              )
              .copyWith(
                decoration: style.underline ? TextDecoration.underline : TextDecoration.none,
                decorationColor: style.foreground,
              );

          return AnimatedContainer(
            duration: IddsDuration.fast,
            curve: IddsCurves.standard,
            padding: padding,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(metrics.radius),
              border: style.border == null ? null : Border.all(color: style.border!),
              boxShadow: style.focusRing
                  ? <BoxShadow>[
                      // CSS: 0 0 0 2px background-primary, 0 0 0 3px stroke-tertiary.
                      BoxShadow(color: theme.colors.strokeTertiary, spreadRadius: 3),
                      BoxShadow(color: theme.colors.backgroundPrimary, spreadRadius: 2),
                    ]
                  : null,
            ),
            child: DefaultTextStyle(
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              child: IconTheme(
                data: IconThemeData(size: metrics.lineHeight, color: style.foreground),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: IddsSpacing.s8,
                  children: <Widget>[
                    if (widget.prefixIcon != null) widget.prefixIcon!,
                    widget.child,
                    if (widget.suffixIcon != null) widget.suffixIcon!,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Ukuran dari `.ina-button--{size}` (dan media query `max-width: 639px`).
class _Metrics {
  const _Metrics(this.fontSize, this.lineHeight, this.paddingVertical, this.paddingHorizontal, this.radius);

  factory _Metrics.of(IddsButtonSize size, {required bool compact}) {
    final double radius = switch (size) {
      IddsButtonSize.md => 7.0,
      IddsButtonSize.sm => 6.0,
      _ => IddsRadius.lg,
    };
    if (compact) {
      return switch (size) {
        IddsButtonSize.xl2 => _Metrics(IddsFontSize.sm, IddsLineHeight.sm, 12, 16, radius),
        IddsButtonSize.xl => _Metrics(IddsFontSize.sm, IddsLineHeight.base, 10, 12, radius),
        IddsButtonSize.lg => _Metrics(IddsFontSize.xs, IddsLineHeight.xs, 10, 12, radius),
        IddsButtonSize.md => _Metrics(IddsFontSize.xs, IddsLineHeight.xs, 8, 8, radius),
        IddsButtonSize.sm => _Metrics(IddsFontSize.xs2, 12, 6, 8, radius),
      };
    }
    return switch (size) {
      IddsButtonSize.xl2 => _Metrics(IddsFontSize.base, IddsLineHeight.base, 16, 16, radius),
      IddsButtonSize.xl => _Metrics(IddsFontSize.base, IddsLineHeight.base, 12, 16, radius),
      IddsButtonSize.lg => _Metrics(IddsFontSize.sm, IddsLineHeight.sm, 12, 12, radius),
      IddsButtonSize.md => _Metrics(IddsFontSize.sm, IddsLineHeight.sm, 10, 12, radius),
      IddsButtonSize.sm => _Metrics(IddsFontSize.xs, IddsLineHeight.xs, 8, 8, radius),
    };
  }

  final double fontSize;
  final double lineHeight;
  final double paddingVertical;
  final double paddingHorizontal;
  final double radius;
}

/// Warna dari `.ina-button--{hierarchy}` dan state-nya.
class _Style {
  const _Style({
    required this.background,
    required this.foreground,
    this.border,
    this.focusRing = false,
    this.underline = false,
  });

  factory _Style.resolve(
    IddsButtonHierarchy hierarchy,
    IddsColors c, {
    required bool enabled,
    required bool hovered,
    required bool focused,
  }) {
    final bool active = enabled && (hovered || focused);
    final bool ring = enabled && focused;
    switch (hierarchy) {
      case IddsButtonHierarchy.primary:
        if (!enabled) return _Style(background: c.backgroundTertiary, foreground: c.contentTertiary);
        return _Style(
          // color-mix(primary 90%, transparent)
          background: active ? c.primaryMain.withValues(alpha: c.primaryMain.a * 0.9) : c.primaryMain,
          foreground: c.onPrimary,
          focusRing: ring,
        );
      case IddsButtonHierarchy.secondary:
        if (!enabled) {
          return _Style(
            background: c.backgroundTertiary,
            foreground: c.contentTertiary,
            border: c.strokePrimary,
          );
        }
        return _Style(
          background: active ? c.backgroundSecondary : c.backgroundPrimary,
          foreground: c.contentPrimary,
          border: c.strokePrimary,
          focusRing: ring,
        );
      case IddsButtonHierarchy.tertiary:
        if (!enabled) return _Style(background: c.backgroundTertiary, foreground: c.contentTertiary);
        return _Style(
          background: active ? c.backgroundTertiary : c.backgroundPrimary,
          foreground: c.contentPrimary,
          focusRing: ring,
        );
      case IddsButtonHierarchy.link:
        if (!enabled) return _Style(background: c.backgroundPrimary, foreground: c.contentTertiary);
        return _Style(
          background: c.backgroundPrimary,
          foreground: active ? c.guide.shade400 : c.contentGuide,
          focusRing: ring,
          underline: ring,
        );
    }
  }

  final Color background;
  final Color foreground;
  final Color? border;
  final bool focusRing;
  final bool underline;
}
