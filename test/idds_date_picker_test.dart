import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

/// Senin, 17 Agustus 2026.
final DateTime _today = DateTime(2026, 8, 17);

/// Kolom diletakkan di atas layar agar panel punya ruang di bawahnya.
Widget _top(Widget child) => testApp(Align(alignment: Alignment.topCenter, child: SizedBox(width: 320, child: child)));

class _RangeHarness extends StatefulWidget {
  const _RangeHarness({required this.log});

  final List<IddsDateRange?> log;

  @override
  State<_RangeHarness> createState() => _RangeHarnessState();
}

class _RangeHarnessState extends State<_RangeHarness> {
  IddsDateRange? value;

  @override
  Widget build(BuildContext context) {
    return IddsDateRangePicker(
      value: value,
      currentDate: _today,
      monthCount: 1,
      onChanged: (IddsDateRange? v) {
        widget.log.add(v);
        setState(() => value = v);
      },
    );
  }
}

class _MultiHarness extends StatefulWidget {
  const _MultiHarness();

  @override
  State<_MultiHarness> createState() => _MultiHarnessState();
}

class _MultiHarnessState extends State<_MultiHarness> {
  List<DateTime> values = <DateTime>[];

  @override
  Widget build(BuildContext context) {
    return IddsMultiDatePicker(
      values: values,
      currentDate: _today,
      monthCount: 1,
      onChanged: (List<DateTime> v) => setState(() => values = v),
    );
  }
}

void main() {
  group('iddsFormatDate / iddsParseDate', () {
    test('format bawaan dan pola nama', () {
      final DateTime d = DateTime(2026, 8, 7);
      expect(iddsFormatDate(d), '07/08/2026');
      expect(iddsFormatDate(d, 'EEEE, d MMMM yyyy'), 'Jumat, 7 Agustus 2026');
      expect(iddsFormatDate(d, "d MMM yy 'pukul'"), '7 Agu 26 pukul');
      expect(iddsFormatDate(d, 'yyyy-MM-dd'), '2026-08-07');
    });

    test('parse sesuai pola dan menolak tanggal tidak valid', () {
      expect(iddsParseDate('17/08/2026'), DateTime(2026, 8, 17));
      expect(iddsParseDate('2026-8-17', 'yyyy-MM-dd'), DateTime(2026, 8, 17));
      expect(iddsParseDate('31/02/2026'), isNull);
      expect(iddsParseDate('abc'), isNull);
    });

    test('IddsDateRange menukar urutan dan menghitung hari', () {
      final IddsDateRange r = IddsDateRange(start: DateTime(2026, 8, 20), end: DateTime(2026, 8, 10));
      expect(r.start, DateTime(2026, 8, 10));
      expect(r.dayCount, 11);
      expect(r.contains(DateTime(2026, 8, 15, 13)), isTrue);
      expect(IddsDateRange(start: DateTime(2026, 8, 10)).isComplete, isFalse);
    });
  });

  group('IddsDatePicker', () {
    testWidgets('memilih tanggal lalu menutup panel', (WidgetTester tester) async {
      DateTime? picked;
      await tester.pumpWidget(_top(IddsDatePicker(value: null, currentDate: _today, onChanged: (DateTime? d) => picked = d)));
      expect(find.text('Pilih tanggal'), findsOneWidget);

      await tester.tap(find.text('Pilih tanggal'));
      await tester.pumpAndSettle();
      expect(find.text('Agustus'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);

      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      expect(picked, DateTime(2026, 8, 20));
      expect(find.text('Agustus'), findsNothing);
    });

    testWidgets('menampilkan nilai dan tombol hapus', (WidgetTester tester) async {
      DateTime? picked = DateTime(2026, 1, 1);
      await tester.pumpWidget(_top(IddsDatePicker(
        value: DateTime(2026, 8, 5),
        dateFormat: 'd MMMM yyyy',
        onChanged: (DateTime? d) => picked = d,
      )));
      expect(find.text('5 Agustus 2026'), findsOneWidget);
      await tester.tap(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.x));
      await tester.pumpAndSettle();
      expect(picked, isNull);
    });

    testWidgets('tanggal setelah hari ini nonaktif dengan disableFuture', (WidgetTester tester) async {
      DateTime? picked;
      await tester.pumpWidget(_top(IddsDatePicker(
        value: null,
        currentDate: _today,
        disableFuture: true,
        onChanged: (DateTime? d) => picked = d,
      )));
      await tester.tap(find.text('Pilih tanggal'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
      await tester.tap(find.text('16'));
      await tester.pumpAndSettle();
      expect(picked, DateTime(2026, 8, 16));
    });

    testWidgets('keyboard: panah kanan lalu Enter', (WidgetTester tester) async {
      DateTime? picked;
      await tester.pumpWidget(_top(IddsDatePicker(value: null, currentDate: _today, onChanged: (DateTime? d) => picked = d)));
      await tester.tap(find.text('Pilih tanggal'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked, DateTime(2026, 8, 25));
    });

    testWidgets('pilihan bulan dan tahun', (WidgetTester tester) async {
      await tester.pumpWidget(_top(IddsDatePicker(value: null, currentDate: _today, onChanged: (_) {})));
      await tester.tap(find.text('Pilih tanggal'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Agustus'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mar'));
      await tester.pumpAndSettle();
      expect(find.text('Maret'), findsOneWidget);

      await tester.tap(find.text('2026'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2030'));
      await tester.pumpAndSettle();
      expect(find.text('Maret'), findsOneWidget);
      expect(find.text('2030'), findsOneWidget);
    });

    testWidgets('nonaktif dan hanya-baca tidak membuka panel', (WidgetTester tester) async {
      await tester.pumpWidget(_top(Column(
        children: <Widget>[
          const IddsDatePicker(value: null, onChanged: null, placeholder: 'Nonaktif'),
          IddsDatePicker(value: DateTime(2026, 8, 1), readOnly: true, onChanged: (_) {}),
        ],
      )));
      await tester.tap(find.text('Nonaktif'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('01/08/2026'));
      await tester.pumpAndSettle();
      expect(find.text('Agustus'), findsNothing);
      // Tombol hapus tidak tampil saat hanya-baca.
      expect(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.x), findsNothing);
    });
  });

  testWidgets('IddsDateRangePicker: awal lalu akhir, panel tertutup', (WidgetTester tester) async {
    final List<IddsDateRange?> log = <IddsDateRange?>[];
    await tester.pumpWidget(_top(_RangeHarness(log: log)));
    await tester.tap(find.text('Pilih rentang tanggal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('14'));
    await tester.pumpAndSettle();
    expect(log.last, IddsDateRange(start: DateTime(2026, 8, 14)));
    expect(find.text('14/08/2026 - '), findsOneWidget);

    // Memilih tanggal lebih awal sebagai akhir: urutan ditukar.
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(log.last, IddsDateRange(start: DateTime(2026, 8, 10), end: DateTime(2026, 8, 14)));
    expect(find.text('10/08/2026 - 14/08/2026'), findsOneWidget);
    expect(find.text('Agustus'), findsNothing);
  });

  testWidgets('IddsMultiDatePicker: tetap terbuka dan meringkas teks', (WidgetTester tester) async {
    await tester.pumpWidget(_top(const _MultiHarness()));
    await tester.tap(find.text('Pilih tanggal'));
    await tester.pumpAndSettle();
    for (final String d in <String>['3', '4', '5']) {
      await tester.tap(find.text(d).first);
      await tester.pumpAndSettle();
    }
    expect(find.text('03/08/2026, 04/08/2026, 05/08/2026'), findsOneWidget);
    expect(find.text('Agustus'), findsOneWidget);

    await tester.tap(find.text('6').first);
    await tester.pumpAndSettle();
    expect(find.text('4 tanggal dipilih'), findsOneWidget);

    // Menekan lagi membatalkan.
    await tester.tap(find.text('6').first);
    await tester.pumpAndSettle();
    expect(find.text('03/08/2026, 04/08/2026, 05/08/2026'), findsOneWidget);
  });

  testWidgets('IddsCalendar mulai Senin bila diatur', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(IddsCalendar(
      mode: IddsCalendarMode.single,
      selected: const <DateTime>[],
      currentDate: _today,
      firstDayOfWeek: DateTime.monday,
      onChanged: (_) {},
    )));
    final double sen = tester.getTopLeft(find.text('Sen')).dx;
    final double min = tester.getTopLeft(find.text('Min')).dx;
    expect(sen, lessThan(min));
  });
}
