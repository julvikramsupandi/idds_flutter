import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class ContentSection extends StatefulWidget {
  const ContentSection({super.key});

  @override
  State<ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends State<ContentSection> {
  double _progress = 0.4;

  Widget _media(BuildContext context, IconData icon) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Container(
      color: c.primary.shade200,
      alignment: Alignment.center,
      child: Icon(icon, size: 48, color: c.primary.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GallerySection(
          title: 'Accordion',
          subtitle: 'Grup (satu terbuka), accordion tunggal, dan gaya kartu. Panah atas/bawah berpindah antar judul.',
          usage: 'IddsAccordionGroup hanya membuka satu panel dalam satu waktu (multipleOpen: true untuk lebih). Isi bisa widget apa saja. IddsAccordionCard untuk satu panel bergaya kartu.',
          code: _accordionCode,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const IddsAccordionGroup(
                    initiallyOpen: <int>{0},
                    items: <IddsAccordionItem>[
                      IddsAccordionItem(
                        title: Text('Siapa yang bisa mendaftar?'),
                        child: Text('Warga Provinsi Gorontalo berusia 17–35 tahun yang sedang menempuh pendidikan.'),
                      ),
                      IddsAccordionItem(
                        title: Text('Dokumen apa saja yang dibutuhkan?'),
                        child: Text('KTP, Kartu Keluarga, transkrip nilai, dan surat keterangan aktif kuliah.'),
                      ),
                      IddsAccordionItem(
                        title: Text('Kapan pengumuman hasil seleksi?'),
                        child: Text('Pengumuman dikirim lewat email paling lambat 30 hari setelah pendaftaran ditutup.'),
                      ),
                      IddsAccordionItem(title: Text('Pertanyaan nonaktif'), child: Text('-'), enabled: false),
                    ],
                  ),
                  const SizedBox(height: IddsSpacing.s24),
                  const IddsAccordionCard(
                    title: Text('Rincian biaya layanan'),
                    child: Text('Layanan ini tidak dipungut biaya.'),
                  ),
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'Card',
          subtitle: 'Basic, horizontal (media pindah ke atas di layar < 640px), overlay, dan card polos.',
          usage: 'Kartu konten dengan media, avatar, judul, keterangan, dan aksi. Isi onTap agar seluruh kartu bisa ditekan. IddsCardPlain adalah wadah bergaris tepi untuk isi bebas.',
          code: _cardCode,
          children: <Widget>[
            Wrap(
              spacing: IddsSpacing.s16,
              runSpacing: IddsSpacing.s16,
              children: <Widget>[
                SizedBox(
                  width: 340,
                  child: IddsCard(
                    mediaPosition: IddsCardMediaPosition.top,
                    media: _media(context, TablerIcons.school),
                    avatar: const IddsAvatar(initials: 'DK'),
                    title: const Text('Beasiswa Pendidikan 2026'),
                    description: const Text('Pendaftaran dibuka hingga 30 November 2026 untuk mahasiswa aktif.'),
                    action: IddsButton(onPressed: () {}, child: const Text('Daftar sekarang')),
                  ),
                ),
                SizedBox(
                  width: 340,
                  child: IddsCard(
                    variant: IddsCardVariant.overlay,
                    media: _media(context, TablerIcons.mountain),
                    title: const Text('Wisata Danau Limboto'),
                    description: const Text('Kenali potensi wisata dan ekonomi kreatif di sekitar danau.'),
                    onTap: () => showGallerySnack(context, 'Kartu ditekan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: IddsSpacing.s16),
            IddsCard(
              variant: IddsCardVariant.horizontal,
              media: _media(context, TablerIcons.file_text),
              title: const Text('Laporan Kinerja Triwulan III'),
              description: const Text('Ringkasan capaian layanan digital pemerintah daerah selama Juli–September.'),
              onTap: () => showGallerySnack(context, 'Membuka laporan'),
            ),
            const SizedBox(height: IddsSpacing.s16),
            const IddsCardPlain(child: Text('Card polos: wadah bergaris tepi untuk konten apa saja.')),
          ],
        ),
        GallerySection(
          title: 'Loading & Divider',
          usage: 'Spinner untuk proses singkat, progress bar/circle bila kemajuan diketahui (value 0–1, null untuk berjalan terus), dan skeleton sebagai kerangka konten saat data dimuat.',
          code: _loadingCode,
          children: <Widget>[
            const Wrap(
              spacing: IddsSpacing.s32,
              runSpacing: IddsSpacing.s16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                IddsSpinner(),
                IddsSpinner(size: 32, strokeWidth: 4, color: IddsLoadingColor.success),
                IddsSpinner(title: 'Memuat data', subtitle: 'Mohon tunggu sebentar'),
              ],
            ),
            const SizedBox(height: IddsSpacing.s24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: IddsSpacing.s12,
                children: <Widget>[
                  IddsProgressBar(value: _progress),
                  const IddsProgressBar(height: IddsProgressBarHeight.lg, color: IddsLoadingColor.success, value: 0.8),
                  const IddsProgressBar(),
                  Row(
                    spacing: IddsSpacing.s12,
                    children: <Widget>[
                      IddsCircleProgress(value: _progress),
                      IddsCircleProgress(value: _progress, diameter: 40, strokeWidth: 4),
                      Text('${(_progress * 100).round()}%'),
                      const Spacer(),
                      IddsButton(
                        size: IddsButtonSize.sm,
                        hierarchy: IddsButtonHierarchy.secondary,
                        onPressed: () => setState(() => _progress = _progress >= 1 ? 0 : _progress + 0.2),
                        child: const Text('Tambah'),
                      ),
                    ],
                  ),
                  const IddsDivider(spacing: IddsSpacing.s8, label: Text('Skeleton')),
                  const Row(
                    spacing: IddsSpacing.s12,
                    children: <Widget>[
                      IddsSkeleton.circle(size: 48),
                      Expanded(
                        child: Column(
                          spacing: IddsSpacing.s8,
                          children: <Widget>[
                            IddsSkeleton(height: 16),
                            IddsSkeleton(height: 12, color: IddsSkeletonColor.blue),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const IddsSkeleton(height: 120, radius: IddsRadius.lg),
                  const IddsDivider(variant: IddsDividerVariant.middle, light: true),
                  const IntrinsicHeight(
                    child: Row(
                      spacing: IddsSpacing.s12,
                      children: <Widget>[Text('Beranda'), IddsDivider.vertical(), Text('Layanan'), IddsDivider.vertical(), Text('Kontak')],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const String _accordionCode = r'''
const IddsAccordionGroup(
  initiallyOpen: {0}, // indeks panel yang terbuka di awal
  items: [
    IddsAccordionItem(
      title: Text('Siapa yang bisa mendaftar?'),
      child: Text('Warga berusia 17–35 tahun yang sedang kuliah.'),
    ),
    IddsAccordionItem(
      title: Text('Dokumen apa saja yang dibutuhkan?'),
      child: Text('KTP, Kartu Keluarga, dan transkrip nilai.'),
    ),
  ],
)

const IddsAccordionCard(
  title: Text('Rincian biaya layanan'),
  child: Text('Layanan ini tidak dipungut biaya.'),
)
''';

const String _cardCode = r'''
IddsCard(
  media: Image.network(imageUrl, fit: BoxFit.cover),
  avatar: const IddsAvatar(initials: 'Dinas Kominfo'),
  title: const Text('Beasiswa Pendidikan 2026'),
  description: const Text('Pendaftaran dibuka hingga 30 November.'),
  action: IddsButton(onPressed: register, child: const Text('Daftar')),
)

IddsCard(
  variant: IddsCardVariant.horizontal, // basic, horizontal, overlay
  media: Image.asset('assets/laporan.png', fit: BoxFit.cover),
  title: const Text('Laporan Kinerja Triwulan III'),
  onTap: () => openReport(),
)

const IddsCardPlain(child: Text('Isi apa saja'))
''';

const String _loadingCode = r'''
const IddsSpinner(title: 'Memuat data', subtitle: 'Mohon tunggu sebentar')

IddsProgressBar(value: progress) // 0.0–1.0; tanpa value = berjalan terus
IddsCircleProgress(value: progress)

const IddsSkeleton(height: 16)
const IddsSkeleton.circle(size: 48)

const IddsDivider(label: Text('atau'))
const IddsDivider.vertical() // di dalam Row + IntrinsicHeight
''';
