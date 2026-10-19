import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

void main() {
  group('IddsAccordion', () {
    testWidgets('membuka dan menutup isi', (WidgetTester tester) async {
      bool? last;
      await tester.pumpWidget(testApp(SizedBox(
        width: 400,
        child: IddsAccordion(
          title: const Text('Syarat pendaftaran'),
          onChanged: (bool v) => last = v,
          child: const Text('KTP dan KK'),
        ),
      )));
      expect(find.text('KTP dan KK'), findsNothing);

      await tester.tap(find.text('Syarat pendaftaran'));
      await tester.pumpAndSettle();
      expect(find.text('KTP dan KK'), findsOneWidget);
      expect(last, isTrue);

      await tester.tap(find.text('Syarat pendaftaran'));
      await tester.pumpAndSettle();
      expect(find.text('KTP dan KK'), findsNothing);
      expect(last, isFalse);
    });

    testWidgets('grup: hanya satu yang terbuka', (WidgetTester tester) async {
      Set<int>? open;
      await tester.pumpWidget(testApp(SizedBox(
        width: 400,
        child: IddsAccordionGroup(
          initiallyOpen: const <int>{0},
          onChanged: (Set<int> v) => open = v,
          items: const <IddsAccordionItem>[
            IddsAccordionItem(title: Text('Satu'), child: Text('Isi satu')),
            IddsAccordionItem(title: Text('Dua'), child: Text('Isi dua')),
            IddsAccordionItem(title: Text('Tiga'), child: Text('Isi tiga'), enabled: false),
          ],
        ),
      )));
      expect(find.text('Isi satu'), findsOneWidget);

      await tester.tap(find.text('Dua'));
      await tester.pumpAndSettle();
      expect(open, <int>{1});
      expect(find.text('Isi satu'), findsNothing);
      expect(find.text('Isi dua'), findsOneWidget);

      await tester.tap(find.text('Tiga'));
      await tester.pumpAndSettle();
      expect(find.text('Isi tiga'), findsNothing);
    });

    testWidgets('accordion kartu', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const SizedBox(
        width: 400,
        child: IddsAccordionCard(title: Text('Rincian biaya'), initiallyOpen: true, child: Text('Gratis')),
      )));
      expect(find.text('Gratis'), findsOneWidget);
      await tester.tap(find.text('Rincian biaya'));
      await tester.pumpAndSettle();
      expect(find.text('Gratis'), findsNothing);
    });
  });

  group('IddsCard', () {
    testWidgets('judul, keterangan, aksi, dan ketukan', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(testApp(SizedBox(
        width: 360,
        child: IddsCard(
          title: const Text('Beasiswa 2026'),
          description: const Text('Pendaftaran dibuka hingga 30 November.'),
          media: const ColoredBox(color: Color(0xFF888888)),
          onTap: () => taps++,
          action: const Text('Daftar'),
        ),
      )));
      expect(find.text('Beasiswa 2026'), findsOneWidget);
      expect(find.text('Daftar'), findsOneWidget);
      await tester.tap(find.text('Beasiswa 2026'));
      expect(taps, 1);
    });

    testWidgets('varian horizontal dan overlay tanpa error tata letak', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const SingleChildScrollView(
        child: Column(
          children: <Widget>[
            IddsCard(
              variant: IddsCardVariant.horizontal,
              title: Text('Horizontal'),
              media: ColoredBox(color: Color(0xFF888888)),
            ),
            IddsCard(
              variant: IddsCardVariant.overlay,
              title: Text('Overlay'),
              description: Text('Teks putih di atas gambar'),
              media: ColoredBox(color: Color(0xFF888888)),
            ),
            IddsCardPlain(child: Text('Polos')),
          ],
        ),
      )));
      expect(tester.takeException(), isNull);
      expect(find.text('Overlay'), findsOneWidget);
      expect(tester.getSize(find.byType(IddsCard).last).height, greaterThanOrEqualTo(362));
    });
  });

  testWidgets('indikator memuat dan divider tampil', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(const SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IddsSpinner(title: 'Memuat data', subtitle: 'Mohon tunggu'),
          IddsProgressBar(value: 0.4),
          IddsProgressBar(),
          IddsCircleProgress(value: 0.7),
          IddsSkeleton(height: 16),
          IddsSkeleton.circle(size: 40),
          IddsDivider(label: Text('atau')),
          SizedBox(height: 20, child: Row(children: <Widget>[IddsDivider.vertical()])),
        ],
      ),
    )));
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    expect(find.text('Memuat data'), findsOneWidget);
    expect(find.text('atau'), findsOneWidget);
    expect(tester.getSize(find.byType(IddsSkeleton).first).width, 300);
    // Animasi berulang: lepaskan widget sebelum test selesai.
    await tester.pumpWidget(const SizedBox());
  });
}
