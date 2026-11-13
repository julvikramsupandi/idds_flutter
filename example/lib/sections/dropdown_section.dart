import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

const List<IddsSelectOption<String>> _provinces = <IddsSelectOption<String>>[
  IddsSelectOption<String>(value: 'aceh', label: 'Aceh'),
  IddsSelectOption<String>(value: 'sumut', label: 'Sumatera Utara'),
  IddsSelectOption<String>(value: 'sumbar', label: 'Sumatera Barat'),
  IddsSelectOption<String>(value: 'riau', label: 'Riau'),
  IddsSelectOption<String>(value: 'jambi', label: 'Jambi'),
  IddsSelectOption<String>(value: 'dki', label: 'DKI Jakarta'),
  IddsSelectOption<String>(value: 'jabar', label: 'Jawa Barat'),
  IddsSelectOption<String>(value: 'jateng', label: 'Jawa Tengah'),
  IddsSelectOption<String>(value: 'diy', label: 'DI Yogyakarta'),
  IddsSelectOption<String>(value: 'jatim', label: 'Jawa Timur'),
  IddsSelectOption<String>(value: 'bali', label: 'Bali'),
  IddsSelectOption<String>(
      value: 'ntt', label: 'Nusa Tenggara Timur', enabled: false),
  IddsSelectOption<String>(value: 'papua', label: 'Papua'),
];

class SelectSection extends StatefulWidget {
  const SelectSection({super.key});

  @override
  State<SelectSection> createState() => _SelectSectionState();
}

class _SelectSectionState extends State<SelectSection> {
  String? _province;
  String? _status = 'aktif';
  Set<String> _services = <String>{'ktp'};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Select',
      subtitle:
          'Satu pilihan dan banyak pilihan (Multi Select), dengan pencarian. '
          'Tiga ukuran: sm 40px, md 44px (bawaan), lg 48px; di layar < 768px masing-masing 4px lebih pendek. '
          'Gunakan panah atas/bawah, Enter, dan Esc untuk navigasi keyboard.',
      usage:
          'IddsSelect untuk satu pilihan dan IddsMultiSelect untuk banyak pilihan; aktifkan searchable untuk daftar panjang (atau onSearch untuk pencarian di server). errorText menampilkan pesan validasi.',
      code: _selectCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s24,
          runSpacing: IddsSpacing.s24,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: IddsSelect<String>(
                label: const Text('Provinsi (md)'),
                required: true,
                searchable: true,
                options: _provinces,
                value: _province,
                errorText: _submitted && _province == null
                    ? 'Provinsi wajib dipilih'
                    : null,
                helperText: 'Ketik untuk mencari',
                onChanged: (String? v) => setState(() => _province = v),
              ),
            ),
            SizedBox(
              width: 220,
              child: IddsSelect<String>(
                label: const Text('Status (sm, indikator radio)'),
                size: IddsDropdownSize.sm,
                indicator: IddsSelectIndicator.radio,
                options: const <IddsSelectOption<String>>[
                  IddsSelectOption<String>(value: 'aktif', label: 'Aktif'),
                  IddsSelectOption<String>(value: 'cuti', label: 'Cuti'),
                  IddsSelectOption<String>(value: 'pensiun', label: 'Pensiun'),
                ],
                value: _status,
                onChanged: (String? v) => setState(() => _status = v),
              ),
            ),
            SizedBox(
              width: 300,
              child: IddsMultiSelect<String>(
                label: const Text('Layanan (lg)'),
                size: IddsDropdownSize.lg,
                showPreview: true,
                searchable: true,
                options: const <IddsSelectOption<String>>[
                  IddsSelectOption<String>(
                      value: 'ktp', label: 'KTP Elektronik'),
                  IddsSelectOption<String>(
                      value: 'kk', label: 'Kartu Keluarga'),
                  IddsSelectOption<String>(
                      value: 'akta', label: 'Akta Kelahiran'),
                  IddsSelectOption<String>(value: 'paspor', label: 'Paspor'),
                  IddsSelectOption<String>(value: 'sim', label: 'SIM'),
                  IddsSelectOption<String>(value: 'npwp', label: 'NPWP'),
                ],
                values: _services,
                onChanged: (Set<String> v) => setState(() => _services = v),
              ),
            ),
            const SizedBox(
              width: 220,
              child: IddsSelect<String>(
                label: Text('Nonaktif (md)'),
                options: _provinces,
                value: 'bali',
                onChanged: null,
              ),
            ),
          ],
        ),
        const SizedBox(height: IddsSpacing.s12),
        IddsButton(
          hierarchy: IddsButtonHierarchy.secondary,
          size: IddsButtonSize.sm,
          onPressed: () => setState(() => _submitted = !_submitted),
          child: Text(_submitted ? 'Sembunyikan error' : 'Tampilkan error'),
        ),
      ],
    );
  }
}

class ActionMenuSection extends StatelessWidget {
  const ActionMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Action Menu',
      subtitle: 'Daftar aksi dengan judul kelompok, pemisah, dan aksi berwarna '
          '(berhasil, peringatan, bahaya).',
      usage:
          'IddsActionMenu menampilkan tombol pemicu dan daftar IddsActionMenuItem. Label pemicu bawaan "Aksi"; isi triggerBuilder untuk pemicu sendiri (mis. tombol ikon). Item dengan onTap null tampil nonaktif.',
      code: _actionMenuCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s16,
          children: <Widget>[
            IddsActionMenu(
              items: <IddsActionMenuEntry>[
                const IddsActionMenuHeader('Dokumen'),
                IddsActionMenuItem(
                    label: 'Lihat detail',
                    onTap: () => showGallerySnack(context, 'Lihat detail')),
                IddsActionMenuItem(
                    label: 'Unduh',
                    onTap: () => showGallerySnack(context, 'Unduh')),
                const IddsActionMenuItem(
                    label: 'Bagikan (nonaktif)', onTap: null),
                const IddsActionMenuDivider(),
                IddsActionMenuItem(
                  label: 'Setujui',
                  type: IddsActionMenuItemType.success,
                  onTap: () => showGallerySnack(context, 'Disetujui'),
                ),
                IddsActionMenuItem(
                  label: 'Tandai bermasalah',
                  type: IddsActionMenuItemType.warning,
                  onTap: () => showGallerySnack(context, 'Ditandai'),
                ),
                IddsActionMenuItem(
                  label: 'Hapus',
                  type: IddsActionMenuItemType.danger,
                  onTap: () => showGallerySnack(context, 'Dihapus'),
                ),
              ],
            ),
            IddsActionMenu(
              label: 'Ekspor',
              placement: IddsPopoverPlacement.bottomEnd,
              width: IddsActionMenuWidth.lg,
              items: <IddsActionMenuEntry>[
                IddsActionMenuItem(
                    label: 'PDF',
                    onTap: () => showGallerySnack(context, 'PDF')),
                IddsActionMenuItem(
                    label: 'Excel (.xlsx)',
                    onTap: () => showGallerySnack(context, 'Excel')),
                IddsActionMenuItem(
                    label: 'CSV',
                    onTap: () => showGallerySnack(context, 'CSV')),
              ],
            ),
            const IddsActionMenu(
                label: 'Nonaktif',
                enabled: false,
                items: <IddsActionMenuEntry>[]),
          ],
        ),
      ],
    );
  }
}

class DropdownSection extends StatelessWidget {
  const DropdownSection({super.key});

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return GallerySection(
      title: 'Dropdown',
      subtitle: 'Panel melayang berisi konten bebas di bawah tombol pemicu.',
      usage:
          'IddsDropdown untuk panel berisi bebas: triggerBuilder membangun pemicu (dengan fungsi buka/tutup) dan contentBuilder membangun isi (dengan fungsi close). Untuk daftar pilihan pakai Select, untuk daftar aksi pakai Action Menu.',
      code: _dropdownCode,
      children: <Widget>[
        IddsDropdown(
          width: 260,
          triggerBuilder:
              (BuildContext context, bool open, VoidCallback? toggle) =>
                  IddsButton(
            hierarchy: IddsButtonHierarchy.secondary,
            onPressed: toggle,
            child: Text(open ? 'Tutup info' : 'Info layanan'),
          ),
          contentBuilder: (BuildContext context, VoidCallback close) => Padding(
            padding: const EdgeInsets.all(IddsSpacing.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Layanan tersedia Senin–Jumat, 08.00–16.00 WIB.',
                  style: IddsTheme.of(context).textStyle(
                    fontSize: IddsFontSize.sm,
                    lineHeight: IddsLineHeight.sm,
                    color: c.contentPrimary,
                  ),
                ),
                const SizedBox(height: IddsSpacing.s12),
                IddsButton(
                    size: IddsButtonSize.sm,
                    onPressed: close,
                    child: const Text('Mengerti')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

const String _selectCode = r'''
const List<IddsSelectOption<String>> provinces = [
  IddsSelectOption(value: 'gorontalo', label: 'Gorontalo'),
  IddsSelectOption(value: 'sulut', label: 'Sulawesi Utara'),
  IddsSelectOption(value: 'sulteng', label: 'Sulawesi Tengah'),
];

IddsSelect<String>(
  label: const Text('Provinsi'),
  required: true,
  searchable: true,
  options: provinces,
  value: _province,
  errorText: _submitted && _province == null ? 'Provinsi wajib dipilih' : null,
  onChanged: (String? v) => setState(() => _province = v),
)

IddsMultiSelect<String>(
  label: const Text('Provinsi tujuan'),
  options: provinces,
  values: _destinations, // Set<String>
  onChanged: (Set<String> v) => setState(() => _destinations = v),
)
''';

const String _actionMenuCode = r'''
IddsActionMenu(
  label: 'Ekspor',
  items: [
    IddsActionMenuItem(label: 'PDF', onTap: exportPdf),
    IddsActionMenuItem(label: 'Excel', onTap: exportExcel),
    const IddsActionMenuDivider(),
    IddsActionMenuItem(label: 'Hapus', type: IddsActionMenuItemType.danger, onTap: deleteItem),
  ],
)
''';

const String _dropdownCode = r'''
IddsDropdown(
  width: 260,
  triggerBuilder: (BuildContext context, bool open, VoidCallback? toggle) =>
      IddsButton(onPressed: toggle, child: Text(open ? 'Tutup' : 'Info layanan')),
  contentBuilder: (BuildContext context, VoidCallback close) => Padding(
    padding: const EdgeInsets.all(16),
    child: IddsButton(onPressed: close, child: const Text('Mengerti')),
  ),
)
''';
