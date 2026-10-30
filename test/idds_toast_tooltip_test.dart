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
        replaceExisting: false,
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

  group('showIddsToast (mobile & aturan IDDS)', () {
    Future<BuildContext> pumpHost(WidgetTester tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(testApp(Builder(builder: (BuildContext context) {
        ctx = context;
        return const SizedBox();
      })));
      return ctx;
    }

    testWidgets('bawaan: toast baru menggantikan yang lama (maksimal satu)', (WidgetTester tester) async {
      final BuildContext ctx = await pumpHost(tester);
      int closed = 0;
      showIddsToast(context: ctx, title: const Text('Satu'), duration: null, onClose: () => closed++);
      await tester.pumpAndSettle();
      showIddsToast(context: ctx, title: const Text('Dua'), duration: null);
      await tester.pumpAndSettle();
      expect(find.text('Satu'), findsNothing);
      expect(find.text('Dua'), findsOneWidget);
      expect(closed, 1);
      dismissAllIddsToasts(ctx);
      await tester.pumpAndSettle();
    });

    testWidgets('context di atas overlay (Navigator root) tetap bisa', (WidgetTester tester) async {
      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(WidgetsApp(
        color: const Color(0xFF000000),
        navigatorKey: navigatorKey,
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
            PageRouteBuilder<T>(settings: settings, pageBuilder: (BuildContext context, _, __) => builder(context)),
        home: const SizedBox(),
      ));
      showIddsToast(context: navigatorKey.currentContext!, title: const Text('Dari navigator'), duration: null);
      await tester.pumpAndSettle();
      expect(find.text('Dari navigator'), findsOneWidget);
      dismissAllIddsToasts(navigatorKey.currentContext!);
      await tester.pumpAndSettle();
      expect(find.text('Dari navigator'), findsNothing);
    });

    testWidgets('tombol X: area tekan 48dp walau ikon 16px', (WidgetTester tester) async {
      final BuildContext ctx = await pumpHost(tester);
      final IddsToastController toast = showIddsToast(context: ctx, title: const Text('OK'), duration: null);
      await tester.pumpAndSettle();
      final Rect icon = tester.getRect(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.x));
      // 14px di kiri ikon: di luar ikon, di dalam area 48dp.
      await tester.tapAt(icon.centerLeft - const Offset(14, 0));
      await tester.pumpAndSettle();
      expect(toast.isOpen, isFalse);
    });

    testWidgets('geser ke atas menutup toast', (WidgetTester tester) async {
      final BuildContext ctx = await pumpHost(tester);
      final IddsToastController toast = showIddsToast(context: ctx, title: const Text('Geser'), duration: null);
      await tester.pumpAndSettle();
      await tester.fling(find.text('Geser'), const Offset(0, -200), 1000);
      await tester.pumpAndSettle();
      expect(toast.isOpen, isFalse);
      expect(find.text('Geser'), findsNothing);
    });

    testWidgets('pembaca layar: tampil lebih lama; dengan aksi tidak tertutup sendiri', (WidgetTester tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(testApp(Builder(builder: (BuildContext context) {
        ctx = context;
        return const SizedBox();
      })));
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(accessibleNavigation: true),
        child: testApp(Builder(builder: (BuildContext context) {
          ctx = context;
          return const SizedBox();
        })),
      ));
      showIddsToast(context: ctx, title: const Text('Lama'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('Lama'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Lama'), findsNothing);

      final IddsToastController withAction = showIddsToast(
        context: ctx,
        title: const Text('Ada aksi'),
        action: const Text('Ulangi'),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 30));
      expect(withAction.isOpen, isTrue);
      withAction.close();
      await tester.pumpAndSettle();
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
