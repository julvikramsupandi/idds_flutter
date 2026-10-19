import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class BadgeSection extends StatelessWidget {
  const BadgeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Badge',
      usage: 'Label status singkat. Pilih variant sesuai makna (success untuk aktif/selesai, error untuk gagal, dst.) dan type soft untuk latar lembut atau fill untuk latar penuh.',
      code: _badgeCode,
      children: <Widget>[
        for (final IddsBadgeType type in IddsBadgeType.values) ...<Widget>[
          GalleryCaption(type.name),
          const SizedBox(height: IddsSpacing.s8),
          Wrap(
            spacing: IddsSpacing.s8,
            runSpacing: IddsSpacing.s8,
            children: <Widget>[
              for (final IddsBadgeVariant v in IddsBadgeVariant.values)
                IddsBadge(type: type, variant: v, child: Text(v.name)),
            ],
          ),
          const SizedBox(height: IddsSpacing.s16),
        ],
        const GalleryCaption('Ukuran, radius, dan ikon'),
        const SizedBox(height: IddsSpacing.s8),
        Wrap(
          spacing: IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (final IddsBadgeSize s in IddsBadgeSize.values)
              IddsBadge(size: s, variant: IddsBadgeVariant.success, child: Text('Size ${s.name}')),
            for (final IddsBadgeRounded r in IddsBadgeRounded.values)
              IddsBadge(rounded: r, variant: IddsBadgeVariant.neutral, child: Text('Rounded ${r.name}')),
            const IddsBadge(
              variant: IddsBadgeVariant.warning,
              prefixIcon: IddsIcon(IddsIcons.alertTriangle),
              child: Text('Dengan ikon'),
            ),
          ],
        ),
      ],
    );
  }
}

class AvatarSection extends StatelessWidget {
  const AvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Avatar',
      subtitle: 'Foto gagal dimuat akan kembali ke inisial.',
      usage: 'Inisial diambil dari dua kata pertama initials. Bila image diisi tetapi gagal dimuat, avatar kembali menampilkan inisial.',
      code: _avatarCode,
      children: <Widget>[
        for (final IddsAvatarShape shape in IddsAvatarShape.values) ...<Widget>[
          Wrap(
            spacing: IddsSpacing.s12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final IddsAvatarSize s in IddsAvatarSize.values)
                IddsAvatar(initials: 'Julvikram Supandi', size: s, shape: shape),
              IddsAvatar(
                image: const NetworkImage('https://invalid.example/foto.png'),
                initials: 'GT',
                size: IddsAvatarSize.s48,
                shape: shape,
              ),
            ],
          ),
          const SizedBox(height: IddsSpacing.s12),
        ],
      ],
    );
  }
}

class AlertSection extends StatefulWidget {
  const AlertSection({super.key});

  @override
  State<AlertSection> createState() => _AlertSectionState();
}

class _AlertSectionState extends State<AlertSection> {
  final Set<IddsAlertVariant> _hidden = <IddsAlertVariant>{};

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Alert',
      usage: 'Untuk pesan penting di dalam halaman. Alert tidak menyembunyikan dirinya sendiri: simpan status tampil di state dan hapus widget saat onDismiss dipanggil. Untuk notifikasi sementara, pakai Toast.',
      code: _alertCode,
      children: <Widget>[
        for (final IddsAlertVariant v in IddsAlertVariant.values)
          if (!_hidden.contains(v))
            Padding(
              padding: const EdgeInsets.only(bottom: IddsSpacing.s12),
              child: IddsAlert(
                variant: v,
                title: Text('Alert ${v.name}'),
                message: const Text('Deskripsi singkat, idealnya tidak lebih dari dua baris.'),
                onDismiss: () => setState(() => _hidden.add(v)),
              ),
            ),
        if (_hidden.isNotEmpty)
          IddsButton(
            hierarchy: IddsButtonHierarchy.link,
            onPressed: () => setState(_hidden.clear),
            child: const Text('Tampilkan lagi'),
          ),
      ],
    );
  }
}

const String _badgeCode = r'''
const IddsBadge(
  variant: IddsBadgeVariant.success, // brand, info, warning, success, error, neutral
  child: Text('Aktif'),
)

const IddsBadge(
  type: IddsBadgeType.fill, // soft (bawaan) atau fill
  size: IddsBadgeSize.lg, // sm, md, lg, xl
  rounded: IddsBadgeRounded.full,
  variant: IddsBadgeVariant.warning,
  prefixIcon: Icon(TablerIcons.alert_triangle),
  child: Text('Perlu tinjauan'),
)
''';

const String _avatarCode = r'''
const IddsAvatar(initials: 'Julvikram Supandi') // tampil "JS"

IddsAvatar(
  image: NetworkImage(user.photoUrl),
  initials: user.name,
  size: IddsAvatarSize.s48, // s16, s24, s32, s40, s48
  shape: IddsAvatarShape.square, // circle (bawaan) atau square
)
''';

const String _alertCode = r'''
if (_showAlert)
  IddsAlert(
    variant: IddsAlertVariant.success, // neutral, info, success, caution, critical
    title: const Text('Data tersimpan'),
    message: const Text('Perubahan sudah bisa dilihat publik.'),
    // Tombol X hanya muncul bila onDismiss diisi.
    onDismiss: () => setState(() => _showAlert = false),
  ),
''';
