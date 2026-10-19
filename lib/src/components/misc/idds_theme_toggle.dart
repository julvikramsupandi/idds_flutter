import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Ukuran [IddsThemeToggle].
enum IddsThemeToggleSize {
  /// Tombol 32px, ikon 16px.
  sm(32, 16, IddsSpacing.s8),

  /// Tombol 40px, ikon 18px (bawaan).
  md(40, 18, IddsSpacing.s12),

  /// Tombol 48px, ikon 20px.
  lg(48, 20, IddsSpacing.s16);

  const IddsThemeToggleSize(this.height, this.icon, this.gap);

  /// Tinggi (dan lebar minimum) tombol.
  final double height;

  /// Ukuran ikon.
  final double icon;

  /// Jarak label ke tombol.
  final double gap;
}

/// Tombol beralih mode terang/gelap (Theme Toggle IDDS).
///
/// Tombol ini tidak mengubah tema sendiri: simpan [dark] di state aplikasi
/// dan bangun ulang `IddsThemeData` dengan `brightness` yang sesuai.
///
/// ```dart
/// IddsThemeToggle(dark: _dark, onChanged: (v) => setState(() => _dark = v))
/// ```
class IddsThemeToggle extends StatelessWidget {
  /// Membuat tombol tema.
  const IddsThemeToggle({
    super.key,
    required this.dark,
    required this.onChanged,
    this.size = IddsThemeToggleSize.md,
    this.showLabel = false,
    this.lightLabel = 'Mode terang',
    this.darkLabel = 'Mode gelap',
  });

  /// Mode gelap sedang aktif.
  final bool dark;

  /// Dipanggil dengan nilai baru. `null` membuat tombol nonaktif.
  final ValueChanged<bool>? onChanged;

  /// Ukuran.
  final IddsThemeToggleSize size;

  /// Tampilkan teks mode saat ini di samping ikon.
  final bool showLabel;

  /// Teks mode terang.
  final String lightLabel;

  /// Teks mode gelap.
  final String darkLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final VoidCallback? onTap = onChanged == null ? null : () => onChanged!(!dark);
    final String label = dark ? darkLabel : lightLabel;

    // CSS `@idds/react`: tombol bulat tanpa garis tepi, latar transparan
    // (membesar 1.05 saat hover), ikon primary, label di luar tombol.
    // Penyesuaian (lintasan `__track` dan latar hover): lihat README.
    final double labelSize = switch (size) {
      IddsThemeToggleSize.lg => iddsIsCompact(context, IddsBreakpoint.sm) ? IddsFontSize.sm : IddsFontSize.base,
      IddsThemeToggleSize.md => iddsIsCompact(context, IddsBreakpoint.sm) ? IddsFontSize.xs : IddsFontSize.sm,
      IddsThemeToggleSize.sm => IddsFontSize.xs,
    };
    final double labelLineHeight = switch (labelSize) {
      IddsFontSize.base => IddsLineHeight.base,
      IddsFontSize.sm => IddsLineHeight.sm,
      _ => IddsLineHeight.xs,
    };

    return Semantics(
      button: true,
      toggled: dark,
      label: dark ? 'Ganti ke $lightLabel' : 'Ganti ke $darkLabel',
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) {
          final Color iconColor = !state.enabled
              ? c.contentTertiary
              : theme.isDark
                  ? (state.hovered ? c.primary.shade300 : c.primary.shade400)
                  : (state.hovered ? c.primary.shade500 : c.primary.shade600);
          final Widget button = IddsInsetRing(
            visible: state.focused,
            borderRadius: BorderRadius.circular(IddsRadius.full),
            // CSS fokus: cincin 2px latar + primary-500.
            rings: <(double, Color)>[(2.0, c.backgroundPrimary), (2.0, c.primary.shade500)],
            child: AnimatedScale(
              scale: state.pressed
                  ? 0.95
                  : state.hovered && state.enabled
                      ? 1.05
                      : 1,
              duration: IddsDuration.base,
              child: AnimatedContainer(
                duration: IddsDuration.base,
                width: size.height,
                height: size.height,
                decoration: BoxDecoration(
                  color: state.hovered && state.enabled ? c.backgroundTertiary : const Color(0x00000000),
                  borderRadius: BorderRadius.circular(IddsRadius.full),
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: IddsDuration.slow,
                  transitionBuilder: (Widget child, Animation<double> a) => RotationTransition(
                    turns: Tween<double>(begin: 0.75, end: 1).animate(a),
                    child: FadeTransition(opacity: a, child: child),
                  ),
                  child: IddsIcon(
                    dark ? IddsIcons.moon : IddsIcons.sun,
                    key: ValueKey<bool>(dark),
                    size: size.icon,
                    color: iconColor,
                  ),
                ),
              ),
            ),
          );
          return Opacity(
            opacity: state.enabled ? 1 : 0.5,
            child: showLabel
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: size.gap,
                    children: <Widget>[
                      Text(
                        label,
                        style: theme.textStyle(
                          fontSize: labelSize,
                          lineHeight: labelLineHeight,
                          fontWeight: IddsFontWeight.medium,
                          color: c.contentSecondary,
                        ),
                      ),
                      button,
                    ],
                  )
                : button,
          );
        },
      ),
    );
  }
}
