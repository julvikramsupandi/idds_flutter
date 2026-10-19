import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class ChartSection extends StatefulWidget {
  const ChartSection({super.key});

  @override
  State<ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<ChartSection> {
  bool _stacked = false;
  bool _area = true;

  static const List<String> _months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  Widget _card(String title, Widget child) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: IddsCardPlain(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: IddsSpacing.s16,
            children: <Widget>[
              Text(
                title,
                style: IddsTheme.of(context).textStyle(
                  fontSize: IddsFontSize.base,
                  lineHeight: IddsLineHeight.base,
                  fontWeight: IddsFontWeight.semibold,
                  color: IddsTheme.of(context).colors.contentPrimary,
                ),
              ),
              child,
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Grafik',
      subtitle: 'Line, Bar, dan Pie/Donut, digambar sendiri dengan palet IddsChartColors. Sorot atau ketuk untuk tooltip.',
      usage: 'Warna seri mengikuti IddsChartColors.categorical sesuai urutan, bisa diganti per seri lewat color. Legenda tampil otomatis untuk dua seri atau lebih; null pada values membuat garis terputus.',
      code: _chartCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s16,
          children: <Widget>[
            _card(
              'Layanan kependudukan per bulan',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: IddsSpacing.s12,
                children: <Widget>[
                  Row(
                    spacing: IddsSpacing.s8,
                    children: <Widget>[
                      IddsToggle(value: _area, semanticLabel: 'Area', onChanged: (bool v) => setState(() => _area = v)),
                      const Text('Area'),
                    ],
                  ),
                  IddsLineChart(
                    labels: _months,
                    area: _area,
                    series: const <IddsChartSeries>[
                      IddsChartSeries(
                        name: 'Permohonan',
                        values: <double?>[1200, 1350, 1280, 1510, 1620, 1580, 1740, 1810, 1700, 1920, 2050, 2210],
                      ),
                      IddsChartSeries(
                        name: 'Selesai',
                        values: <double?>[1100, 1240, 1200, 1390, 1500, 1490, 1610, 1700, 1650, 1830, 1960, null],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _card(
              'Penerima bantuan per wilayah',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: IddsSpacing.s12,
                children: <Widget>[
                  Row(
                    spacing: IddsSpacing.s8,
                    children: <Widget>[
                      IddsToggle(value: _stacked, semanticLabel: 'Bertumpuk', onChanged: (bool v) => setState(() => _stacked = v)),
                      const Text('Bertumpuk'),
                    ],
                  ),
                  IddsBarChart(
                    labels: const <String>['Kota Gorontalo', 'Kab. Gorontalo', 'Bone Bolango', 'Pohuwato', 'Boalemo'],
                    stacked: _stacked,
                    series: const <IddsChartSeries>[
                      IddsChartSeries(name: 'Laki-laki', values: <double?>[4200, 5100, 2150, 1900, 1650]),
                      IddsChartSeries(name: 'Perempuan', values: <double?>[4500, 5300, 2300, 2050, 1700]),
                    ],
                  ),
                ],
              ),
            ),
            _card(
              'Peringkat kepuasan layanan',
              const IddsBarChart(
                horizontal: true,
                showValues: true,
                labels: <String>['Paspor', 'KTP Elektronik', 'Akta Kelahiran', 'SIM', 'NPWP'],
                series: <IddsChartSeries>[IddsChartSeries(name: 'Skor', values: <double?>[92, 88, 85, 79, 74])],
              ),
            ),
            _card(
              'Kanal pengajuan',
              const IddsPieChart(
                donut: true,
                centerLabel: 'Pengajuan',
                slices: <IddsChartSlice>[
                  IddsChartSlice(label: 'Aplikasi', value: 5400),
                  IddsChartSlice(label: 'Situs web', value: 3100),
                  IddsChartSlice(label: 'Loket', value: 1800),
                  IddsChartSlice(label: 'Pos', value: 300),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const String _chartCode = r'''
IddsLineChart(
  labels: const ['Jan', 'Feb', 'Mar', 'Apr'],
  area: true,
  series: const [
    IddsChartSeries(name: 'Permohonan', values: [1200, 1350, 1280, 1510]),
    IddsChartSeries(name: 'Selesai', values: [1100, 1240, null, 1390]),
  ],
)

IddsBarChart(
  labels: const ['Kota Gorontalo', 'Bone Bolango', 'Pohuwato'],
  horizontal: true, // stacked: true untuk menumpuk beberapa seri
  showValues: true,
  series: const [
    IddsChartSeries(name: 'Penerima', values: [4200, 2150, 1900]),
  ],
)

IddsPieChart(
  donut: true,
  centerLabel: 'Pengajuan',
  slices: const [
    IddsChartSlice(label: 'Aplikasi', value: 5400),
    IddsChartSlice(label: 'Situs web', value: 3100),
    IddsChartSlice(label: 'Loket', value: 1800),
  ],
)
''';
