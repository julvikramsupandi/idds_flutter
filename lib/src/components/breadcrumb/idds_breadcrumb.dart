import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Satu langkah di [IddsBreadcrumb].
@immutable
class IddsBreadcrumbItem {
  /// Membuat langkah.
  const IddsBreadcrumbItem({required this.label, this.onTap, this.icon, this.enabled = true});

  /// Teks.
  final String label;

  /// Dipanggil saat ditekan. Bila `null`, langkah tidak bisa ditekan.
  /// Langkah terakhir (halaman saat ini) tidak pernah bisa ditekan.
  final VoidCallback? onTap;

  /// Ikon di kiri teks.
  final Widget? icon;

  /// Apakah langkah aktif.
  final bool enabled;
}

/// Jejak navigasi halaman.
///
/// ```dart
/// IddsBreadcrumb(items: [
///   IddsBreadcrumbItem(label: 'Beranda', onTap: () => context.go('/')),
///   IddsBreadcrumbItem(label: 'Layanan', onTap: () => context.go('/layanan')),
///   const IddsBreadcrumbItem(label: 'Beasiswa'),
/// ])
/// ```
class IddsBreadcrumb extends StatelessWidget {
  /// Membuat breadcrumb.
  const IddsBreadcrumb({
    super.key,
    required this.items,
    this.separator,
    this.maxLength,
    this.semanticLabel = 'Breadcrumb',
  });

  /// Langkah-langkah, dari paling umum ke halaman saat ini.
  final List<IddsBreadcrumbItem> items;

  /// Pemisah antar langkah. Bawaan: ikon chevron kanan 14px.
  final Widget? separator;

  /// Panjang maksimal teks langkah terakhir sebelum dipotong dengan "...".
  final int? maxLength;

  /// Label untuk pembaca layar.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool large = !iddsIsCompact(context, IddsBreakpoint.md);
    final double fontSize = large ? IddsFontSize.sm : IddsFontSize.xs;
    final double lineHeight = large ? IddsLineHeight.sm : IddsLineHeight.xs;

    final Widget sep = Padding(
      padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s4),
      child: IconTheme(
        data: IconThemeData(size: 14, color: c.contentSecondary),
        child: DefaultTextStyle(
          style: theme.textStyle(fontSize: fontSize, lineHeight: lineHeight, color: c.contentSecondary),
          child: separator ?? const IddsIcon(IddsIcons.chevronRight),
        ),
      ),
    );

    return Semantics(
      container: true,
      label: semanticLabel,
      explicitChildNodes: true,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: IddsSpacing.s4,
        runSpacing: IddsSpacing.s4,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) ExcludeSemantics(child: sep),
            _Crumb(
              item: items[i],
              current: i == items.length - 1,
              maxLength: i == items.length - 1 ? maxLength : null,
              fontSize: fontSize,
              lineHeight: lineHeight,
            ),
          ],
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({
    required this.item,
    required this.current,
    required this.maxLength,
    required this.fontSize,
    required this.lineHeight,
  });

  final IddsBreadcrumbItem item;
  final bool current;
  final int? maxLength;
  final double fontSize;
  final double lineHeight;

  String get _text {
    final int? max = maxLength;
    if (max == null || item.label.length <= max) return item.label;
    return '${item.label.substring(0, max)}...';
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final VoidCallback? onTap = !current && item.enabled ? item.onTap : null;

    Widget content(bool hovered) {
      final Color color = current || hovered ? c.contentPrimary : c.contentSecondary;
      return Opacity(
        opacity: item.enabled ? 1 : 0.5,
        child: IconTheme(
          data: IconThemeData(size: fontSize + 2, color: color),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: IddsSpacing.s4,
            children: <Widget>[
              if (item.icon != null) item.icon!,
              // Tanpa Flexible: breadcrumb sering diletakkan di Row tanpa batas
              // lebar. Teks panjang dipotong lewat maxLength.
              Text(
                _text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .textStyle(
                      fontSize: fontSize,
                      lineHeight: lineHeight,
                      fontWeight: current ? IddsFontWeight.medium : IddsFontWeight.normal,
                      color: color,
                    )
                    .copyWith(
                      decoration: hovered ? TextDecoration.underline : TextDecoration.none,
                      decorationColor: color,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (onTap == null) {
      return Semantics(
        // Langkah terakhir = halaman saat ini (aria-current="page" di web).
        selected: current,
        child: content(false),
      );
    }

    return Semantics(
      link: true,
      onTap: onTap,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => Container(
          decoration: state.focused
              ? BoxDecoration(
                  color: c.backgroundTertiary,
                  borderRadius: BorderRadius.circular(IddsRadius.sm),
                  boxShadow: <BoxShadow>[BoxShadow(color: c.primary.shade600, spreadRadius: 2)],
                )
              : null,
          child: content(state.hovered),
        ),
      ),
    );
  }
}
