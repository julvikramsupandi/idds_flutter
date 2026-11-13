import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class ToastSection extends StatefulWidget {
  const ToastSection({super.key});

  @override
  State<ToastSection> createState() => _ToastSectionState();
}

class _ToastSectionState extends State<ToastSection> {
  IddsToastPosition _position = IddsToastPosition.topRight;
  IddsToastStyle _style = IddsToastStyle.solid;

  void _toast(IddsToastState state) {
    final (String title, String description) = switch (state) {
      IddsToastState.normal => (
          'Sinkronisasi berjalan',
          'Data akan diperbarui dalam beberapa menit.'
        ),
      IddsToastState.destructive => (
          'Gagal menyimpan',
          'Periksa koneksi internet Anda lalu coba lagi.'
        ),
      IddsToastState.positive => (
          'Data berhasil disimpan',
          'Perubahan sudah tersimpan di server.'
        ),
    };
    showIddsToast(
      context: context,
      title: Text(title),
      description: Text(description),
      state: state,
      style: _style,
      position: _position,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Toast',
      subtitle:
          'Tertutup otomatis setelah 5 detik, hanya satu yang tampil (toast baru menggantikan yang lama), '
          'dan bisa digeser menjauhi tepi layar untuk menutup.',
      usage:
          'showIddsToast menampilkan notifikasi sementara di atas halaman dan mengembalikan controller untuk menutupnya. Bawaan replaceExisting: true (aturan IDDS satu toast); isi false untuk menumpuk. Bisa dipanggil dengan context Navigator root (mis. dari navigatorKey) atau isi overlay.',
      code: _toastCode,
      children: <Widget>[
        const GalleryCaption('Posisi dan gaya toast'),
        const SizedBox(height: IddsSpacing.s8),
        SizedBox(
          width: 240,
          child: IddsSelect<IddsToastPosition>(
            size: IddsDropdownSize.sm,
            value: _position,
            onChanged: (IddsToastPosition? p) =>
                setState(() => _position = p ?? _position),
            options: <IddsSelectOption<IddsToastPosition>>[
              for (final IddsToastPosition p in IddsToastPosition.values)
                IddsSelectOption<IddsToastPosition>(value: p, label: p.name),
            ],
          ),
        ),
        const SizedBox(height: IddsSpacing.s8),
        IddsChipGroup<IddsToastStyle>(
          size: IddsChipSize.small,
          selected: <IddsToastStyle>{_style},
          onChanged: (Set<IddsToastStyle> v) =>
              setState(() => _style = v.isEmpty ? _style : v.first),
          options: const <IddsChipOption<IddsToastStyle>>[
            IddsChipOption<IddsToastStyle>(
                value: IddsToastStyle.solid, label: 'Solid'),
            IddsChipOption<IddsToastStyle>(
                value: IddsToastStyle.outline, label: 'Outline'),
          ],
        ),
        const SizedBox(height: IddsSpacing.s12),
        Wrap(
          spacing: IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          children: <Widget>[
            IddsButton(
                onPressed: () => _toast(IddsToastState.normal),
                child: const Text('Toast info')),
            IddsButton(
              hierarchy: IddsButtonHierarchy.secondary,
              onPressed: () => _toast(IddsToastState.positive),
              child: const Text('Toast berhasil'),
            ),
            IddsButton(
              hierarchy: IddsButtonHierarchy.secondary,
              onPressed: () => _toast(IddsToastState.destructive),
              child: const Text('Toast gagal'),
            ),
            IddsButton(
              hierarchy: IddsButtonHierarchy.tertiary,
              onPressed: () => dismissAllIddsToasts(context),
              child: const Text('Tutup semua'),
            ),
          ],
        ),
      ],
    );
  }
}

class TooltipSection extends StatelessWidget {
  const TooltipSection({super.key});

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return GallerySection(
      title: 'Tooltip',
      subtitle:
          'Muncul saat disorot mouse, difokuskan dengan Tab, atau ditekan lama di layar sentuh.',
      usage:
          'IddsTooltip membungkus widget apa saja. Isi message untuk tooltip teks singkat, atau title/description untuk tooltip kartu (onboarding) dengan tombol lanjut dan tutup.',
      code: _tooltipCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s24,
          runSpacing: IddsSpacing.s24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final IddsTooltipPlacement p in <IddsTooltipPlacement>[
              IddsTooltipPlacement.top,
              IddsTooltipPlacement.bottomStart,
              IddsTooltipPlacement.left,
              IddsTooltipPlacement.right,
            ])
              IddsTooltip(
                message: 'Tooltip ${p.name}',
                placement: p,
                child: IddsButton(
                  hierarchy: IddsButtonHierarchy.secondary,
                  size: IddsButtonSize.sm,
                  onPressed: () {},
                  child: Text(p.name),
                ),
              ),
            IddsTooltip(
              variant: IddsTooltipVariant.light,
              placement: IddsTooltipPlacement.bottom,
              title: 'Ekspor laporan',
              description:
                  'Laporan bulanan kini bisa diekspor ke PDF dan Excel.',
              onClose: () {},
              onNext: () =>
                  showGallerySnack(context, 'Lanjut ke langkah berikutnya'),
              child: const IddsBadge(child: Text('Kartu terang')),
            ),
            IddsTooltip(
              variant: IddsTooltipVariant.dark,
              placement: IddsTooltipPlacement.bottom,
              title: 'Mode gelap',
              description: 'Tooltip kartu dengan latar gelap.',
              onClose: () {},
              child: const IddsBadge(child: Text('Kartu gelap')),
            ),
            IddsTooltip(
              variant: IddsTooltipVariant.media,
              placement: IddsTooltipPlacement.bottom,
              title: 'Dashboard baru',
              description: 'Lihat ringkasan layanan dalam satu halaman.',
              image: Container(
                color: theme.colors.primary.shade100,
                alignment: Alignment.center,
                child: IddsIcon(IddsIcons.box,
                    size: 48, color: theme.colors.primary.shade600),
              ),
              onNext: () {},
              child: const IddsBadge(child: Text('Kartu media')),
            ),
          ],
        ),
      ],
    );
  }
}

const String _toastCode = r'''
showIddsToast(
  context: context,
  title: const Text('Data berhasil disimpan'),
  description: const Text('Perubahan sudah tersimpan di server.'),
  state: IddsToastState.positive, // normal, destructive, positive
  style: IddsToastStyle.solid, // solid atau outline
  position: IddsToastPosition.topRight,
  // replaceExisting: false, // menumpuk; bawaan true (satu toast)
);

// Tanpa BuildContext halaman (mis. dari helper), pakai navigator root.
showIddsToast(
  context: navigatorKey.currentContext!,
  title: const Text('Tautan disalin'),
);
''';

const String _tooltipCode = r'''
IddsTooltip(
  message: 'Unduh dokumen',
  placement: IddsTooltipPlacement.top,
  child: IddsButton(onPressed: download, child: const Text('Unduh')),
)

IddsTooltip(
  variant: IddsTooltipVariant.light, // basic, light, dark, media
  title: 'Ekspor laporan',
  description: 'Laporan bulanan kini bisa diekspor ke PDF dan Excel.',
  onNext: () => nextStep(),
  onClose: () => closeGuide(),
  child: const IddsBadge(child: Text('Baru')),
)
''';
