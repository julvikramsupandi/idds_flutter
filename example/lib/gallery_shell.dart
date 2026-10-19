import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'pages/brand_page.dart';
import 'pages/home_page.dart';
import 'sections/button_section.dart';
import 'sections/chart_section.dart';
import 'sections/content_section.dart';
import 'sections/date_section.dart';
import 'sections/display_section.dart';
import 'sections/dropdown_section.dart';
import 'sections/feedback_section.dart';
import 'sections/file_upload_section.dart';
import 'sections/form_section.dart';
import 'sections/misc_section.dart';
import 'sections/more_inputs_section.dart';
import 'sections/navigation_section.dart';
import 'sections/overlay_section.dart';
import 'sections/table_section.dart';

/// Satu halaman galeri di menu.
class _Page {
  const _Page(this.id, this.title, this.icon, this.builder);

  final String id;
  final String title;
  final IconData icon;
  final WidgetBuilder builder;
}

/// Kelompok menu.
class _Group {
  const _Group(this.title, this.pages);

  final String title;
  final List<_Page> pages;
}

/// Kerangka galeri: sidebar di layar lebar (≥ 1024px), drawer di layar
/// sempit. Setiap kelompok komponen punya halaman sendiri.
class GalleryShell extends StatefulWidget {
  const GalleryShell({
    super.key,
    required this.brand,
    required this.brightness,
    required this.onBrandChanged,
    required this.onBrightnessChanged,
  });

  final IddsBrand brand;
  final Brightness brightness;
  final ValueChanged<IddsBrand> onBrandChanged;
  final ValueChanged<Brightness> onBrightnessChanged;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  String _current = 'home';

  late final List<_Group> _groups = <_Group>[
    _Group('Mulai', <_Page>[
      _Page(
        'home',
        'Beranda',
        TablerIcons.layout_dashboard,
        (BuildContext context) => HomePage(brand: widget.brand, onBrandChanged: widget.onBrandChanged),
      ),
      _Page(
        'brand',
        'Brand & Warna',
        TablerIcons.palette,
        (BuildContext context) => _scroll(BrandPage(brand: widget.brand, onBrandChanged: widget.onBrandChanged)),
      ),
    ]),
    _Group('Aksi & Tampilan', <_Page>[
      _Page('button', 'Button', TablerIcons.click, (_) => _scroll(const ButtonSection())),
      _Page('badge', 'Badge', TablerIcons.tag, (_) => _scroll(const BadgeSection())),
      _Page('avatar', 'Avatar', TablerIcons.user_circle, (_) => _scroll(const AvatarSection())),
      _Page('alert', 'Alert', TablerIcons.alert_triangle, (_) => _scroll(const AlertSection())),
      _Page('content', 'Accordion, Card & Loading', TablerIcons.layout_cards, (_) => _scroll(const ContentSection())),
    ]),
    _Group('Form', <_Page>[
      _Page('form', 'Text Input, Checkbox & Radio', TablerIcons.forms, (_) => _scroll(const FormSection())),
      _Page('inputs', 'Input lainnya', TablerIcons.password, (_) => _scroll(const MoreInputsSection())),
      _Page('dropdown', 'Dropdown', TablerIcons.selector, (_) => _scroll(const DropdownSection())),
      _Page('date', 'Date Picker', TablerIcons.calendar, (_) => _scroll(const DateSection())),
      _Page('upload', 'File Upload', TablerIcons.file_upload, (_) => _scroll(const FileUploadSection())),
    ]),
    _Group('Umpan Balik', <_Page>[
      _Page('overlay', 'Modal & Drawer', TablerIcons.app_window, (_) => _scroll(const OverlaySection())),
      _Page('feedback', 'Toast & Tooltip', TablerIcons.bell, (_) => _scroll(const FeedbackSection())),
    ]),
    _Group('Data', <_Page>[
      _Page('table', 'Table', TablerIcons.table, (_) => _scroll(const TableSection())),
      _Page('chart', 'Grafik', TablerIcons.chart_line, (_) => _scroll(const ChartSection())),
    ]),
    _Group('Navigasi', <_Page>[
      _Page('navigation', 'Chip, Tab, Stepper & Pagination', TablerIcons.route, (_) => _scroll(const NavigationSection())),
      _Page('misc', 'Lainnya', TablerIcons.components, (_) => _scroll(const MiscSection())),
    ]),
  ];

  static Widget _scroll(Widget child) => SingleChildScrollView(
        padding: const EdgeInsets.all(IddsSpacing.s24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[child]),
      );

  _Page get _page => _groups.expand((_Group g) => g.pages).firstWhere((_Page p) => p.id == _current);

  void _select(String id) => setState(() => _current = id);

  void _openDrawer() {
    showIddsDrawer<void>(
      context: context,
      position: IddsDrawerPosition.left,
      width: 300,
      builder: (BuildContext context) => IddsDrawer(
        title: const Text('idds_flutter'),
        padding: EdgeInsets.zero,
        child: _Menu(
          groups: _groups,
          current: _current,
          onSelected: (String id) {
            Navigator.pop(context);
            _select(id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= IddsBreakpoint.lg;
    final BorderSide line = BorderSide(color: c.strokePrimary);

    final Widget topBar = Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s16),
      decoration: BoxDecoration(color: c.backgroundPrimary, border: Border(bottom: line)),
      child: Row(
        spacing: IddsSpacing.s12,
        children: <Widget>[
          if (!wide)
            IddsButton(
              hierarchy: IddsButtonHierarchy.tertiary,
              size: IddsButtonSize.sm,
              semanticLabel: 'Buka menu',
              onPressed: _openDrawer,
              child: const Icon(TablerIcons.menu_2),
            ),
          Expanded(
            child: Text(
              _page.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textStyle(
                fontSize: IddsFontSize.lg,
                lineHeight: IddsLineHeight.lg,
                fontWeight: IddsFontWeight.semibold,
                color: c.contentPrimary,
              ),
            ),
          ),
          if (width >= IddsBreakpoint.sm)
            SizedBox(
              width: 220,
              child: IddsSelect<String>(
                size: IddsDropdownSize.sm,
                options: <IddsSelectOption<String>>[
                  for (final IddsBrand b in galleryBrands) IddsSelectOption<String>(value: b.id, label: b.name),
                ],
                value: widget.brand.id,
                onChanged: (String? id) {
                  if (id != null) widget.onBrandChanged(galleryBrands.firstWhere((IddsBrand b) => b.id == id));
                },
              ),
            ),
          IddsThemeToggle(
            dark: widget.brightness == Brightness.dark,
            size: IddsThemeToggleSize.md,
            onChanged: (bool dark) => widget.onBrightnessChanged(dark ? Brightness.dark : Brightness.light),
          ),
        ],
      ),
    );

    // Key per halaman: state tiap halaman dibuat baru saat berpindah menu.
    final Widget content = KeyedSubtree(key: ValueKey<String>(_current), child: Builder(builder: _page.builder));

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (wide)
              Container(
                width: 280,
                decoration: BoxDecoration(color: c.backgroundPrimary, border: Border(right: line)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s16),
                      alignment: AlignmentDirectional.centerStart,
                      decoration: BoxDecoration(border: Border(bottom: line)),
                      child: Text(
                        'IDDS Flutter',
                        style: theme.textStyle(
                          fontSize: IddsFontSize.lg,
                          lineHeight: IddsLineHeight.lg,
                          fontWeight: IddsFontWeight.bold,
                          color: c.primaryMain,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _Menu(groups: _groups, current: _current, onSelected: _select),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[topBar, Expanded(child: content)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.groups, required this.current, required this.onSelected});

  final List<_Group> groups;
  final String current;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final _Group group in groups)
          IddsList(
            padding: const EdgeInsets.only(top: IddsSpacing.s8),
            subheader: IddsListSubheader(group.title),
            children: <Widget>[
              for (final _Page page in group.pages)
                IddsListItem(
                  dense: true,
                  leading: Icon(page.icon),
                  title: Text(page.title),
                  selected: page.id == current,
                  onTap: () => onSelected(page.id),
                ),
            ],
          ),
        const SizedBox(height: IddsSpacing.s16),
      ],
    );
  }
}
