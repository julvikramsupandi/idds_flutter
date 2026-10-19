import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Button',
      subtitle: 'Ukuran mengecil satu tingkat saat lebar layar < 640px. Tekan Tab untuk melihat cincin fokus.',
      usage: 'Gunakan satu tombol primary per area untuk aksi utama; secondary dan tertiary untuk aksi pendamping, link untuk navigasi. Ikon diisi lewat prefixIcon/suffixIcon dengan widget apa saja. onPressed: null membuat tombol nonaktif.',
      code: _buttonCode,
      children: <Widget>[
        for (final IddsButtonHierarchy h in IddsButtonHierarchy.values) ...<Widget>[
          GalleryCaption(h.name),
          const SizedBox(height: IddsSpacing.s8),
          Wrap(
            spacing: IddsSpacing.s12,
            runSpacing: IddsSpacing.s12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final IddsButtonSize s in IddsButtonSize.values)
                IddsButton(
                  hierarchy: h,
                  size: s,
                  onPressed: () => showGallerySnack(context, 'Ditekan: ${h.name} ${s.name}'),
                  child: Text('Button ${s.name}'),
                ),
              IddsButton(
                hierarchy: h,
                onPressed: () => showGallerySnack(context, 'Ditekan: ${h.name} + ikon'),
                prefixIcon: const Icon(TablerIcons.plus),
                suffixIcon: const Icon(TablerIcons.arrow_right),
                child: const Text('Dengan ikon'),
              ),
              IddsButton(hierarchy: h, onPressed: null, child: const Text('Nonaktif')),
            ],
          ),
          const SizedBox(height: IddsSpacing.s24),
        ],
      ],
    );
  }
}

const String _buttonCode = r'''
IddsButton(
  onPressed: () => save(),
  child: const Text('Simpan'),
)

IddsButton(
  hierarchy: IddsButtonHierarchy.secondary, // primary, secondary, tertiary, link
  size: IddsButtonSize.sm, // xl2, xl, lg, md (bawaan), sm
  prefixIcon: const Icon(TablerIcons.plus),
  onPressed: () {},
  child: const Text('Tambah data'),
)

// Nonaktif
const IddsButton(onPressed: null, child: Text('Nonaktif'))
''';
