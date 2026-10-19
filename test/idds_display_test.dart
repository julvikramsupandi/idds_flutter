import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:idds_flutter/src/foundation/idds_icon.dart' show parseSvgPath;

import 'test_app.dart';

Color? _boxColor(WidgetTester tester, Finder of) {
  final DecoratedBox box = tester.widget<DecoratedBox>(
    find.descendant(of: of, matching: find.byType(DecoratedBox)).first,
  );
  return (box.decoration as BoxDecoration).color;
}

void main() {
  group('IddsBadge', () {
    testWidgets('soft info memakai guide-100', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsBadge(child: Text('Baru'))));
      final IddsColors c = IddsThemeData().colors;
      expect(_boxColor(tester, find.byType(IddsBadge)), c.guide.shade100);
      expect(find.text('Baru'), findsOneWidget);
    });

    testWidgets('fill brand memakai warna utama brand', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          const IddsBadge(type: IddsBadgeType.fill, variant: IddsBadgeVariant.brand, child: Text('A')),
          theme: IddsThemeData(brand: IddsBrand.bkn),
        ),
      );
      expect(_boxColor(tester, find.byType(IddsBadge)), IddsBrand.bkn.primaryMainLight);
    });

    testWidgets('lebar minimal 48px', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsBadge(child: Text('1'))));
      expect(tester.getSize(find.byType(IddsBadge)).width, greaterThanOrEqualTo(48));
    });

    testWidgets('tinggi md = 4 + 20 + 4', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsBadge(child: Text('A'))));
      expect(tester.getSize(find.byType(IddsBadge)).height, 28);
    });
  });

  group('IddsAvatar', () {
    testWidgets('inisial maksimal 2 huruf kapital', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsAvatar(initials: 'julvikram')));
      expect(find.text('JU'), findsOneWidget);
    });

    testWidgets('ukuran sesuai enum', (WidgetTester tester) async {
      for (final IddsAvatarSize size in IddsAvatarSize.values) {
        await tester.pumpWidget(testApp(IddsAvatar(initials: 'A', size: size)));
        expect(tester.getSize(find.byType(IddsAvatar)), Size.square(size.dimension));
      }
    });
  });

  group('IddsAlert', () {
    testWidgets('menampilkan judul dan pesan', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(const IddsAlert(title: Text('Tersimpan'), message: Text('Data sudah disimpan.'))),
      );
      expect(find.text('Tersimpan'), findsOneWidget);
      expect(find.text('Data sudah disimpan.'), findsOneWidget);
      expect(find.byType(IddsIcon), findsOneWidget);
    });

    testWidgets('tombol tutup memanggil onDismiss', (WidgetTester tester) async {
      int dismissed = 0;
      await tester.pumpWidget(testApp(IddsAlert(title: const Text('Info'), onDismiss: () => dismissed++)));
      await tester.tap(find.bySemanticsLabel('Tutup peringatan'));
      expect(dismissed, 1);
    });

    testWidgets('tanpa onDismiss tidak ada tombol tutup', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsAlert(title: Text('Info'))));
      expect(find.bySemanticsLabel('Tutup peringatan'), findsNothing);
    });

    testWidgets('showIcon: false menyembunyikan ikon', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsAlert(title: Text('Info'), showIcon: false)));
      expect(find.byType(IddsIcon), findsNothing);
    });
  });

  group('IddsIcon', () {
    test('semua ikon bawaan bisa di-parse', () {
      for (final IddsIconData icon in <IddsIconData>[
        IddsIcons.check,
        IddsIcons.minus,
        IddsIcons.x,
        IddsIcons.infoCircle,
        IddsIcons.alertCircle,
        IddsIcons.alertTriangle,
        IddsIcons.box,
      ]) {
        for (final String d in icon.paths) {
          expect(parseSvgPath(d).getBounds().isFinite, isTrue, reason: d);
        }
      }
    });
  });

  testWidgets('judul Alert, Card, dan Toast bisa berupa widget dengan gaya bawaan', (WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(testApp(SizedBox(
      width: 400,
      child: Column(
        children: <Widget>[
          const IddsAlert(
            title: Row(children: <Widget>[IddsIcon(IddsIcons.clock), Text('Judul alert')]),
            message: Text('Isi'),
          ),
          const IddsCard(
            title: Row(children: <Widget>[Text('Judul kartu'), IddsBadge(child: Text('Baru'))]),
            description: Text('Keterangan'),
          ),
          Builder(builder: (BuildContext context) {
            ctx = context;
            return const SizedBox();
          }),
        ],
      ),
    )));
    showIddsToast(context: ctx, title: const Text('Judul toast'), description: const Text('Isi toast'), duration: null);
    await tester.pumpAndSettle();

    FontWeight? weight(String text) => DefaultTextStyle.of(tester.element(find.text(text))).style.fontWeight;
    expect(weight('Judul alert'), FontWeight.w600);
    expect(weight('Judul kartu'), FontWeight.w600);
    expect(weight('Judul toast'), FontWeight.w500);
    expect(find.text('Baru'), findsOneWidget);
    expect(find.text('Isi toast'), findsOneWidget);
    dismissAllIddsToasts(ctx);
    await tester.pumpAndSettle();
  });
}
