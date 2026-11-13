import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'application_form_screen.dart';
import 'mobile_common.dart';
import 'phone_frame.dart';

/// Satu layanan di grid Beranda.
class _Service {
  const _Service(
      this.name, this.icon, this.description, this.requirements, this.duration);

  final String name;
  final IconData icon;
  final String description;
  final List<String> requirements;
  final String duration;
}

const List<_Service> _services = <_Service>[
  _Service(
      'KTP-el',
      TablerIcons.id,
      'Rekam baru, cetak ulang karena rusak atau hilang, dan perubahan data KTP-el.',
      <String>[
        'Kartu Keluarga',
        'Surat kehilangan dari kepolisian (bila hilang)'
      ],
      '1–3 hari kerja'),
  _Service(
      'Kartu Keluarga',
      TablerIcons.users,
      'Penerbitan KK baru, penambahan anggota, atau perubahan data keluarga.',
      <String>['KK lama', 'Akta kelahiran / buku nikah'],
      '1–3 hari kerja'),
  _Service(
      'Akta Kelahiran',
      TablerIcons.baby_carriage,
      'Pencatatan kelahiran dan penerbitan akta kelahiran anak.',
      <String>['Surat keterangan lahir', 'KK dan KTP-el orang tua'],
      '1–2 hari kerja'),
  _Service(
      'Pindah Domisili',
      TablerIcons.home_move,
      'Surat keterangan pindah datang dan pindah keluar daerah.',
      <String>['KK dan KTP-el', 'Alamat tujuan lengkap'],
      '2–5 hari kerja'),
  _Service(
      'Pajak Daerah',
      TablerIcons.receipt_tax,
      'Cek tagihan dan bayar PBB serta pajak kendaraan bermotor.',
      <String>['NOP PBB atau nomor polisi kendaraan'],
      'Langsung'),
  _Service(
      'Kesehatan',
      TablerIcons.stethoscope,
      'Daftar antrean puskesmas dan cek status kepesertaan jaminan kesehatan.',
      <String>['NIK', 'Nomor kartu jaminan kesehatan'],
      'Langsung'),
  _Service(
      'Bantuan Sosial',
      TablerIcons.heart_handshake,
      'Cek penerima dan ajukan usulan bantuan sosial.',
      <String>['NIK dan KK'],
      '5–14 hari kerja'),
  _Service('Lainnya', TablerIcons.layout_grid,
      'Lihat semua layanan yang tersedia di daerah Anda.', <String>[], '-'),
];

/// Beranda aplikasi layanan publik: sapaan, pencarian, status pengajuan,
/// grid layanan (detail di bottom sheet), informasi terbaru, dan navigasi
/// bawah.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _notAvailable(String page) => showPhoneToast(context,
      title: Text('Halaman $page tidak ada di contoh ini'));

  void _openService(_Service service) {
    showIddsBottomSheet<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext sheetContext) => _ServiceSheet(
        service: service,
        onApply: () {
          Navigator.pop(sheetContext);
          Navigator.of(context).push(
            PageRouteBuilder<void>(
              pageBuilder: (BuildContext context, Animation<double> a,
                      Animation<double> b) =>
                  ApplicationFormScreen(serviceName: service.name),
              transitionsBuilder: (BuildContext context, Animation<double> a,
                      Animation<double> b, Widget child) =>
                  SlideTransition(
                position: Tween<Offset>(
                        begin: const Offset(1, 0), end: Offset.zero)
                    .animate(
                        CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    final Widget header = Padding(
      padding: EdgeInsets.fromLTRB(IddsSpacing.s16, safe.top + IddsSpacing.s8,
          IddsSpacing.s8, IddsSpacing.s8),
      child: Row(
        spacing: IddsSpacing.s12,
        children: <Widget>[
          const IddsAvatar(initials: 'SR', size: IddsAvatarSize.s40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Selamat pagi,',
                  style: theme.textStyle(
                      fontSize: IddsFontSize.xs,
                      lineHeight: IddsLineHeight.xs,
                      color: c.contentSecondary),
                ),
                Text(
                  'Siti Rahmawati',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textStyle(
                    fontSize: IddsFontSize.base,
                    lineHeight: IddsLineHeight.base,
                    fontWeight: IddsFontWeight.semibold,
                    color: c.contentPrimary,
                  ),
                ),
              ],
            ),
          ),
          IddsButton(
            hierarchy: IddsButtonHierarchy.tertiary,
            semanticLabel: 'Notifikasi, 3 belum dibaca',
            onPressed: () => showPhoneToast(context,
                title: const Text('3 notifikasi belum dibaca')),
            // Angka menempel di sudut ikon, sehingga posisinya tetap benar
            // walau tombol mengecil di layar < 640px.
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(TablerIcons.bell),
                Positioned(
                  top: -6,
                  right: -8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    padding:
                        const EdgeInsets.symmetric(horizontal: IddsSpacing.s4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.negative.shade500,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: c.backgroundPrimary, width: 1.5),
                    ),
                    child: Text(
                      '3',
                      style: theme.textStyle(
                        fontSize: IddsFontSize.xs2,
                        lineHeight: 12,
                        fontWeight: IddsFontWeight.semibold,
                        color: c.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        header,
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(IddsSpacing.s16, IddsSpacing.s8,
                IddsSpacing.s16, IddsSpacing.s24),
            children: <Widget>[
              const IddsSearchField(placeholder: 'Cari layanan'),
              const SizedBox(height: IddsSpacing.s16),
              _ActiveApplicationCard(
                  onTap: () => _notAvailable('detail pengajuan')),
              const SizedBox(height: IddsSpacing.s24),
              const MobileSectionTitle('Layanan'),
              const SizedBox(height: IddsSpacing.s12),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  const double gap = IddsSpacing.s8;
                  final double width = (constraints.maxWidth - gap * 3) / 4;
                  return Wrap(
                    spacing: gap,
                    runSpacing: IddsSpacing.s16,
                    children: <Widget>[
                      for (final _Service s in _services)
                        SizedBox(
                            width: width,
                            child: _ServiceTile(
                                service: s, onTap: () => _openService(s))),
                    ],
                  );
                },
              ),
              const SizedBox(height: IddsSpacing.s24),
              MobileSectionTitle(
                'Informasi Terbaru',
                action: IddsButton(
                  hierarchy: IddsButtonHierarchy.link,
                  onPressed: () => showPhoneToast(context,
                      title: const Text('Membuka semua informasi')),
                  child: const Text('Lihat semua'),
                ),
              ),
              IddsList(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  for (final (String title, String date, IconData icon)
                      in const <(String, String, IconData)>[
                    (
                      'Perekaman KTP-el keliling di Kecamatan Kota Barat',
                      '12 Nov 2026',
                      TablerIcons.speakerphone
                    ),
                    (
                      'Jadwal layanan libur akhir tahun',
                      '10 Nov 2026',
                      TablerIcons.calendar_event
                    ),
                    (
                      'Pembayaran PBB kini bisa lewat aplikasi',
                      '5 Nov 2026',
                      TablerIcons.news
                    ),
                  ])
                    IddsListItem(
                      leading: Icon(icon),
                      title: Text(title,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(date),
                      trailing: const Icon(TablerIcons.chevron_right),
                      alignTop: true,
                      onTap: () => showPhoneToast(context, title: Text(title)),
                    ),
                ],
              ),
            ],
          ),
        ),
        _BottomNavigation(
            current: 0,
            onChanged: (int i) {
              if (i != 0) _notAvailable(_BottomNavigation.items[i].$1);
            }),
      ],
    );
  }
}

class _ActiveApplicationCard extends StatelessWidget {
  const _ActiveApplicationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return IddsCardPlain(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: IddsSpacing.s8,
        children: <Widget>[
          Row(
            spacing: IddsSpacing.s8,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Pengajuan Aktif',
                  style: theme.textStyle(
                      fontSize: IddsFontSize.xs,
                      lineHeight: IddsLineHeight.xs,
                      color: c.contentSecondary),
                ),
              ),
              const IddsBadge(
                  variant: IddsBadgeVariant.warning,
                  size: IddsBadgeSize.sm,
                  child: Text('Diproses')),
            ],
          ),
          Text(
            'Surat Keterangan Pindah Domisili',
            style: theme.textStyle(
              fontSize: IddsFontSize.sm,
              lineHeight: IddsLineHeight.sm,
              fontWeight: IddsFontWeight.semibold,
              color: c.contentPrimary,
            ),
          ),
          const SizedBox(height: IddsSpacing.s4),
          const IddsProgressBar(
              value: 0.6, semanticLabel: 'Kemajuan pengajuan'),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Verifikasi berkas · langkah 3 dari 5',
                  style: theme.textStyle(
                      fontSize: IddsFontSize.xs,
                      lineHeight: IddsLineHeight.xs,
                      color: c.contentSecondary),
                ),
              ),
              IddsButton(
                hierarchy: IddsButtonHierarchy.link,
                onPressed: onTap,
                child: const Text('Detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service, required this.onTap});

  final _Service service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Semantics(
      button: true,
      label: service.name,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          spacing: IddsSpacing.s8,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.isDark ? c.primary.shade900 : c.primary.shade50,
                borderRadius: BorderRadius.circular(IddsRadius.xl),
              ),
              child: Icon(service.icon,
                  size: 24,
                  color:
                      theme.isDark ? c.primary.shade200 : c.primary.shade600),
            ),
            Text(
              service.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textStyle(
                  fontSize: IddsFontSize.xs,
                  lineHeight: IddsLineHeight.xs,
                  color: c.contentPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSheet extends StatelessWidget {
  const _ServiceSheet({required this.service, required this.onApply});

  final _Service service;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        IddsSpacing.s16,
        IddsSpacing.s8,
        IddsSpacing.s16,
        IddsSpacing.s16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: IddsSpacing.s12,
        children: <Widget>[
          Text(
            service.name,
            style: theme.textStyle(
              fontSize: IddsFontSize.lg,
              lineHeight: IddsLineHeight.lg,
              fontWeight: IddsFontWeight.semibold,
              color: c.contentPrimary,
            ),
          ),
          Text(
            service.description,
            style: theme.textStyle(
                fontSize: IddsFontSize.sm,
                lineHeight: IddsLineHeight.sm,
                color: c.contentSecondary),
          ),
          if (service.requirements.isNotEmpty)
            IddsList(
              padding: EdgeInsets.zero,
              subheader: const IddsListSubheader('Persyaratan'),
              children: <Widget>[
                for (final String r in service.requirements)
                  IddsListItem(
                      dense: true,
                      leading: const Icon(TablerIcons.circle_check),
                      title: Text(r)),
              ],
            ),
          Row(
            spacing: IddsSpacing.s8,
            children: <Widget>[
              Icon(TablerIcons.clock_hour_4,
                  size: 16, color: c.contentSecondary),
              Flexible(
                child: Text(
                  'Perkiraan selesai: ${service.duration}',
                  style: theme.textStyle(
                      fontSize: IddsFontSize.xs,
                      lineHeight: IddsLineHeight.xs,
                      color: c.contentSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: IddsSpacing.s4),
          IddsButton(onPressed: onApply, child: const Text('Ajukan Sekarang')),
        ],
      ),
    );
  }
}

/// Navigasi bawah. IDDS belum punya komponen navigasi bawah, jadi contoh
/// ini dirakit dari token warna & tipografi IDDS.
class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.current, required this.onChanged});

  final int current;
  final ValueChanged<int> onChanged;

  static const List<(String, IconData)> items = <(String, IconData)>[
    ('Beranda', TablerIcons.home),
    ('Riwayat', TablerIcons.history),
    ('Dokumen', TablerIcons.file_text),
    ('Profil', TablerIcons.user),
  ];

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        border: Border(top: BorderSide(color: c.strokePrimary)),
      ),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == current,
                label: items[i].$1,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: SizedBox(
                    height: 56,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: IddsSpacing.s2,
                      children: <Widget>[
                        Icon(items[i].$2,
                            size: 22,
                            color: i == current
                                ? c.primaryMain
                                : c.contentTertiary),
                        Text(
                          items[i].$1,
                          style: theme.textStyle(
                            fontSize: IddsFontSize.xs2,
                            lineHeight: IddsLineHeight.xs,
                            fontWeight: i == current
                                ? IddsFontWeight.semibold
                                : IddsFontWeight.normal,
                            color: i == current
                                ? c.primaryMain
                                : c.contentTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
