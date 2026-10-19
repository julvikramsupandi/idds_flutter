import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

/// Aplikasi dengan Navigator; IddsTheme sengaja hanya membungkus halaman
/// untuk memastikan tema ikut terbawa ke modal.
Widget _app(Widget Function(BuildContext context) home) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
        PageRouteBuilder<T>(settings: settings, pageBuilder: (BuildContext c, _, __) => builder(c)),
    home: IddsTheme(data: IddsThemeData(), child: Builder(builder: home)),
  );
}

Finder _closeIcon() => find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.x);

void main() {
  group('showIddsModal', () {
    testWidgets('menampilkan judul, isi, dan aksi; mengembalikan hasil', (WidgetTester tester) async {
      Future<bool?>? result;
      await tester.pumpWidget(_app((BuildContext context) => Center(
            child: GestureDetector(
              onTap: () => result = showIddsModal<bool>(
                context: context,
                builder: (BuildContext context) => IddsModal(
                  title: const Text('Hapus dokumen?'),
                  actions: <Widget>[
                    IddsButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                  ],
                  child: const Text('Tidak bisa dikembalikan.'),
                ),
              ),
              child: const Text('Buka'),
            ),
          )));
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus dokumen?'), findsOneWidget);
      expect(find.text('Tidak bisa dikembalikan.'), findsOneWidget);

      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
      expect(find.text('Hapus dokumen?'), findsNothing);
    });

    testWidgets('tombol X, Esc, dan latar menutup modal', (WidgetTester tester) async {
      await tester.pumpWidget(_app((BuildContext context) => Center(
            child: GestureDetector(
              onTap: () => showIddsModal<void>(
                context: context,
                builder: (BuildContext context) => const IddsModal(title: Text('Info'), child: Text('Isi')),
              ),
              child: const Text('Buka'),
            ),
          )));

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      await tester.tap(_closeIcon());
      await tester.pumpAndSettle();
      expect(find.text('Info'), findsNothing);

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Info'), findsNothing);

      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Info'), findsNothing);
    });

    testWidgets('barrierDismissible false: latar tidak menutup', (WidgetTester tester) async {
      await tester.pumpWidget(_app((BuildContext context) => Center(
            child: GestureDetector(
              onTap: () => showIddsModal<void>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => const IddsModal(title: Text('Info'), child: Text('Isi')),
              ),
              child: const Text('Buka'),
            ),
          )));
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Info'), findsOneWidget);
    });

    testWidgets('lebar mengikuti ukuran dan layar', (WidgetTester tester) async {
      await tester.pumpWidget(_app((BuildContext context) => Center(
            child: GestureDetector(
              onTap: () => showIddsModal<void>(
                context: context,
                builder: (BuildContext context) => const IddsModal(
                  size: IddsModalSize.lg,
                  title: Text('Lebar'),
                  child: SizedBox(height: 40),
                ),
              ),
              child: const Text('Buka'),
            ),
          )));
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      // Layar test 800px: 800 - 2 × 16 = 768px.
      final double width = tester.getSize(find.ancestor(of: find.text('Lebar'), matching: find.byType(ClipRRect)).first).width;
      expect(width, lessThanOrEqualTo(768));
      expect(width, greaterThan(700));
    });
  });

  group('showIddsDrawer', () {
    Widget drawerApp(IddsDrawerPosition position) => _app((BuildContext context) => Center(
          child: GestureDetector(
            onTap: () => showIddsDrawer<void>(
              context: context,
              position: position,
              builder: (BuildContext context) => IddsDrawer(
                title: const Text('Filter'),
                actions: <Widget>[
                  IddsButton(onPressed: () => Navigator.pop(context), child: const Text('Terapkan')),
                ],
                child: const Text('Isi filter'),
              ),
            ),
            child: const Text('Buka'),
          ),
        ));

    testWidgets('judul bisa berupa widget (ikon + teks) dan mendapat gaya judul', (WidgetTester tester) async {
      await tester.pumpWidget(_app((BuildContext context) => Center(
            child: GestureDetector(
              onTap: () => showIddsDrawer<void>(
                context: context,
                builder: (BuildContext context) => const IddsDrawer(
                  title: Row(
                    spacing: 8,
                    children: <Widget>[IddsIcon(IddsIcons.calendar), Text('Jadwal')],
                  ),
                  child: Text('Isi'),
                ),
              ),
              child: const Text('Buka'),
            ),
          )));
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.calendar), findsOneWidget);
      final TextStyle style = DefaultTextStyle.of(tester.element(find.text('Jadwal'))).style;
      expect(style.fontWeight, FontWeight.w600);
    });

    testWidgets('drawer kanan menempel di tepi kanan', (WidgetTester tester) async {
      await tester.pumpWidget(drawerApp(IddsDrawerPosition.right));
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      expect(find.text('Filter'), findsOneWidget);
      final Rect title = tester.getRect(find.text('Filter'));
      expect(title.left, greaterThan(800 - 420 - 1));

      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();
      expect(find.text('Filter'), findsNothing);
    });

    testWidgets('layar kecil: drawer kanan tampil dari bawah', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(drawerApp(IddsDrawerPosition.right));
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      final Rect title = tester.getRect(find.text('Filter'));
      expect(title.left, lessThan(40));
      expect(title.top, greaterThan(800 * 0.5));

      await tester.tap(_closeIcon());
      await tester.pumpAndSettle();
      expect(find.text('Filter'), findsNothing);
    });

    testWidgets('drawer atas', (WidgetTester tester) async {
      await tester.pumpWidget(drawerApp(IddsDrawerPosition.top));
      await tester.tap(find.text('Buka'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('Filter')).top, lessThan(40));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Filter'), findsNothing);
    });
  });
}
