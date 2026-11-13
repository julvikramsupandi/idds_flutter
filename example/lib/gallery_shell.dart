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
    required this.page,
    required this.onPageChanged,
    required this.brand,
    required this.brightness,
    required this.onBrandChanged,
    required this.onBrightnessChanged,
  });

  /// Id halaman awal, juga dipakai sebagai URL (`/#/button`).
  static const String homePage = 'home';

  /// Id halaman yang ditampilkan. Id yang tidak dikenal menampilkan Beranda.
  final String page;

  /// Dipanggil saat menu dipilih; induk memperbarui URL lalu [page].
  final ValueChanged<String> onPageChanged;

  final IddsBrand brand;
  final Brightness brightness;
  final ValueChanged<IddsBrand> onBrandChanged;
  final ValueChanged<Brightness> onBrightnessChanged;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  late final List<_Group> _groups = <_Group>[
    _Group('Mulai', <_Page>[
      _Page(
        GalleryShell.homePage,
        'Beranda',
        TablerIcons.layout_dashboard,
        (BuildContext context) => HomePage(
          brand: widget.brand,
          onBrandChanged: widget.onBrandChanged,
        ),
      ),
      _Page(
        'brand',
        'Brand & Warna',
        TablerIcons.palette,
        (BuildContext context) => _scroll(
          BrandPage(brand: widget.brand, onBrandChanged: widget.onBrandChanged),
        ),
      ),
    ]),
    _Group('Aksi', <_Page>[
      _section('button', 'Button', TablerIcons.click, const ButtonSection()),
      _section('button-group', 'Button Group', TablerIcons.box_multiple,
          const ButtonGroupSection()),
      _section('action-menu', 'Action Menu', TablerIcons.dots_vertical,
          const ActionMenuSection()),
    ]),
    _Group('Input', <_Page>[
      _section('text-field', 'Text Field', TablerIcons.forms,
          const TextFieldSection()),
      _section('text-area', 'Text Area', TablerIcons.align_left,
          const TextAreaSection()),
      _section(
          'password', 'Password', TablerIcons.lock, const PasswordSection()),
      _section('search', 'Search', TablerIcons.search, const SearchSection()),
      _section(
          'phone', 'Phone Input', TablerIcons.phone, const PhoneInputSection()),
      _section('otp', 'OTP', TablerIcons.shield_lock, const OtpSection()),
      _section('checkbox', 'Checkbox', TablerIcons.checkbox,
          const CheckboxSection()),
      _section('radio', 'Radio', TablerIcons.circle_dot, const RadioSection()),
      _section(
          'toggle', 'Toggle', TablerIcons.toggle_right, const ToggleSection()),
      _section('select', 'Select', TablerIcons.selector, const SelectSection()),
      _section('dropdown', 'Dropdown', TablerIcons.caret_down,
          const DropdownSection()),
      _section('upload', 'File Upload', TablerIcons.file_upload,
          const FileUploadSection()),
    ]),
    _Group('Tanggal & Waktu', <_Page>[
      _section('date', 'Date Picker', TablerIcons.calendar,
          const DatePickerSection()),
      _section('calendar', 'Calendar', TablerIcons.calendar_month,
          const CalendarSection()),
      _section(
          'time', 'Time Picker', TablerIcons.clock, const TimePickerSection()),
      _section('month-year', 'Month/Year Picker', TablerIcons.calendar_event,
          const MonthYearPickerSection()),
    ]),
    _Group('Tampilan Data', <_Page>[
      _section(
          'avatar', 'Avatar', TablerIcons.user_circle, const AvatarSection()),
      _section('badge', 'Badge', TablerIcons.tag, const BadgeSection()),
      _section('card', 'Card', TablerIcons.layout_cards, const CardSection()),
      _section('list', 'List', TablerIcons.list, const ListSection()),
      _section('accordion', 'Accordion', TablerIcons.layout_navbar_collapse,
          const AccordionSection()),
      _section('divider', 'Divider', TablerIcons.separator_horizontal,
          const DividerSection()),
      _section('table', 'Table', TablerIcons.table, const TableSection()),
      _section('chart', 'Grafik', TablerIcons.chart_line, const ChartSection()),
    ]),
    _Group('Umpan Balik', <_Page>[
      _section(
          'alert', 'Alert', TablerIcons.alert_triangle, const AlertSection()),
      _section('toast', 'Toast', TablerIcons.bell, const ToastSection()),
      _section('tooltip', 'Tooltip', TablerIcons.message_circle,
          const TooltipSection()),
      _section('modal', 'Modal', TablerIcons.app_window, const ModalSection()),
      _section('drawer', 'Drawer', TablerIcons.layout_sidebar,
          const DrawerSection()),
      _section('bottom-sheet', 'Bottom Sheet', TablerIcons.layout_bottombar,
          const BottomSheetSection()),
      _section(
          'loading', 'Loading', TablerIcons.loader, const LoadingSection()),
    ]),
    _Group('Navigasi', <_Page>[
      _section(
          'tab', 'Tab Menu', TablerIcons.layout_navbar, const TabMenuSection()),
      _section(
          'stepper', 'Stepper', TablerIcons.timeline, const StepperSection()),
      _section('breadcrumb', 'Breadcrumb', TablerIcons.chevrons_right,
          const BreadcrumbSection()),
      _section('pagination', 'Pagination', TablerIcons.dots,
          const PaginationSection()),
      _section('chip', 'Chip', TablerIcons.tags, const ChipSection()),
    ]),
    _Group('Lainnya', <_Page>[
      _section('choice-grid', 'Multiple Choice Grid', TablerIcons.grid_dots,
          const ChoiceGridSection()),
      _section('theme-toggle', 'Theme Toggle', TablerIcons.sun_moon,
          const ThemeToggleSection()),
    ]),
  ];

  /// Alamat halaman gabungan versi lama → halaman komponen pertamanya, agar
  /// tautan lama (mis. `/#/content`) tetap berfungsi.
  static const Map<String, String> _aliases = <String, String>{
    'content': 'accordion',
    'form': 'text-field',
    'inputs': 'text-area',
    'overlay': 'modal',
    'feedback': 'toast',
    'navigation': 'chip',
    'misc': 'list',
  };

  static _Page _section(
          String id, String title, IconData icon, Widget section) =>
      _Page(id, title, icon, (_) => _scroll(section));

  static Widget _scroll(Widget child) => SingleChildScrollView(
        padding: const EdgeInsets.all(IddsSpacing.s24),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[child]),
      );

  Iterable<_Page> get _pages => _groups.expand((_Group g) => g.pages);

  _Page get _activePage {
    final String id = _aliases[widget.page] ?? widget.page;
    return _pages.firstWhere((_Page p) => p.id == id,
        orElse: () => _pages.first);
  }

  String get _current => _activePage.id;

  void _select(String id) => widget.onPageChanged(id);

  void _openDrawer() {
    showIddsDrawer<void>(
      context: context,
      position: IddsDrawerPosition.left,
      width: 300,
      // Menu navigasi tetap dari samping di HP, bukan panel bawah.
      bottomOnSmallScreens: false,
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
      decoration: BoxDecoration(
          color: c.backgroundPrimary, border: Border(bottom: line)),
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
              _activePage.title,
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
                  for (final IddsBrand b in galleryBrands)
                    IddsSelectOption<String>(value: b.id, label: b.name),
                ],
                value: widget.brand.id,
                onChanged: (String? id) {
                  if (id != null) {
                    widget.onBrandChanged(
                        galleryBrands.firstWhere((IddsBrand b) => b.id == id));
                  }
                },
              ),
            ),
          IddsThemeToggle(
            dark: widget.brightness == Brightness.dark,
            size: IddsThemeToggleSize.md,
            onChanged: (bool dark) => widget
                .onBrightnessChanged(dark ? Brightness.dark : Brightness.light),
          ),
        ],
      ),
    );

    // Key per halaman: state tiap halaman dibuat baru saat berpindah menu.
    final Widget content = KeyedSubtree(
        key: ValueKey<String>(_current),
        child: Builder(builder: _activePage.builder));

    // Judul tab browser mengikuti halaman yang dibuka.
    return Title(
      title: '${_activePage.title} · idds_flutter',
      color: c.primaryMain,
      child: Scaffold(
        backgroundColor: c.backgroundPrimary,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (wide)
                Container(
                  width: 280,
                  decoration: BoxDecoration(
                      color: c.backgroundPrimary, border: Border(right: line)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(
                            horizontal: IddsSpacing.s16),
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
                        child: _Menu(
                          groups: _groups,
                          current: _current,
                          onSelected: _select,
                          // Pencarian menempel di atas, daftar digulir.
                          expand: true,
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
      ),
    );
  }
}

/// Daftar menu galeri dengan kotak pencarian komponen.
class _Menu extends StatefulWidget {
  const _Menu({
    required this.groups,
    required this.current,
    required this.onSelected,
    this.expand = false,
  });

  final List<_Group> groups;
  final String current;
  final ValueChanged<String> onSelected;

  /// `true`: mengisi tinggi induk, pencarian tetap di atas dan daftar
  /// digulir sendiri (sidebar). `false`: setinggi isinya (di dalam drawer
  /// yang sudah bisa digulir).
  final bool expand;

  @override
  State<_Menu> createState() => _MenuState();
}

class _MenuState extends State<_Menu> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final String q = _query.trim().toLowerCase();
    final List<_Group> groups = <_Group>[
      for (final _Group g in widget.groups)
        if (q.isEmpty)
          g
        else if (g.pages.any((_Page p) => p.title.toLowerCase().contains(q)))
          _Group(g.title, <_Page>[
            for (final _Page p in g.pages)
              if (p.title.toLowerCase().contains(q)) p,
          ]),
    ];

    final Widget search = Padding(
      padding: const EdgeInsets.fromLTRB(
        IddsSpacing.s16,
        IddsSpacing.s12,
        IddsSpacing.s16,
        IddsSpacing.s4,
      ),
      child: IddsSearchField(
        size: IddsTextFieldSize.sm,
        placeholder: 'Cari komponen',
        debounce: Duration.zero,
        onChanged: (String v) => setState(() => _query = v),
      ),
    );

    final Widget list = Column(
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
                  selected: page.id == widget.current,
                  onTap: () => widget.onSelected(page.id),
                ),
            ],
          ),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.all(IddsSpacing.s16),
            child: Text(
              'Tidak ada komponen "${_query.trim()}".',
              style: IddsTheme.of(context).textStyle(
                fontSize: IddsFontSize.sm,
                lineHeight: IddsLineHeight.sm,
                color: IddsTheme.of(context).colors.contentSecondary,
              ),
            ),
          ),
        const SizedBox(height: IddsSpacing.s16),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        search,
        if (widget.expand)
          Expanded(child: SingleChildScrollView(child: list))
        else
          list,
      ],
    );
  }
}
