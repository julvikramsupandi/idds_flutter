import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

void main() {
  group('showIddsToast', () {
    testWidgets('tampil lalu hilang otomatis', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(Builder(
        builder: (BuildContext context) => GestureDetector(
          onTap: () => showIddsToast(context: context, title: const Text('Data tersimpan'), description: const Text('Perubahan sudah disimpan.')),
          child: const Text('Simpan'),
        ),
      )));
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.text('Data tersimpan'), findsOneWidget);
      expect(find.text('Perubahan sudah disimpan.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Data tersimpan'), findsNothing);
    });

    testWidgets('tombol X rata kanan walau judul pendek', (WidgetTester tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(testApp(Builder(builder: (BuildContext context) {
        ctx = context;
        return const SizedBox();
      })));
      final IddsToastController toast = showIddsToast(context: ctx, title: const Text('OK'), duration: null);
      await tester.pumpAndSettle();
      final Finder close = find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.x);
      final Rect box = tester.getRect(find.ancestor(of: close, matching: find.byType(IntrinsicWidth)));
      final Rect icon = tester.getRect(close);
      expect(box.width, greaterThanOrEqualTo(358));
      // Padding 16px + 2px area tekan.
      expect(box.right - icon.right, lessThanOrEqualTo(19));
      toast.close();
      await tester.pumpAndSettle();
    });

    testWidgets('tombol tutup, controller, dan tumpukan', (WidgetTester tester) async {
      late BuildContext ctx;
      int closed = 0;
      await tester.pumpWidget(testApp(Builder(builder: (BuildContext context) {
        ctx = context;
        return const SizedBox();
      })));

      showIddsToast(context: ctx, title: const Text('Satu'), duration: null, onClose: () => closed++);
      final IddsToastController second = showIddsToast(
        context: ctx,
        title: const Text('Dua'),
        duration: null,
        state: IddsToastState.destructive,
        style: IddsToastStyle.outline,
        position: IddsToastPosition.bottomCenter,
      );
      await tester.pumpAndSettle();
      expect(find.text('Satu'), findsOneWidget);
      expect(find.text('Dua'), findsOneWidget);
      // Posisi atas kanan vs bawah tengah.
      expect(tester.getTopLeft(find.text('Satu')).dy, lessThan(tester.getTopLeft(find.text('Dua')).dy));

      await tester.tap(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.x).first);
      await tester.pumpAndSettle();
      expect(find.text('Satu'), findsNothing);
      expect(closed, 1);

      expect(second.isOpen, isTrue);
      second.close();
      await tester.pumpAndSettle();
      expect(find.text('Dua'), findsNothing);
      expect(second.isOpen, isFalse);
    });
  });

  group('IddsTooltip', () {
    testWidgets('muncul saat disorot mouse dan hilang saat keluar', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsTooltip(message: 'Unduh dokumen', child: Text('Unduh'))));
      expect(find.text('Unduh dokumen'), findsNothing);

      final TestGesture mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Unduh')));
      await tester.pumpAndSettle();
      expect(find.text('Unduh dokumen'), findsOneWidget);
      // Tooltip di atas widget.
      expect(tester.getBottomLeft(find.text('Unduh dokumen')).dy, lessThan(tester.getTopLeft(find.text('Unduh')).dy));

      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(find.text('Unduh dokumen'), findsNothing);
    });

    testWidgets('tekan lama di layar sentuh', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsTooltip(
        message: 'Info',
        placement: IddsTooltipPlacement.bottom,
        child: Text('Ikon'),
      )));
      await tester.longPress(find.text('Ikon'));
      await tester.pumpAndSettle();
      expect(find.text('Info'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Info')).dy, greaterThan(tester.getBottomLeft(find.text('Ikon')).dy));

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Info'), findsNothing);
    });

    testWidgets('kartu dengan tombol Lanjut', (WidgetTester tester) async {
      int next = 0;
      await tester.pumpWidget(testApp(IddsTooltip(
        variant: IddsTooltipVariant.dark,
        title: 'Fitur baru',
        description: 'Ekspor laporan ke PDF.',
        onNext: () => next++,
        onClose: () {},
        child: const Text('Laporan'),
      )));
      await tester.longPress(find.text('Laporan'));
      await tester.pumpAndSettle();
      expect(find.text('Fitur baru'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();
      expect(next, 1);
      expect(find.text('Fitur baru'), findsNothing);
    });
  });
}
