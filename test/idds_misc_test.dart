import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

Widget _navApp(Widget Function(BuildContext context) home) => WidgetsApp(
      color: const Color(0xFF000000),
      pageRouteBuilder: <T>(RouteSettings s, WidgetBuilder b) =>
          PageRouteBuilder<T>(settings: s, pageBuilder: (BuildContext c, _, __) => b(c)),
      home: IddsTheme(data: IddsThemeData(), child: Builder(builder: home)),
    );

void main() {
  testWidgets('IddsMonthPicker memilih bulan', (WidgetTester tester) async {
    int? month;
    await tester.pumpWidget(testApp(SizedBox(
      width: 260,
      child: IddsMonthPicker(value: null, lastMonth: 6, onChanged: (int? m) => month = m),
    )));
    await tester.tap(find.text('Pilih bulan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sep'));
    await tester.pumpAndSettle();
    expect(month, isNull);
    await tester.tap(find.text('Mar'));
    await tester.pumpAndSettle();
    expect(month, 3);
  });

  testWidgets('IddsYearPicker berpindah halaman', (WidgetTester tester) async {
    int? year;
    await tester.pumpWidget(testApp(SizedBox(
      width: 300,
      child: IddsYearPicker(value: 2026, onChanged: (int? y) => year = y),
    )));
    await tester.tap(find.text('2026'));
    await tester.pumpAndSettle();
    expect(find.text('2020 – 2039'), findsOneWidget);
    await tester.tap(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.chevronRight));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2045'));
    await tester.pumpAndSettle();
    expect(year, 2045);
  });

  testWidgets('IddsThemeToggle membalik nilai', (WidgetTester tester) async {
    bool dark = false;
    await tester.pumpWidget(testApp(IddsThemeToggle(dark: dark, showLabel: true, onChanged: (bool v) => dark = v)));
    expect(find.text('Mode terang'), findsOneWidget);
    await tester.tap(find.byType(IddsThemeToggle));
    expect(dark, isTrue);
  });

  testWidgets('IddsList item bisa ditekan', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(testApp(SizedBox(
      width: 300,
      child: IddsList(
        subheader: const IddsListSubheader('Layanan'),
        dividers: true,
        children: <Widget>[
          IddsListItem(title: const Text('KTP'), subtitle: const Text('Kartu identitas'), onTap: () => taps++),
          const IddsListItem(title: Text('KK')),
        ],
      ),
    )));
    await tester.tap(find.text('KTP'));
    expect(taps, 1);
    // Subheader ditulis kapital seperti React, tetapi dibacakan apa adanya.
    expect(find.text('LAYANAN'), findsOneWidget);
    expect(find.bySemanticsLabel('Layanan'), findsOneWidget);
  });

  testWidgets('IddsListItem: jarak ikon ke judul 12px', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(
      width: 300,
      child: IddsListItem(leading: IddsIcon(IddsIcons.file, size: 20), title: Text('Dokumen')),
    )));
    final Rect icon = tester.getRect(find.byType(IddsIcon));
    final Rect title = tester.getRect(find.text('Dokumen'));
    expect(title.left - icon.right, 12);
  });

  testWidgets('IddsChoiceGrid satu jawaban per baris', (WidgetTester tester) async {
    Map<String, String> answers = <String, String>{};
    Widget build() => testApp(IddsChoiceGrid(
          rows: const <IddsChoiceGridItem>[
            IddsChoiceGridItem(id: 'a', label: 'Kecepatan'),
            IddsChoiceGridItem(id: 'b', label: 'Keramahan'),
          ],
          columns: const <IddsChoiceGridItem>[
            IddsChoiceGridItem(id: '1', label: 'Kurang'),
            IddsChoiceGridItem(id: '2', label: 'Baik'),
          ],
          selected: answers,
          onChanged: (Map<String, String> v) => answers = v,
        ));
    await tester.pumpWidget(build());
    final Finder radios = find.byWidgetPredicate((Widget w) => w.runtimeType.toString() == '_GridRadio');
    expect(radios, findsNWidgets(4));
    await tester.tap(radios.at(1));
    expect(answers, <String, String>{'a': '2'});
    await tester.pumpWidget(build());
    await tester.tap(radios.at(2));
    expect(answers, <String, String>{'a': '2', 'b': '1'});
  });

  testWidgets('showIddsBottomSheet: tarik ke bawah menutup, locked tidak', (WidgetTester tester) async {
    await tester.pumpWidget(_navApp((BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => showIddsBottomSheet<void>(
                context: context,
                builder: (BuildContext context) => const SizedBox(height: 200, child: Text('Isi panel')),
              ),
              child: const Text('Buka'),
            ),
            GestureDetector(
              onTap: () => showIddsBottomSheet<void>(
                context: context,
                locked: true,
                builder: (BuildContext context) => const SizedBox(height: 200, child: Text('Terkunci')),
              ),
              child: const Text('Buka terkunci'),
            ),
          ],
        )));
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(find.text('Isi panel'), findsOneWidget);
    await tester.drag(find.text('Isi panel'), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(find.text('Isi panel'), findsNothing);

    await tester.tap(find.text('Buka terkunci'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Terkunci'), const Offset(0, 300));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(find.text('Terkunci'), findsOneWidget);
  });
}
