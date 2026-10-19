import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

void main() {
  test('iddsCompactNumber memakai satuan Indonesia', () {
    expect(iddsCompactNumber(950), '950');
    expect(iddsCompactNumber(1200), '1,2 rb');
    expect(iddsCompactNumber(3400000), '3,4 jt');
    expect(iddsCompactNumber(5e9), '5 M');
    expect(iddsCompactNumber(1.1e12), '1,1 T');
    expect(iddsCompactNumber(-2500), '-2,5 rb');
  });

  testWidgets('IddsLineChart: legenda untuk 2 seri dan tooltip saat diketuk', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(
      width: 400,
      child: IddsLineChart(
        labels: <String>['Jan', 'Feb', 'Mar'],
        series: <IddsChartSeries>[
          IddsChartSeries(name: 'Permohonan', values: <double?>[120, 180, 150]),
          IddsChartSeries(name: 'Selesai', values: <double?>[100, null, 140]),
        ],
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Permohonan'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    await tester.tap(find.byType(IddsLineChart));
    await tester.pump();
    // Kategori tengah: Feb. Seri "Selesai" kosong di Feb, jadi hanya satu baris nilai.
    expect(find.text('Feb'), findsOneWidget);
    expect(find.text('180'), findsOneWidget);
    expect(find.text('Permohonan'), findsNWidgets(2));
    expect(find.text('Selesai'), findsOneWidget);
  });

  testWidgets('IddsLineChart satu seri tanpa legenda', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(
      width: 300,
      child: IddsLineChart(
        labels: <String>['A', 'B'],
        series: <IddsChartSeries>[IddsChartSeries(name: 'Tunggal', values: <double?>[1, 2])],
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Tunggal'), findsNothing);
  });

  testWidgets('IddsBarChart mendatar & bertumpuk menampilkan tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(
      width: 400,
      child: IddsBarChart(
        horizontal: true,
        stacked: true,
        labels: <String>['Kota', 'Kabupaten'],
        series: <IddsChartSeries>[
          IddsChartSeries(name: 'Laki-laki', values: <double?>[1200, 800]),
          IddsChartSeries(name: 'Perempuan', values: <double?>[1100, 900]),
        ],
      ),
    )));
    await tester.pumpAndSettle();
    final Rect r = tester.getRect(find.byType(IddsBarChart));
    // Ketuk area bawah plot (kategori kedua).
    await tester.tapAt(Offset(r.center.dx, r.bottom - 40));
    await tester.pump();
    expect(find.text('Kabupaten'), findsOneWidget);
    expect(find.text('800'), findsOneWidget);
    expect(find.text('900'), findsOneWidget);
  });

  testWidgets('IddsBarChart menerima data kosong', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(
      width: 300,
      child: IddsBarChart(labels: <String>[], series: <IddsChartSeries>[]),
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('IddsPieChart donat: total di tengah dan persen di legenda', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(
      width: 500,
      child: IddsPieChart(
        donut: true,
        centerLabel: 'Total',
        slices: <IddsChartSlice>[
          IddsChartSlice(label: 'Daring', value: 75),
          IddsChartSlice(label: 'Luring', value: 25),
        ],
      ),
    )));
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('75 · 75%'), findsOneWidget);
    expect(find.text('25 · 25%'), findsOneWidget);
  });

  testWidgets('Grafik tampil di mode gelap', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(
      const SizedBox(
        width: 400,
        child: IddsBarChart(
          showValues: true,
          labels: <String>['A', 'B'],
          series: <IddsChartSeries>[IddsChartSeries(name: 'X', values: <double?>[3, -2])],
        ),
      ),
      theme: IddsThemeData(brightness: Brightness.dark),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
