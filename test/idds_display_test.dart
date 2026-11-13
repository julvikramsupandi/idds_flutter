import 'dart:math' as math;

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

    testWidgets('fill brand memakai warna utama brand',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          const IddsBadge(
              type: IddsBadgeType.fill,
              variant: IddsBadgeVariant.brand,
              child: Text('A')),
          theme: IddsThemeData(brand: IddsBrand.bkn),
        ),
      );
      expect(_boxColor(tester, find.byType(IddsBadge)),
          IddsBrand.bkn.primaryMainLight);
    });

    testWidgets('lebar minimal 48px', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsBadge(child: Text('1'))));
      expect(tester.getSize(find.byType(IddsBadge)).width,
          greaterThanOrEqualTo(48));
    });

    testWidgets('tinggi md = 4 + 20 + 4', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsBadge(child: Text('A'))));
      expect(tester.getSize(find.byType(IddsBadge)).height, 28);
    });
  });

  group('IddsAvatar', () {
    testWidgets('inisial maksimal 2 huruf kapital',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsAvatar(initials: 'julvikram')));
      expect(find.text('JU'), findsOneWidget);
    });

    testWidgets('ukuran sesuai enum', (WidgetTester tester) async {
      for (final IddsAvatarSize size in IddsAvatarSize.values) {
        await tester.pumpWidget(testApp(IddsAvatar(initials: 'A', size: size)));
        expect(tester.getSize(find.byType(IddsAvatar)),
            Size.square(size.dimension));
      }
    });
  });

  group('IddsAlert', () {
    // Dark mode: latar gelap bernuansa (bukan *-100 terang), judul dan isi
    // kontras ≥ 4,5:1 (README "Penyesuaian dari IDDS").
    for (final Brightness brightness in Brightness.values) {
      for (final IddsAlertVariant variant in IddsAlertVariant.values) {
        testWidgets('kontras ${variant.name} ${brightness.name}',
            (WidgetTester tester) async {
          final IddsThemeData theme = IddsThemeData(brightness: brightness);
          await tester.pumpWidget(testApp(
            IddsAlert(
                variant: variant,
                title: const Text('Judul'),
                message: const Text('Isi pesan.')),
            theme: theme,
          ));
          final Color background = (tester
                  .widget<Container>(find
                      .descendant(
                          of: find.byType(IddsAlert),
                          matching: find.byType(Container))
                      .first)
                  .decoration! as BoxDecoration)
              .color!;
          Color textColor(String text) => tester
              .widget<RichText>(find
                  .descendant(
                      of: find.text(text), matching: find.byType(RichText))
                  .first)
              .text
              .style!
              .color!;
          double contrast(Color a, Color b) {
            final double la = a.computeLuminance(), lb = b.computeLuminance();
            return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
          }

          expect(contrast(textColor('Judul'), background),
              greaterThanOrEqualTo(4.5));
          expect(contrast(textColor('Isi pesan.'), background),
              greaterThanOrEqualTo(4.5));
          if (brightness == Brightness.dark) {
            // Latar tidak boleh terang di layar gelap.
            expect(background.computeLuminance(), lessThan(0.1));
          }
        });
      }
    }

    testWidgets('menampilkan judul dan pesan', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(const IddsAlert(
            title: Text('Tersimpan'), message: Text('Data sudah disimpan.'))),
      );
      expect(find.text('Tersimpan'), findsOneWidget);
      expect(find.text('Data sudah disimpan.'), findsOneWidget);
      expect(find.byType(IddsIcon), findsOneWidget);
    });

    testWidgets('tombol tutup memanggil onDismiss',
        (WidgetTester tester) async {
      int dismissed = 0;
      await tester.pumpWidget(testApp(
          IddsAlert(title: const Text('Info'), onDismiss: () => dismissed++)));
      await tester.tap(find.bySemanticsLabel('Tutup peringatan'));
      expect(dismissed, 1);
    });

    testWidgets('tanpa onDismiss tidak ada tombol tutup',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsAlert(title: Text('Info'))));
      expect(find.bySemanticsLabel('Tutup peringatan'), findsNothing);
    });

    testWidgets('showIcon: false menyembunyikan ikon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          testApp(const IddsAlert(title: Text('Info'), showIcon: false)));
      expect(find.byType(IddsIcon), findsNothing);
    });

    testWidgets('action tampil di bawah pesan', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsAlert(
        variant: IddsAlertVariant.critical,
        title: Text('Gagal mengirim'),
        message: Text('Server tidak merespons.'),
        action: Text('Coba lagi'),
      )));
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Coba lagi')).dy,
        greaterThan(
            tester.getBottomLeft(find.text('Server tidak merespons.')).dy),
      );
    });

    testWidgets('tombol tutup: area tekan 48dp walau ikon 14px',
        (WidgetTester tester) async {
      int dismissed = 0;
      await tester.pumpWidget(testApp(IddsAlert(
        title: const Text('Info'),
        message:
            const Text('Pesan dua baris agar alert cukup tinggi untuk diuji.'),
        onDismiss: () => dismissed++,
      )));
      final Rect icon = tester.getRect(find.byWidgetPredicate(
          (Widget w) => w is IddsIcon && w.icon == IddsIcons.x));
      await tester.tapAt(icon.center + const Offset(-14, 12));
      expect(dismissed, 1);
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

  testWidgets(
      'judul Alert, Card, dan Toast bisa berupa widget dengan gaya bawaan',
      (WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(testApp(SizedBox(
      width: 400,
      child: Column(
        children: <Widget>[
          const IddsAlert(
            title: Row(children: <Widget>[
              IddsIcon(IddsIcons.clock),
              Text('Judul alert')
            ]),
            message: Text('Isi'),
          ),
          const IddsCard(
            title: Row(children: <Widget>[
              Text('Judul kartu'),
              IddsBadge(child: Text('Baru'))
            ]),
            description: Text('Keterangan'),
          ),
          Builder(builder: (BuildContext context) {
            ctx = context;
            return const SizedBox();
          }),
        ],
      ),
    )));
    showIddsToast(
        context: ctx,
        title: const Text('Judul toast'),
        description: const Text('Isi toast'),
        duration: null);
    await tester.pumpAndSettle();

    FontWeight? weight(String text) =>
        DefaultTextStyle.of(tester.element(find.text(text))).style.fontWeight;
    expect(weight('Judul alert'), FontWeight.w600);
    expect(weight('Judul kartu'), FontWeight.w600);
    expect(weight('Judul toast'), FontWeight.w500);
    expect(find.text('Baru'), findsOneWidget);
    expect(find.text('Isi toast'), findsOneWidget);
    dismissAllIddsToasts(ctx);
    await tester.pumpAndSettle();
  });
}
