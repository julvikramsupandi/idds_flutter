import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Daftar vertikal (List IDDS) berisi [IddsListItem] dan
/// [IddsListSubheader].
class IddsList extends StatelessWidget {
  /// Membuat daftar.
  const IddsList({
    super.key,
    required this.children,
    this.subheader,
    this.dividers = false,
    this.padding = const EdgeInsets.symmetric(vertical: IddsSpacing.s8),
  });

  /// Item-item.
  final List<Widget> children;

  /// Judul daftar di paling atas.
  final Widget? subheader;

  /// Garis pemisah antar item.
  final bool dividers;

  /// Jarak atas-bawah daftar.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (subheader != null) subheader!,
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (dividers && i > 0) Container(height: 1, color: c.strokePrimary),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Judul kelompok di [IddsList].
class IddsListSubheader extends StatelessWidget {
  /// Membuat judul kelompok.
  const IddsListSubheader(this.label, {super.key, this.inset = false});

  /// Teks.
  final String label;

  /// Menjorok 32px dari kiri (React: `inset`, `pl-8`).
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    // React: px-4 py-1 (pl-8 bila inset), text-sm semibold uppercase,
    // warna gray-600.
    return Semantics(
      header: true,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(inset ? IddsSpacing.s32 : IddsSpacing.s16, IddsSpacing.s4, IddsSpacing.s16, IddsSpacing.s4),
        child: Text(
          label.toUpperCase(),
          style: theme.textStyle(
            fontSize: IddsFontSize.sm,
            lineHeight: IddsLineHeight.sm,
            fontWeight: IddsFontWeight.semibold,
            color: theme.colors.contentSecondary,
          ),
        ),
      ),
    );
  }
}

/// Satu baris [IddsList]: ikon/avatar di kiri, teks utama dan sekunder, dan
/// widget di kanan (mis. badge, toggle, chevron).
class IddsListItem extends StatelessWidget {
  /// Membuat item.
  const IddsListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.enabled = true,
    this.dense = false,
    this.alignTop = false,
  });

  /// Teks utama.
  final Widget title;

  /// Teks sekunder di bawah [title].
  final Widget? subtitle;

  /// Ikon atau avatar di kiri.
  final Widget? leading;

  /// Widget di kanan.
  final Widget? trailing;

  /// Bila diisi, item bisa ditekan (List Item Button).
  final VoidCallback? onTap;

  /// Ditandai terpilih.
  final bool selected;

  /// Apakah item aktif.
  final bool enabled;

  /// Jarak lebih rapat.
  final bool dense;

  /// Ikon/avatar sejajar atas (untuk teks beberapa baris).
  final bool alignTop;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;

    Widget body(IddsInteractionState? state) {
      final bool hovered = state?.hovered ?? false;
      final bool pressed = state?.pressed ?? false;
      return Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AnimatedContainer(
          duration: IddsDuration.fast,
          padding: EdgeInsets.symmetric(horizontal: IddsSpacing.s16, vertical: dense ? IddsSpacing.s4 : IddsSpacing.s8),
          constraints: BoxConstraints(minHeight: dense ? 36 : 48),
          color: pressed
              ? c.backgroundTertiary
              : selected || hovered
                  ? c.backgroundSecondary
                  : null,
          // React: ikon/avatar mr-3 (12px).
          child: Row(
            crossAxisAlignment: alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            spacing: IddsSpacing.s12,
            children: <Widget>[
              if (leading != null)
                IconTheme(
                  data: IconThemeData(size: 20, color: c.contentSecondary),
                  child: leading!,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: <Widget>[
                    DefaultTextStyle(
                      style: theme.textStyle(
                        fontSize: dense ? IddsFontSize.xs : IddsFontSize.sm,
                        lineHeight: dense ? IddsLineHeight.xs : IddsLineHeight.sm,
                        fontWeight: selected ? IddsFontWeight.semibold : IddsFontWeight.normal,
                        color: c.contentPrimary,
                      ),
                      child: title,
                    ),
                    if (subtitle != null)
                      DefaultTextStyle(
                        style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary),
                        child: subtitle!,
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                IconTheme(data: IconThemeData(size: 20, color: c.contentSecondary), child: trailing!),
            ],
          ),
        ),
      );
    }

    if (onTap == null) return Semantics(selected: selected, child: body(null));
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: IddsInteractive(
        onTap: enabled ? onTap : null,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.zero,
          rings: <(double, Color)>[(2.0, c.primary.shade500)],
          child: body(state),
        ),
      ),
    );
  }
}
