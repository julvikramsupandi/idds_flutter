import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_primitives.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Kotak centang IDDS, dengan label dan teks pendukung opsional.
///
/// ```dart
/// IddsCheckbox(
///   value: _agreed,
///   onChanged: (v) => setState(() => _agreed = v),
///   label: 'Saya menyetujui syarat dan ketentuan',
/// )
/// ```
///
/// Nonaktif bila [onChanged] bernilai `null`. Di layar < 768px kotak dan
/// teks memakai ukuran lebih kecil (16px), sama seperti versi web.
class IddsCheckbox extends StatelessWidget {
  /// Membuat checkbox.
  const IddsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.indeterminate = false,
    this.label,
    this.subtext,
    this.invalid = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// Tercentang.
  final bool value;

  /// Dipanggil dengan nilai baru (`!value`). `null` membuat checkbox nonaktif.
  final ValueChanged<bool>? onChanged;

  /// Tampilkan tanda strip (sebagian terpilih). Lebih diutamakan dari
  /// tanda centang.
  final bool indeterminate;

  /// Teks di sebelah kotak.
  final String? label;

  /// Teks pendukung di bawah [label].
  final String? subtext;

  /// Tampilkan garis tepi merah (hanya saat tidak tercentang).
  final bool invalid;

  /// Focus node opsional.
  final FocusNode? focusNode;

  /// Langsung mendapat fokus.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool large = !iddsIsCompact(context, IddsBreakpoint.md);
    final double boxSize = large ? 20 : 16;
    final bool enabled = onChanged != null;
    final bool marked = value || indeterminate;
    final VoidCallback? onTap = enabled ? () => onChanged!(!value) : null;

    return Semantics(
      container: true,
      checked: indeterminate ? null : value,
      mixed: indeterminate ? true : null,
      enabled: enabled,
      label: label,
      hint: subtext,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (BuildContext context, IddsInteractionState state) {
          final Color background;
          final Color border;
          if (!enabled) {
            background = c.backgroundTertiary;
            border = c.strokeSecondary;
          } else if (marked) {
            background = c.contentPrimary;
            border = c.contentPrimary;
          } else if (invalid) {
            background = c.backgroundPrimary;
            border = state.hovered ? c.negative.shade600 : c.negative.shade500;
          } else {
            background = c.backgroundPrimary;
            border = state.hovered ? c.strokeSecondary : IddsPrimitives.neutral.shade500;
          }
          final BorderRadius radius = BorderRadius.circular(IddsRadius.base);

          final Widget box = IddsInsetRing(
            visible: state.focused,
            borderRadius: radius,
            inset: 1,
            // CSS: inset 0 0 0 1px #fff, inset 0 0 0 2px content-primary.
            rings: <(double, Color)>[(1.0, const Color(0xFFFFFFFF)), (1.0, c.contentPrimary)],
            child: AnimatedContainer(
              duration: IddsDuration.fast,
              curve: IddsCurves.standard,
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                color: background,
                borderRadius: radius,
                border: Border.all(color: border),
              ),
              alignment: Alignment.center,
              child: marked
                  ? IddsIcon(
                      indeterminate ? IddsIcons.minus : IddsIcons.check,
                      size: 14,
                      strokeWidth: 4,
                      color: enabled ? c.white : IddsPrimitives.neutral.shade400,
                    )
                  : null,
            ),
          );

          if (label == null && subtext == null) return box;

          final Widget texts = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (label != null)
                Text(
                  label!,
                  style: theme.textStyle(
                    fontSize: large ? IddsFontSize.base : IddsFontSize.sm,
                    lineHeight: boxSize,
                  ),
                ),
              if (subtext != null)
                Text(
                  subtext!,
                  style: theme.textStyle(
                    fontSize: large ? IddsFontSize.sm : IddsFontSize.xs,
                    lineHeight: large ? IddsLineHeight.sm : IddsLineHeight.xs,
                    color: c.contentSecondary,
                  ),
                ),
            ],
          );

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: subtext == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              spacing: IddsSpacing.s12,
              children: <Widget>[
                box,
                // Teks boleh membungkus bila lebar dibatasi; di dalam Row tanpa
                // batas lebar, Flexible akan error.
                if (constraints.hasBoundedWidth) Flexible(child: texts) else texts,
              ],
            ),
          );
        },
      ),
    );
  }
}
