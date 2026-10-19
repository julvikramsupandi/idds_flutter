import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {
  Set<String> _range = <String>{'30'};
  Set<String> _topics = <String>{'pendidikan'};
  String _period = 'bulanan';
  String _tab = 'profil';
  int _step = 1;
  int _page = 1;
  int _pageSize = 10;

  static const List<IddsTabItem<String>> _tabs = <IddsTabItem<String>>[
    IddsTabItem<String>(value: 'profil', label: Text('Profil')),
    IddsTabItem<String>(value: 'dokumen', label: Text('Dokumen')),
    IddsTabItem<String>(value: 'riwayat', label: Text('Riwayat')),
    IddsTabItem<String>(value: 'arsip', label: Text('Arsip'), enabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GallerySection(
          title: 'Chip',
          usage: 'IddsChipGroup untuk memilih satu (bawaan) atau banyak nilai (multiple: true). customization menambahkan chip "Kustomisasi" berisi isian; IddsChipCustomization.integer dan .text tersedia sebagai bentuk siap pakai.',
          code: _chipCode,
          children: <Widget>[
            const GalleryCaption('Satu pilihan (outline) dengan Kustomisasi'),
            const SizedBox(height: IddsSpacing.s8),
            IddsChipGroup<String>(
              selected: _range,
              onChanged: (Set<String> v) => setState(() => _range = v),
              customization: IddsChipCustomization<String>(
                parse: (String text) => int.tryParse(text)?.toString(),
                format: (String value) => value,
                placeholder: 'Jumlah hari',
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                suffix: 'hari',
              ),
              options: const <IddsChipOption<String>>[
                IddsChipOption<String>(value: '7', label: '7 hari'),
                IddsChipOption<String>(value: '30', label: '30 hari'),
                IddsChipOption<String>(value: '90', label: '90 hari'),
                IddsChipOption<String>(value: '365', label: '1 tahun', enabled: false),
              ],
            ),
            const SizedBox(height: IddsSpacing.s16),
            const GalleryCaption('Banyak pilihan (filled, small)'),
            const SizedBox(height: IddsSpacing.s8),
            IddsChipGroup<String>(
              multiple: true,
              variant: IddsChipVariant.filled,
              size: IddsChipSize.small,
              selected: _topics,
              onChanged: (Set<String> v) => setState(() => _topics = v),
              options: const <IddsChipOption<String>>[
                IddsChipOption<String>(value: 'pendidikan', label: 'Pendidikan'),
                IddsChipOption<String>(value: 'kesehatan', label: 'Kesehatan'),
                IddsChipOption<String>(value: 'pajak', label: 'Pajak'),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'Button Group',
          usage: 'Sekumpulan tombol yang saling terhubung untuk memilih satu nilai, misalnya periode laporan.',
          code: _buttonGroupCode,
          children: <Widget>[
            IddsButtonGroup<String>(
              value: _period,
              onChanged: (String v) => setState(() => _period = v),
              options: const <IddsButtonGroupOption<String>>[
                IddsButtonGroupOption<String>(value: 'harian', label: Text('Harian')),
                IddsButtonGroupOption<String>(value: 'mingguan', label: Text('Mingguan')),
                IddsButtonGroupOption<String>(value: 'bulanan', label: Text('Bulanan')),
                IddsButtonGroupOption<String>(value: 'tahunan', label: Text('Tahunan'), enabled: false),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'Breadcrumb',
          usage: 'Item terakhir adalah halaman saat ini (tanpa onTap). maxLength memotong label yang terlalu panjang.',
          code: _breadcrumbCode,
          children: <Widget>[
            IddsBreadcrumb(
              maxLength: 24,
              items: <IddsBreadcrumbItem>[
                IddsBreadcrumbItem(
                  label: 'Beranda',
                  icon: const Icon(TablerIcons.home),
                  onTap: () => showGallerySnack(context, 'Ke Beranda'),
                ),
                IddsBreadcrumbItem(label: 'Layanan', onTap: () => showGallerySnack(context, 'Ke Layanan')),
                const IddsBreadcrumbItem(label: 'Arsip', enabled: false),
                const IddsBreadcrumbItem(label: 'Sistem Informasi Beasiswa Provinsi Gorontalo'),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'Tab Menu',
          usage: 'IddsTabMenu hanya menampilkan tab dan melaporkan pilihan; tampilkan isi tab sendiri berdasarkan nilai terpilih (misalnya dengan switch atau IndexedStack).',
          code: _tabCode,
          children: <Widget>[
            for (final IddsTabVariant v in IddsTabVariant.values) ...<Widget>[
              GalleryCaption(v.name),
              const SizedBox(height: IddsSpacing.s8),
              IddsTabMenu<String>(
                items: _tabs,
                value: _tab,
                variant: v,
                onChanged: (String t) => setState(() => _tab = t),
              ),
              const SizedBox(height: IddsSpacing.s16),
            ],
            const GalleryCaption('outline + useBrandColor + fullWidth'),
            const SizedBox(height: IddsSpacing.s8),
            IddsTabMenu<String>(
              items: _tabs,
              value: _tab,
              fullWidth: true,
              useBrandColor: true,
              onChanged: (String t) => setState(() => _tab = t),
            ),
            const SizedBox(height: IddsSpacing.s16),
            const GalleryCaption('vertikal'),
            const SizedBox(height: IddsSpacing.s8),
            Wrap(
              spacing: IddsSpacing.s24,
              runSpacing: IddsSpacing.s16,
              children: <Widget>[
                for (final IddsTabVariant v in IddsTabVariant.values)
                  IddsTabMenu<String>(
                    items: _tabs,
                    value: _tab,
                    variant: v,
                    direction: Axis.vertical,
                    width: 180,
                    onChanged: (String t) => setState(() => _tab = t),
                  ),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'Stepper',
          subtitle: 'Tekan langkah untuk berpindah. Langkah 3 ditandai bermasalah.',
          usage: 'currentStep dimulai dari 0. Langkah sebelum currentStep ditandai selesai; errorSteps menandai langkah bermasalah. Isi onStepTap bila pengguna boleh melompat antarlangkah.',
          code: _stepperCode,
          children: <Widget>[
            IddsStepper(
              currentStep: _step,
              errorSteps: const <int>{2},
              onStepTap: (int i) => setState(() => _step = i),
              steps: const <IddsStep>[
                IddsStep(label: 'Data diri'),
                IddsStep(label: 'Pendidikan'),
                IddsStep(label: 'Dokumen'),
                IddsStep(label: 'Konfirmasi'),
              ],
            ),
            const SizedBox(height: IddsSpacing.s16),
            IddsStepper(
              currentStep: _step,
              direction: Axis.vertical,
              onStepTap: (int i) => setState(() => _step = i),
              steps: const <IddsStep>[
                IddsStep(label: 'Data diri'),
                IddsStep(label: 'Pendidikan'),
                IddsStep(label: 'Dokumen'),
                IddsStep(label: 'Konfirmasi'),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'Pagination',
          subtitle: '"Halaman … dari …" tampil di layar ≥ 580px. Ukuran membesar di ≥ 1024px dan ≥ 1280px. Pilihan jumlah baris muncul bila onPageSizeChanged diisi.',
          usage: 'Halaman dimulai dari 1. Pilihan jumlah baris per halaman muncul bila pageSize dan onPageSizeChanged diisi.',
          code: _paginationCode,
          children: <Widget>[
            IddsPagination(
              currentPage: _page,
              totalPages: (120 / _pageSize).ceil(),
              onPageChanged: (int p) => setState(() => _page = p),
              pageSize: _pageSize,
              onPageSizeChanged: (int s) => setState(() {
                _pageSize = s;
                _page = 1;
              }),
            ),
            const SizedBox(height: IddsSpacing.s12),
            const IddsPagination(currentPage: 3, totalPages: 12, onPageChanged: null),
          ],
        ),
      ],
    );
  }
}

const String _chipCode = r'''
IddsChipGroup<int>(
  selected: _range, // Set<int>
  options: const [
    IddsChipOption(value: 7, label: '7 hari'),
    IddsChipOption(value: 30, label: '30 hari'),
    IddsChipOption(value: 90, label: '90 hari'),
  ],
  customization: IddsChipCustomization.integer(suffix: 'hari'),
  onChanged: (Set<int> v) => setState(() => _range = v),
)

IddsChipGroup<String>(
  multiple: true,
  variant: IddsChipVariant.filled, // outline (bawaan) atau filled
  size: IddsChipSize.small,
  selected: _topics,
  options: const [
    IddsChipOption(value: 'pendidikan', label: 'Pendidikan'),
    IddsChipOption(value: 'kesehatan', label: 'Kesehatan'),
  ],
  onChanged: (Set<String> v) => setState(() => _topics = v),
)
''';

const String _buttonGroupCode = r'''
IddsButtonGroup<String>(
  value: _period,
  options: const [
    IddsButtonGroupOption(value: 'harian', label: Text('Harian')),
    IddsButtonGroupOption(value: 'mingguan', label: Text('Mingguan')),
    IddsButtonGroupOption(value: 'bulanan', label: Text('Bulanan')),
  ],
  onChanged: (String v) => setState(() => _period = v),
)
''';

const String _breadcrumbCode = r'''
IddsBreadcrumb(
  maxLength: 24,
  items: [
    IddsBreadcrumbItem(label: 'Beranda', icon: const Icon(TablerIcons.home), onTap: goHome),
    IddsBreadcrumbItem(label: 'Layanan', onTap: goServices),
    const IddsBreadcrumbItem(label: 'Sistem Informasi Beasiswa'),
  ],
)
''';

const String _tabCode = r'''
IddsTabMenu<String>(
  value: _tab,
  variant: IddsTabVariant.outline, // outline, buttonBrand, buttonWhite
  items: const [
    IddsTabItem(value: 'profil', label: Text('Profil')),
    IddsTabItem(value: 'dokumen', label: Text('Dokumen')),
    IddsTabItem(value: 'arsip', label: Text('Arsip'), enabled: false),
  ],
  onChanged: (String v) => setState(() => _tab = v),
)

// Vertikal
IddsTabMenu<String>(
  direction: Axis.vertical,
  width: 200,
  value: _tab,
  items: tabs,
  onChanged: (String v) => setState(() => _tab = v),
)
''';

const String _stepperCode = r'''
IddsStepper(
  currentStep: _step,
  errorSteps: const {2},
  direction: Axis.horizontal, // atau Axis.vertical
  onStepTap: (int i) => setState(() => _step = i),
  steps: const [
    IddsStep(label: 'Data diri'),
    IddsStep(label: 'Pendidikan'),
    IddsStep(label: 'Dokumen'),
    IddsStep(label: 'Konfirmasi'),
  ],
)
''';

const String _paginationCode = r'''
IddsPagination(
  currentPage: _page,
  totalPages: (totalItems / _pageSize).ceil(),
  onPageChanged: (int p) => setState(() => _page = p),
  pageSize: _pageSize,
  onPageSizeChanged: (int s) => setState(() {
    _pageSize = s;
    _page = 1;
  }),
)
''';
