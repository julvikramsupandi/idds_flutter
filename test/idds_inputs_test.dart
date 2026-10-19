import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

Finder _icon(IddsIconData data) => find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == data);

void main() {
  testWidgets('IddsTextArea tumbuh mengikuti baris', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(width: 300, child: IddsTextArea(minLines: 3, maxLines: 6))));
    final double h3 = tester.getSize(find.byType(IddsTextArea)).height;
    await tester.enterText(find.byType(EditableText), 'a\nb\nc\nd\ne');
    await tester.pump();
    final double h5 = tester.getSize(find.byType(IddsTextArea)).height;
    expect(h5, greaterThan(h3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('IddsPasswordField menyembunyikan dan menampilkan', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(width: 300, child: IddsPasswordField())));
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isTrue);
    await tester.tap(_icon(IddsIcons.eye));
    await tester.pump();
    expect(tester.widget<EditableText>(find.byType(EditableText)).obscureText, isFalse);
    expect(_icon(IddsIcons.eyeOff), findsOneWidget);
  });

  testWidgets('IddsSearchField memanggil onSearch setelah jeda', (WidgetTester tester) async {
    final List<String> searches = <String>[];
    await tester.pumpWidget(testApp(SizedBox(width: 300, child: IddsSearchField(onSearch: searches.add))));
    await tester.enterText(find.byType(EditableText), 'ktp');
    await tester.pump(const Duration(milliseconds: 100));
    expect(searches, isEmpty);
    await tester.pump(const Duration(milliseconds: 300));
    expect(searches, <String>['ktp']);
  });

  group('IddsPhoneInput', () {
    testWidgets('memformat angka dan mengirim nomor lengkap', (WidgetTester tester) async {
      String? value;
      await tester.pumpWidget(testApp(SizedBox(width: 360, child: IddsPhoneInput(onChanged: (String v) => value = v))));
      expect(find.text('+62'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), '081234567890');
      await tester.pump();
      expect(value, '+6281234567890');
      expect(find.text('081-2345-67890'), findsOneWidget);
    });

    testWidgets('memilih negara lewat pencarian', (WidgetTester tester) async {
      String? value;
      await tester.pumpWidget(testApp(SizedBox(
        width: 360,
        child: IddsPhoneInput(value: '+62812', onChanged: (String v) => value = v),
      )));
      expect(find.text('812'), findsOneWidget);
      await tester.tap(find.text('+62'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).last, 'malay');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Malaysia'));
      await tester.pumpAndSettle();
      expect(find.text('+60'), findsOneWidget);
      expect(value, '+60812');
    });
  });

  testWidgets('IddsOtpInput mengisi kotak dan memanggil onCompleted', (WidgetTester tester) async {
    String code = '';
    String? completed;
    await tester.pumpWidget(testApp(StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => IddsOtpInput(
        length: 4,
        value: code,
        onChanged: (String v) => setState(() => code = v),
        onCompleted: (String v) => completed = v,
      ),
    )));
    await tester.enterText(find.byType(EditableText), '12a34');
    await tester.pump();
    expect(code, '1234');
    expect(completed, '1234');
    expect(find.text('3'), findsOneWidget);
  });

  group('IddsTimePicker', () {
    testWidgets('memilih jam dan menit lalu Pilih', (WidgetTester tester) async {
      IddsTime? time;
      await tester.pumpWidget(testApp(SizedBox(
        width: 280,
        child: IddsTimePicker(value: null, minuteStep: 15, onChanged: (IddsTime? t) => time = t),
      )));
      await tester.tap(find.text('Pilih waktu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('02').first);
      await tester.pump();
      await tester.tap(find.text('30'));
      await tester.pump();
      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();
      expect(time, const IddsTime(2, 30));
    });

    testWidgets('format 12 jam dan hapus', (WidgetTester tester) async {
      IddsTime? time = const IddsTime(13, 5);
      await tester.pumpWidget(testApp(SizedBox(
        width: 280,
        child: IddsTimePicker(value: time, use12Hours: true, onChanged: (IddsTime? t) => time = t),
      )));
      expect(find.text('1:05 PM'), findsOneWidget);
      await tester.tap(_icon(IddsIcons.x));
      expect(time, isNull);
    });

    test('IddsTime parse dan format', () {
      expect(IddsTime.tryParse('7:05'), const IddsTime(7, 5));
      expect(IddsTime.tryParse('24:00'), isNull);
      expect(const IddsTime(9, 3, 7).format(showSeconds: true), '09:03:07');
      expect(const IddsTime(0, 15).format(use12Hours: true), '12:15 AM');
    });
  });
}
