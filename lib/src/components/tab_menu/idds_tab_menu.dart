import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Gaya [IddsTabMenu].
enum IddsTabVariant {
  /// Garis bawah (horizontal) atau garis kiri (vertikal) pada tab terpilih.
  outline,

  /// Tab terpilih berlatar warna brand muda.
  buttonBrand,

  /// Tab di dalam wadah abu-abu, tab terpilih berlatar putih dengan bayangan.
  buttonWhite,
}

/// Ukuran [IddsTabMenu].
enum IddsTabSize {
  /// Tinggi 36px, font 14px (32px / 12px di layar < 768px).
  sm,

  /// Tinggi 40px, font 16px (36px / 14px di layar < 768px).
  md,
}

/// Satu tab di [IddsTabMenu].
@immutable
class IddsTabItem<T> {
  /// Membuat tab.
  const IddsTabItem({required this.value, required this.label, this.enabled = true});

  /// Nilai tab.
  final T value;

  /// Isi tab, biasanya [Text].
  final Widget label;

  /// Apakah tab bisa dipilih.
  final bool enabled;
}

/// Menu tab horizontal atau vertikal.
///
/// Widget ini hanya menampilkan tab dan melaporkan pilihan; isi tiap tab
/// diatur sendiri oleh pemanggil berdasarkan [value].
///
/// ```dart
/// IddsTabMenu<String>(
///   value: _tab,
///   onChanged: (v) => setState(() => _tab = v),
///   items: const [
///     IddsTabItem(value: 'profil', label: Text('Profil')),
///     IddsTabItem(value: 'dokumen', label: Text('Dokumen')),
///   ],
/// )
/// ```
class IddsTabMenu<T> extends StatelessWidget {
  /// Membuat menu tab.
  const IddsTabMenu({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.direction = Axis.horizontal,
    this.variant = IddsTabVariant.outline,
    this.size = IddsTabSize.sm,
    this.fullWidth = false,
    this.useBrandColor = false,
    this.width,
  });

  /// Tab yang tersedia.
  final List<IddsTabItem<T>> items;

  /// Tab terpilih.
  final T? value;

  /// Dipanggil dengan nilai tab baru. `null` membuat semua tab nonaktif.
  final ValueChanged<T>? onChanged;

  /// Horizontal (bawaan) atau vertikal.
  final Axis direction;

  /// Gaya.
  final IddsTabVariant variant;

  /// Ukuran.
  final IddsTabSize size;

  /// Horizontal: tab membagi rata lebar yang tersedia (minimal 120px per tab;
  /// bisa digeser bila tidak muat).
  final bool fullWidth;

  /// Pakai warna brand untuk tab terpilih pada gaya [IddsTabVariant.outline]
  /// dan [IddsTabVariant.buttonWhite].
  final bool useBrandColor;

  /// Vertikal: lebar menu.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool horizontal = direction == Axis.horizontal;
    // CSS: max-width 768px (inklusif).
    final bool compact = iddsIsCompact(context, IddsBreakpoint.md + 1);
    final double height = switch (size) {
      IddsTabSize.sm => compact ? 32 : 36,
      IddsTabSize.md => compact ? 36 : 40,
    };
    final double fontSize = switch (size) {
      IddsTabSize.sm => compact ? IddsFontSize.xs : IddsFontSize.sm,
      IddsTabSize.md => compact ? IddsFontSize.sm : IddsFontSize.base,
    };

    final List<Widget> tabs = <Widget>[
      for (final IddsTabItem<T> item in items)
        _Tab<T>(
          item: item,
          selected: item.value == value,
          onTap: onChanged != null && item.enabled ? () => onChanged!(item.value) : null,
          enabled: onChanged != null && item.enabled,
          horizontal: horizontal,
          variant: variant,
          useBrandColor: useBrandColor,
          height: height,
          fontSize: fontSize,
        ),
    ];

    Widget menu;
    if (horizontal) {
      final Widget row = Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: fullWidth
            ? <Widget>[for (final Widget tab in tabs) Expanded(child: tab)]
            : tabs,
      );
      menu = !fullWidth
          ? row
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double min = 120.0 * items.length;
                if (constraints.maxWidth >= min) return row;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: min, child: row),
                );
              },
            );
    } else {
      menu = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: tabs,
      );
      menu = width != null ? SizedBox(width: width, child: menu) : IntrinsicWidth(child: menu);
    }

    if (variant == IddsTabVariant.buttonWhite) {
      menu = Container(
        padding: const EdgeInsets.all(IddsSpacing.s4),
        decoration: BoxDecoration(
          color: c.backgroundSecondary,
          borderRadius: BorderRadius.circular(IddsRadius.base),
        ),
        child: menu,
      );
    }

    return Semantics(container: true, explicitChildNodes: true, child: menu);
  }
}

class _Tab<T> extends StatelessWidget {
  const _Tab({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.enabled,
    required this.horizontal,
    required this.variant,
    required this.useBrandColor,
    required this.height,
    required this.fontSize,
  });

  final IddsTabItem<T> item;
  final bool selected;
  final VoidCallback? onTap;
  final bool enabled;
  final bool horizontal;
  final IddsTabVariant variant;
  final bool useBrandColor;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;

    return Semantics(
      selected: selected,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) {
          final bool hovered = state.hovered;
          final Color brand = c.primaryMain;
          Color foreground = c.contentSecondary;
          Color? background;
          Border? border;
          List<BoxShadow>? shadow;
          BorderRadius radius = BorderRadius.circular(IddsRadius.base);

          switch (variant) {
            case IddsTabVariant.outline:
              radius = BorderRadius.zero;
              final Color accent = useBrandColor ? brand : c.contentPrimary;
              if (selected) {
                foreground = accent;
              } else if (hovered) {
                foreground = useBrandColor ? brand : c.contentPrimary;
              }
              if (hovered) background = c.backgroundSecondary;
              border = horizontal
                  ? Border(
                      bottom: selected
                          ? BorderSide(color: accent, width: 2)
                          : BorderSide(color: c.strokePrimary),
                    )
                  : (selected ? Border(left: BorderSide(color: accent, width: 3)) : null);
            case IddsTabVariant.buttonBrand:
              if (selected) {
                // Latar primary-25 tidak berubah di dark mode; teks memakai
                // warna utama mode terang agar tetap terbaca.
                background = hovered ? c.backgroundSecondary : c.primary.shade25;
                foreground = theme.brand.primaryMainLight;
              } else if (hovered) {
                background = c.backgroundSecondary;
                foreground = c.contentPrimary;
              }
            case IddsTabVariant.buttonWhite:
              // Bentuk bayangan selalu sama; hanya warnanya yang transparan
              // saat tidak terpilih. Bila bayangan dihilangkan (null), Flutter
              // mengecilkan blur/offset/spread bersamaan sehingga bayangan
              // sesaat menjadi tajam dan gelap (kilatan abu-abu).
              shadow = <BoxShadow>[
                BoxShadow(
                  color: selected ? const Color(0x140A0D12) : const Color(0x000A0D12),
                  offset: const Offset(0, 12),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: selected ? const Color(0x080A0D12) : const Color(0x000A0D12),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                  spreadRadius: -2,
                ),
              ];
              if (selected) {
                background = c.backgroundPrimary;
                foreground = useBrandColor ? brand : c.contentPrimary;
              } else if (hovered) {
                background = c.backgroundSecondary;
                foreground = useBrandColor ? brand : c.contentPrimary;
              }
          }

          // Cincin fokus: selalu ada dua bayangan (transparan bila tidak
          // fokus) agar animasinya juga hanya memudar, tidak berubah ukuran.
          final Color ringInner = state.focused ? c.backgroundPrimary : c.backgroundPrimary.withValues(alpha: 0);
          final Color ringOuter = state.focused ? c.primary.shade500 : c.primary.shade500.withValues(alpha: 0);
          shadow = <BoxShadow>[
            BoxShadow(color: ringOuter, spreadRadius: 4),
            BoxShadow(color: ringInner, spreadRadius: 2),
            ...?shadow,
          ];

          // Garis kiri 3px menggantikan 3px padding (CSS: padding-left 13px).
          final double leftInset = !horizontal && variant == IddsTabVariant.outline && selected ? 13 : 16;

          return Opacity(
            opacity: enabled ? 1 : 0.6,
            child: AnimatedContainer(
              duration: IddsDuration.base,
              curve: IddsCurves.standard,
              height: height,
              padding: EdgeInsets.only(left: leftInset, right: 16),
              alignment: horizontal ? Alignment.center : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: background,
                border: border,
                borderRadius: border == null ? radius : null,
                boxShadow: shadow,
              ),
              child: DefaultTextStyle(
                style: theme.textStyle(
                  fontSize: fontSize,
                  lineHeight: IddsLineHeight.sm,
                  fontWeight: selected ? IddsFontWeight.semibold : IddsFontWeight.normal,
                  color: foreground,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: IconTheme(
                  data: IconThemeData(size: 16, color: foreground),
                  child: item.label,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
