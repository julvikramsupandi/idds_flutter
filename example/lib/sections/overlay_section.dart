import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class ModalSection extends StatelessWidget {
  const ModalSection({super.key});

  Future<void> _confirm(BuildContext context) async {
    final bool? ok = await showIddsModal<bool>(
      context: context,
      builder: (BuildContext context) => IddsModal(
        title: const Text('Hapus dokumen?'),
        actions: <Widget>[
          IddsButton(
            hierarchy: IddsButtonHierarchy.secondary,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          IddsButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus')),
        ],
        child: const Text(
            'Dokumen yang dihapus tidak bisa dikembalikan. Lanjutkan?'),
      ),
    );
    if (context.mounted && ok != null) {
      showGallerySnack(context, ok ? 'Dokumen dihapus' : 'Dibatalkan');
    }
  }

  void _form(BuildContext context, IddsModalSize size) {
    showIddsModal<void>(
      context: context,
      builder: (BuildContext context) => IddsModal(
        size: size,
        title: Text('Ubah profil (${size.name})'),
        actions: <Widget>[
          IddsButton(
            hierarchy: IddsButtonHierarchy.secondary,
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          IddsButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Simpan')),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: IddsSpacing.s16,
          children: <Widget>[
            const IddsTextField(
                label: Text('Nama lengkap'),
                required: true,
                initialValue: 'Julvikram Supandi'),
            IddsSelect<String>(
              label: const Text('Unit kerja'),
              value: 'diskominfo',
              onChanged: (_) {},
              options: const <IddsSelectOption<String>>[
                IddsSelectOption<String>(
                    value: 'diskominfo', label: 'Diskominfotik'),
                IddsSelectOption<String>(value: 'bapenda', label: 'Bapenda'),
              ],
            ),
            IddsDatePicker(
                label: const Text('Tanggal mulai'),
                value: DateTime(2026, 1, 2),
                onChanged: (_) {}),
            for (int i = 1; i <= 6; i++)
              Text(
                  'Paragraf $i: isi panjang agar bagian ini bisa digulir ketika modal lebih tinggi dari layar.'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Modal',
      subtitle:
          'Konfirmasi dan formulir dalam beberapa ukuran. Tutup dengan tombol X, Esc, atau menekan latar.',
      usage:
          'showIddsModal memakai Navigator (sudah ada di MaterialApp/CupertinoApp) dan mengembalikan Future berisi nilai dari Navigator.pop. Isi yang lebih tinggi dari layar bisa digulir; tema IDDS dari halaman pemanggil ikut terbawa.',
      code: _modalCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          children: <Widget>[
            IddsButton(
                onPressed: () => _confirm(context),
                child: const Text('Modal konfirmasi')),
            for (final IddsModalSize size in <IddsModalSize>[
              IddsModalSize.sm,
              IddsModalSize.md,
              IddsModalSize.full
            ])
              IddsButton(
                hierarchy: IddsButtonHierarchy.secondary,
                onPressed: () => _form(context, size),
                child: Text('Modal formulir ${size.name}'),
              ),
          ],
        ),
      ],
    );
  }
}

class DrawerSection extends StatelessWidget {
  const DrawerSection({super.key});

  void _drawer(
    BuildContext context,
    IddsDrawerPosition position, {
    bool bottomOnSmallScreens = true,
  }) {
    showIddsDrawer<void>(
      context: context,
      position: position,
      bottomOnSmallScreens: bottomOnSmallScreens,
      builder: (BuildContext context) => IddsDrawer(
        title: Text('Filter data (${position.name})'),
        actions: <Widget>[
          IddsButton(
            hierarchy: IddsButtonHierarchy.secondary,
            onPressed: () => Navigator.pop(context),
            child: const Text('Reset'),
          ),
          IddsButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Terapkan')),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: IddsSpacing.s16,
          children: <Widget>[
            IddsDateRangePicker(
                label: const Text('Periode'), value: null, onChanged: (_) {}),
            IddsCheckbox(
                value: true, onChanged: (_) {}, label: 'Hanya data aktif'),
            IddsCheckbox(
                value: false, onChanged: (_) {}, label: 'Sertakan arsip'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Drawer',
      subtitle:
          'Panel dari tepi layar. Di layar ≤ 640px drawer kiri/kanan tampil dari bawah seperti IDDS web, '
          'kecuali bottomOnSmallScreens: false (pola navigation drawer di aplikasi mobile).',
      usage:
          'showIddsDrawer mengembalikan Future berisi nilai dari Navigator.pop. Untuk menu navigasi aplikasi mobile, isi bottomOnSmallScreens: false agar drawer tetap muncul dari samping, seperti menu galeri ini di HP.',
      code: _drawerCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          children: <Widget>[
            for (final IddsDrawerPosition p in IddsDrawerPosition.values)
              IddsButton(
                hierarchy: IddsButtonHierarchy.secondary,
                onPressed: () => _drawer(context, p),
                child: Text('Drawer ${p.name}'),
              ),
            IddsButton(
              hierarchy: IddsButtonHierarchy.tertiary,
              onPressed: () => _drawer(
                context,
                IddsDrawerPosition.left,
                bottomOnSmallScreens: false,
              ),
              child: const Text('Kiri, tetap samping'),
            ),
          ],
        ),
      ],
    );
  }
}

const String _modalCode = r'''
final bool? confirmed = await showIddsModal<bool>(
  context: context,
  builder: (BuildContext context) => IddsModal(
    size: IddsModalSize.sm, // sm, md, lg, xl, full
    title: const Text('Hapus dokumen?'),
    actions: [
      IddsButton(
        hierarchy: IddsButtonHierarchy.secondary,
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Batal'),
      ),
      IddsButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
    ],
    child: const Text('Dokumen yang dihapus tidak bisa dikembalikan.'),
  ),
);
''';

const String _drawerCode = r'''
showIddsDrawer<void>(
  context: context,
  position: IddsDrawerPosition.right, // right, left, top, bottom
  builder: (BuildContext context) => IddsDrawer(
    title: const Text('Filter data'),
    actions: [
      IddsButton(onPressed: () => Navigator.pop(context), child: const Text('Terapkan')),
    ],
    child: const FilterForm(),
  ),
);

// Menu navigasi aplikasi mobile: tetap dari samping di layar kecil.
showIddsDrawer<void>(
  context: context,
  position: IddsDrawerPosition.left,
  width: 300,
  bottomOnSmallScreens: false,
  builder: (BuildContext context) => const IddsDrawer(
    title: Text('Menu'),
    child: AppMenu(),
  ),
);
''';
