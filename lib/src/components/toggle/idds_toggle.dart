import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';

/// Ukuran [IddsToggle].
enum IddsToggleSize {
  /// Track 36×20, thumb 16.
  sm(36, 20, 16),

  /// Track 44×24, thumb 20 (bawaan).
  md(44, 24, 20);

  const IddsToggleSize(this.trackWidth, this.trackHeight, this.thumb);

  /// Lebar track.
  final double trackWidth;

  /// Tinggi track.
  final double trackHeight;

  /// Diameter thumb.
  final double thumb;
}

/// Saklar on/off IDDS.
///
/// ```dart
/// IddsToggle(
///   value: _notifications,
///   onChanged: (v) => setState(() => _notifications = v),
///   semanticLabel: 'Notifikasi',
/// )
/// ```
///
/// Nonaktif bila [onChanged] bernilai `null`.
class IddsToggle extends StatelessWidget {
  /// Membuat toggle.
  const IddsToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = IddsToggleSize.md,
    this.activeColor,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// Menyala.
  final bool value;

  /// Dipanggil dengan nilai baru. `null` membuat toggle nonaktif.
  final ValueChanged<bool>? onChanged;

  /// Ukuran.
  final IddsToggleSize size;

  /// Warna track saat menyala. Bawaan: positive-500 (hijau).
  final Color? activeColor;

  /// Label untuk pembaca layar.
  final String? semanticLabel;

  /// Focus node opsional.
  final FocusNode? focusNode;

  /// Langsung mendapat fokus.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool enabled = onChanged != null;
    final VoidCallback? onTap = enabled ? () => onChanged!(!value) : null;
    const double inset = 2;

    return Semantics(
      container: true,
      toggled: value,
      enabled: enabled,
      label: semanticLabel,
      onTap: onTap,
      child: IddsInteractive(
        onTap: onTap,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (BuildContext context, IddsInteractionState state) {
          final Color track = !enabled
              ? c.backgroundTertiary
              : value
                  ? (activeColor ?? c.positive.shade500)
                  : (theme.isDark ? c.strokeSecondary : c.backgroundSecondary);
          final List<BoxShadow>? hoverHalo = state.hovered
              ? const <BoxShadow>[
                  BoxShadow(color: Color(0x1A1F1F1F), blurRadius: 6),
                  BoxShadow(color: Color(0x0A1F1F1F), blurRadius: 4, spreadRadius: 6),
                ]
              : null;
          final BorderRadius radius = BorderRadius.circular(size.trackHeight / 2);

          return IddsInsetRing(
            visible: state.focused,
            borderRadius: radius,
            // CSS: inset 0 0 0 2px background-primary, inset 0 0 0 3px content-primary.
            rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.contentPrimary)],
            child: AnimatedContainer(
              duration: IddsDuration.base,
              curve: IddsCurves.standard,
              width: size.trackWidth,
              height: size.trackHeight,
              decoration: BoxDecoration(color: track, borderRadius: radius, boxShadow: hoverHalo),
              child: Stack(
                children: <Widget>[
                  AnimatedPositioned(
                    duration: IddsDuration.base,
                    curve: IddsCurves.standard,
                    top: inset,
                    left: value ? size.trackWidth - size.thumb - inset : inset,
                    child: AnimatedScale(
                      duration: IddsDuration.fast,
                      scale: state.pressed ? 0.95 : 1.0,
                      child: Container(
                        width: size.thumb,
                        height: size.thumb,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: enabled ? c.backgroundPrimary : c.backgroundSecondary,
                          boxShadow: hoverHalo ??
                              <BoxShadow>[
                                BoxShadow(
                                  color: Color(theme.isDark ? 0x66000000 : 0x33000000),
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
