import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

/// Bilah atas sederhana untuk layar contoh mobile: tombol kembali opsional,
/// judul, dan aksi di kanan. Memberi jarak status bar lewat
/// `MediaQuery.padding.top`.
class MobileAppBar extends StatelessWidget {
  const MobileAppBar(
      {super.key,
      required this.title,
      this.onBack,
      this.actions = const <Widget>[]});

  final Widget title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(bottom: BorderSide(color: c.strokePrimary)),
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: <Widget>[
            const SizedBox(width: IddsSpacing.s8),
            if (onBack != null)
              IddsButton(
                hierarchy: IddsButtonHierarchy.tertiary,
                size: IddsButtonSize.sm,
                semanticLabel: 'Kembali',
                onPressed: onBack,
                child: const Icon(TablerIcons.arrow_left),
              )
            else
              const SizedBox(width: IddsSpacing.s8),
            const SizedBox(width: IddsSpacing.s4),
            Expanded(
              child: DefaultTextStyle(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textStyle(
                  fontSize: IddsFontSize.base,
                  lineHeight: IddsLineHeight.base,
                  fontWeight: IddsFontWeight.semibold,
                  color: c.contentPrimary,
                ),
                child: title,
              ),
            ),
            ...actions,
            const SizedBox(width: IddsSpacing.s8),
          ],
        ),
      ),
    );
  }
}

/// Judul bagian di layar contoh, dengan tautan opsional di kanan.
class MobileSectionTitle extends StatelessWidget {
  const MobileSectionTitle(this.text, {super.key, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            text,
            style: theme.textStyle(
              fontSize: IddsFontSize.base,
              lineHeight: IddsLineHeight.base,
              fontWeight: IddsFontWeight.semibold,
              color: theme.colors.contentPrimary,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

/// Bilah tombol yang menempel di bawah layar (di atas indikator beranda),
/// pola umum untuk aksi utama form di mobile.
class MobileBottomBar extends StatelessWidget {
  const MobileBottomBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Container(
      padding: EdgeInsets.fromLTRB(
        IddsSpacing.s16,
        IddsSpacing.s12,
        IddsSpacing.s16,
        IddsSpacing.s12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(top: BorderSide(color: c.strokePrimary)),
      ),
      child: Row(
        spacing: IddsSpacing.s12,
        children: <Widget>[
          for (final Widget child in children) Expanded(child: child)
        ],
      ),
    );
  }
}
