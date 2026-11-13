import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class MonthYearPickerSection extends StatefulWidget {
  const MonthYearPickerSection({super.key});

  @override
  State<MonthYearPickerSection> createState() => _MonthYearPickerSectionState();
}

class _MonthYearPickerSectionState extends State<MonthYearPickerSection> {
  int? _month = DateTime.now().month;
  int? _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Month/Year Picker',
      subtitle: 'Memilih bulan atau tahun saja, tanpa tanggal.',
      usage:
          'Cocok untuk periode laporan atau masa berlaku. Nilai berupa angka: bulan 1–12 dan tahun empat digit. clearable menampilkan tombol hapus.',
      code: _monthYearCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s16,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: IddsMonthPicker(
                value: _month,
                clearable: true,
                onChanged: (int? m) => setState(() => _month = m),
              ),
            ),
            SizedBox(
              width: 160,
              child: IddsYearPicker(
                value: _year,
                onChanged: (int? y) => setState(() => _year = y),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ThemeToggleSection extends StatefulWidget {
  const ThemeToggleSection({super.key});

  @override
  State<ThemeToggleSection> createState() => _ThemeToggleSectionState();
}

class _ThemeToggleSectionState extends State<ThemeToggleSection> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Theme Toggle',
      subtitle: 'Tombol pengganti mode terang/gelap, dengan atau tanpa label.',
      usage:
          'IddsThemeToggle hanya melaporkan nilai: bangun ulang IddsThemeData dengan brightness yang sesuai, seperti tombol di bilah atas galeri ini.',
      code: _themeToggleCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            IddsThemeToggle(
              dark: _dark,
              showLabel: true,
              onChanged: (bool v) => setState(() => _dark = v),
            ),
            IddsThemeToggle(
              dark: _dark,
              size: IddsThemeToggleSize.sm,
              onChanged: (bool v) => setState(() => _dark = v),
            ),
          ],
        ),
        const SizedBox(height: IddsSpacing.s8),
        const GalleryCaption(
          'Contoh ini hanya menyimpan nilai; pakai tombol di bilah atas untuk mengganti tema galeri.',
        ),
      ],
    );
  }
}

class BottomSheetSection extends StatelessWidget {
  const BottomSheetSection({super.key});

  void _openSheet(BuildContext context, {required bool locked}) {
    showIddsBottomSheet<void>(
      context: context,
      locked: locked,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
          IddsSpacing.s16,
          0,
          IddsSpacing.s16,
          IddsSpacing.s16 + MediaQuery.paddingOf(context).bottom,
        ),
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
            Text(
              locked
                  ? 'Panel ini hanya bisa ditutup dengan tombol di bawah.'
                  : 'Tarik ke bawah, tekan latar, atau Esc untuk menutup.',
            ),
            IddsButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Bottom Sheet',
      subtitle: 'Panel dari bawah layar yang bisa ditarik untuk menutup.',
      usage:
          'showIddsBottomSheet menampilkan panel dan mengembalikan Future berisi nilai dari Navigator.pop. locked: true mencegah panel ditutup dengan menarik, menekan latar, atau Esc. Tinggi panel mengikuti isi, maksimal 90% layar (maxHeightFactor).',
      code: _bottomSheetCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          children: <Widget>[
            IddsButton(
              onPressed: () => _openSheet(context, locked: false),
              child: const Text('Buka bottom sheet'),
            ),
            IddsButton(
              hierarchy: IddsButtonHierarchy.secondary,
              onPressed: () => _openSheet(context, locked: true),
              child: const Text('Bottom sheet terkunci'),
            ),
          ],
        ),
      ],
    );
  }
}

class ListSection extends StatefulWidget {
  const ListSection({super.key});

  @override
  State<ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends State<ListSection> {
  String _service = 'ktp';

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'List',
      subtitle: 'Daftar dengan subjudul, ikon, keterangan, item terpilih, '
          'dan garis pemisah.',
      usage:
          'IddsList membungkus IddsListItem dan bisa diberi subheader serta dividers. Isi onTap agar item bisa ditekan; selected menandai item yang sedang aktif.',
      code: _listCode,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: IddsCardPlain(
            padding: EdgeInsets.zero,
            child: IddsList(
              subheader: const IddsListSubheader('Layanan kependudukan'),
              dividers: true,
              children: <Widget>[
                for (final (String id, String title, String sub, IconData icon)
                    in <(String, String, String, IconData)>[
                  (
                    'ktp',
                    'KTP Elektronik',
                    'Perekaman dan pencetakan',
                    TablerIcons.id,
                  ),
                  (
                    'kk',
                    'Kartu Keluarga',
                    'Perubahan data anggota keluarga',
                    TablerIcons.users_group,
                  ),
                  (
                    'akta',
                    'Akta Kelahiran',
                    'Pencatatan kelahiran',
                    TablerIcons.baby_carriage,
                  ),
                ])
                  IddsListItem(
                    leading: Icon(icon),
                    title: Text(title),
                    subtitle: Text(sub),
                    selected: _service == id,
                    trailing: const IddsIcon(IddsIcons.chevronRight),
                    onTap: () => setState(() => _service = id),
                  ),
                const IddsListItem(
                  title: Text('Surat pindah (segera)'),
                  enabled: false,
                  dense: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChoiceGridSection extends StatefulWidget {
  const ChoiceGridSection({super.key});

  @override
  State<ChoiceGridSection> createState() => _ChoiceGridSectionState();
}

class _ChoiceGridSectionState extends State<ChoiceGridSection> {
  Map<String, String> _survey = <String, String>{};

  static const List<IddsChoiceGridItem> _scale = <IddsChoiceGridItem>[
    IddsChoiceGridItem(id: '1', label: 'Sangat kurang'),
    IddsChoiceGridItem(id: '2', label: 'Kurang'),
    IddsChoiceGridItem(id: '3', label: 'Cukup'),
    IddsChoiceGridItem(id: '4', label: 'Baik'),
    IddsChoiceGridItem(id: '5', label: 'Sangat baik'),
  ];

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Multiple Choice Grid',
      subtitle: 'Satu pilihan per baris, misalnya untuk survei kepuasan.',
      usage:
          'columns berisi skala jawaban dan rows berisi pertanyaan. Jawaban disimpan sebagai Map<id baris, id kolom>.',
      code: _choiceGridCode,
      children: <Widget>[
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

const String _monthYearCode = r'''
IddsMonthPicker(
  value: _month, // 1–12
  clearable: true,
  onChanged: (int? m) => setState(() => _month = m),
)

IddsYearPicker(
  value: _year,
  onChanged: (int? y) => setState(() => _year = y),
)
''';

const String _themeToggleCode = r'''
IddsThemeToggle(
  dark: _brightness == Brightness.dark,
  showLabel: true,
  onChanged: (bool dark) => setState(
    () => _brightness = dark ? Brightness.dark : Brightness.light,
  ),
)

// Lalu bangun ulang tema:
IddsThemeData(brand: IddsBrand.inagov, brightness: _brightness)
''';

const String _bottomSheetCode = r'''
final String? choice = await showIddsBottomSheet<String>(
  context: context,
  // locked: true, // tidak bisa ditutup dengan menarik/menekan latar
  builder: (BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: IddsButton(
      onPressed: () => Navigator.pop(context, 'whatsapp'),
      child: const Text('Bagikan ke WhatsApp'),
    ),
  ),
);
''';

const String _listCode = r'''
IddsList(
  subheader: const IddsListSubheader('Layanan kependudukan'),
  dividers: true,
  children: [
    IddsListItem(
      leading: const Icon(TablerIcons.id),
      title: const Text('KTP Elektronik'),
      subtitle: const Text('Perekaman dan pencetakan'),
      trailing: const IddsIcon(IddsIcons.chevronRight),
      selected: _service == 'ktp',
      onTap: () => open('ktp'),
    ),
  ],
)
''';

const String _choiceGridCode = r'''
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
