import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class MiscSection extends StatefulWidget {
  const MiscSection({super.key});

  @override
  State<MiscSection> createState() => _MiscSectionState();
}

class _MiscSectionState extends State<MiscSection> {
  int? _month = DateTime.now().month;
  int? _year = DateTime.now().year;
  bool _dark = false;
  String _service = 'ktp';
  Map<String, String> _survey = <String, String>{};

  static const List<IddsChoiceGridItem> _scale = <IddsChoiceGridItem>[
    IddsChoiceGridItem(id: '1', label: 'Sangat kurang'),
    IddsChoiceGridItem(id: '2', label: 'Kurang'),
    IddsChoiceGridItem(id: '3', label: 'Cukup'),
    IddsChoiceGridItem(id: '4', label: 'Baik'),
    IddsChoiceGridItem(id: '5', label: 'Sangat baik'),
  ];

  void _openSheet({required bool locked}) {
    showIddsBottomSheet<void>(
      context: context,
      locked: locked,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(IddsSpacing.s16, 0, IddsSpacing.s16, IddsSpacing.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: IddsSpacing.s12,
          children: <Widget>[
            Text(
              locked ? 'Panel terkunci' : 'Bagikan dokumen',
              style: IddsTheme.of(context).textStyle(
                fontSize: IddsFontSize.lg,
                lineHeight: IddsLineHeight.lg,
                fontWeight: IddsFontWeight.semibold,
              ),
            ),
            Text(locked
                ? 'Panel ini hanya bisa ditutup dengan tombol di bawah.'
                : 'Tarik ke bawah, tekan latar, atau Esc untuk menutup.'),
            IddsButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Lainnya',
      subtitle: 'Month/Year Picker, Theme Toggle, Bottom Sheet, List, dan Multiple Choice Grid.',
      usage: 'Month/Year Picker untuk memilih bulan atau tahun saja. IddsThemeToggle hanya melaporkan nilai: bangun ulang IddsThemeData dengan brightness yang sesuai. Bottom sheet bisa ditarik ke bawah untuk menutup (locked: true untuk mencegahnya).',
      code: _miscCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: IddsMonthPicker(value: _month, clearable: true, onChanged: (int? m) => setState(() => _month = m)),
            ),
            SizedBox(
              width: 160,
              child: IddsYearPicker(value: _year, onChanged: (int? y) => setState(() => _year = y)),
            ),
            IddsThemeToggle(dark: _dark, showLabel: true, onChanged: (bool v) => setState(() => _dark = v)),
            IddsThemeToggle(dark: _dark, size: IddsThemeToggleSize.sm, onChanged: (bool v) => setState(() => _dark = v)),
            IddsButton(
              hierarchy: IddsButtonHierarchy.secondary,
              onPressed: () => _openSheet(locked: false),
              child: const Text('Bottom sheet'),
            ),
            IddsButton(
              hierarchy: IddsButtonHierarchy.tertiary,
              onPressed: () => _openSheet(locked: true),
              child: const Text('Bottom sheet terkunci'),
            ),
          ],
        ),
        const GalleryCaption('Theme Toggle di contoh ini hanya menyimpan nilai; pakai switch di atas halaman untuk mengganti tema.'),
        const SizedBox(height: IddsSpacing.s24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: IddsCardPlain(
            padding: EdgeInsets.zero,
            child: IddsList(
              subheader: const IddsListSubheader('Layanan kependudukan'),
              dividers: true,
              children: <Widget>[
                for (final (String id, String title, String sub, IconData icon) in <(String, String, String, IconData)>[
                  ('ktp', 'KTP Elektronik', 'Perekaman dan pencetakan', TablerIcons.id),
                  ('kk', 'Kartu Keluarga', 'Perubahan data anggota keluarga', TablerIcons.users_group),
                  ('akta', 'Akta Kelahiran', 'Pencatatan kelahiran', TablerIcons.baby_carriage),
                ])
                  IddsListItem(
                    leading: Icon(icon),
                    title: Text(title),
                    subtitle: Text(sub),
                    selected: _service == id,
                    trailing: const IddsIcon(IddsIcons.chevronRight),
                    onTap: () => setState(() => _service = id),
                  ),
                const IddsListItem(title: Text('Surat pindah (segera)'), enabled: false, dense: true),
              ],
            ),
          ),
        ),
        const SizedBox(height: IddsSpacing.s24),
        const GalleryCaption('Survei kepuasan (Multiple Choice Grid)'),
        const SizedBox(height: IddsSpacing.s8),
        IddsChoiceGrid(
          columns: _scale,
          rows: const <IddsChoiceGridItem>[
            IddsChoiceGridItem(id: 'kecepatan', label: 'Kecepatan layanan'),
            IddsChoiceGridItem(id: 'keramahan', label: 'Keramahan petugas'),
            IddsChoiceGridItem(id: 'kejelasan', label: 'Kejelasan informasi'),
          ],
          selected: _survey,
          onChanged: (Map<String, String> v) => setState(() => _survey = v),
        ),
      ],
    );
  }
}

const String _miscCode = r'''
IddsMonthPicker(value: _month, clearable: true, onChanged: (int? m) => setState(() => _month = m))
IddsYearPicker(value: _year, onChanged: (int? y) => setState(() => _year = y))

IddsThemeToggle(dark: _dark, onChanged: (bool v) => setState(() => _dark = v))

showIddsBottomSheet<void>(
  context: context,
  builder: (BuildContext context) => const Padding(
    padding: EdgeInsets.all(16),
    child: Text('Isi panel'),
  ),
);

IddsList(
  subheader: const IddsListSubheader('Layanan kependudukan'),
  dividers: true,
  children: [
    IddsListItem(
      leading: const Icon(TablerIcons.id),
      title: const Text('KTP Elektronik'),
      subtitle: const Text('Perekaman dan pencetakan'),
      trailing: const IddsIcon(IddsIcons.chevronRight),
      onTap: () => open('ktp'),
    ),
  ],
)

IddsChoiceGrid(
  columns: const [
    IddsChoiceGridItem(id: '1', label: 'Kurang'),
    IddsChoiceGridItem(id: '2', label: 'Baik'),
  ],
  rows: const [IddsChoiceGridItem(id: 'kecepatan', label: 'Kecepatan layanan')],
  selected: _answers, // Map<id baris, id kolom>
  onChanged: (Map<String, String> v) => setState(() => _answers = v),
)
''';
