import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class OverlaySection extends StatelessWidget {
  const OverlaySection({super.key});

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
          IddsButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
        child: const Text('Dokumen yang dihapus tidak bisa dikembalikan. Lanjutkan?'),
      ),
    );
    if (context.mounted && ok != null) showGallerySnack(context, ok ? 'Dokumen dihapus' : 'Dibatalkan');
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
          IddsButton(onPressed: () => Navigator.pop(context), child: const Text('Simpan')),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: IddsSpacing.s16,
          children: <Widget>[
            const IddsTextField(label: Text('Nama lengkap'), required: true, initialValue: 'Julvikram Supandi'),
            IddsSelect<String>(
              label: const Text('Unit kerja'),
              value: 'diskominfo',
              onChanged: (_) {},
              options: const <IddsSelectOption<String>>[
                IddsSelectOption<String>(value: 'diskominfo', label: 'Diskominfotik'),
                IddsSelectOption<String>(value: 'bapenda', label: 'Bapenda'),
              ],
            ),
            IddsDatePicker(label: const Text('Tanggal mulai'), value: DateTime(2026, 1, 2), onChanged: (_) {}),
            for (int i = 1; i <= 6; i++)
              Text('Paragraf $i: isi panjang agar bagian ini bisa digulir ketika modal lebih tinggi dari layar.'),
          ],
        ),
      ),
    );
  }

  void _drawer(BuildContext context, IddsDrawerPosition position) {
    showIddsDrawer<void>(
      context: context,
      position: position,
      builder: (BuildContext context) => IddsDrawer(
        title: Text('Filter data (${position.name})'),
        actions: <Widget>[
          IddsButton(
            hierarchy: IddsButtonHierarchy.secondary,
            onPressed: () => Navigator.pop(context),
            child: const Text('Reset'),
          ),
          IddsButton(onPressed: () => Navigator.pop(context), child: const Text('Terapkan')),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: IddsSpacing.s16,
          children: <Widget>[
            IddsDateRangePicker(label: const Text('Periode'), value: null, onChanged: (_) {}),
            IddsCheckbox(value: true, onChanged: (_) {}, label: 'Hanya data aktif'),
            IddsCheckbox(value: false, onChanged: (_) {}, label: 'Sertakan arsip'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Modal & Drawer',
      subtitle: 'Tutup dengan tombol X, Esc, atau menekan latar. Di layar ≤ 640px drawer kiri/kanan tampil dari bawah.',
      usage: 'Keduanya memakai Navigator (sudah ada di MaterialApp/CupertinoApp) dan mengembalikan Future berisi nilai dari Navigator.pop. Tema IDDS dari halaman pemanggil ikut terbawa.',
      code: _overlayCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          children: <Widget>[
            IddsButton(onPressed: () => _confirm(context), child: const Text('Modal konfirmasi')),
            for (final IddsModalSize size in <IddsModalSize>[IddsModalSize.sm, IddsModalSize.md, IddsModalSize.full])
              IddsButton(
                hierarchy: IddsButtonHierarchy.secondary,
                onPressed: () => _form(context, size),
                child: Text('Modal formulir ${size.name}'),
              ),
          ],
        ),
        const SizedBox(height: IddsSpacing.s12),
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
          ],
        ),
      ],
    );
  }
}

const String _overlayCode = r'''
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
''';
