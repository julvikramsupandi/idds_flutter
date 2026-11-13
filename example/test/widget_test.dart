import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idds_flutter_example/main.dart';

void main() {
  // Test tidak punya akses internet; jangan coba mengunduh font.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('layar lebar: sidebar dan beranda tampil',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('IDDS Flutter'), findsOneWidget);
    // Beranda membuka tab Mobile lebih dulu.
    expect(find.text('Masuk ke akun Anda'), findsOneWidget);
    expect(find.text('Distribusi Pengguna'), findsNothing);

    await tester.tap(find.text('Web'));
    await tester.pumpAndSettle();
    expect(find.text('Distribusi Pengguna'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    await tester.tap(find.text('Button'));
    await tester.pumpAndSettle();
    expect(find.text('Distribusi Pengguna'), findsNothing);
  });

  testWidgets('layar sempit: menu dibuka lewat drawer',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('IDDS Flutter'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Buka menu'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Grafik'));
    await tester.tap(find.text('Grafik'));
    await tester.pumpAndSettle();
    expect(find.text('Kanal pengajuan'), findsOneWidget);
  });

  testWidgets('halaman komponen punya contoh kode yang bisa disalin',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final List<MethodCall> calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (MethodCall call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Button'));
    await tester.pumpAndSettle();
    expect(find.text('Cara pakai'), findsOneWidget);

    await tester.ensureVisible(find.text('Salin'));
    await tester.tap(find.text('Salin'));
    await tester.pump();
    final MethodCall copy =
        calls.firstWhere((MethodCall c) => c.method == 'Clipboard.setData');
    expect((copy.arguments as Map<Object?, Object?>)['text'],
        contains('IddsButton('));
    expect(find.text('Tersalin'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Salin'), findsOneWidget);
  });

  test('URL galeri: /#/button <-> halaman button', () async {
    const GalleryRouteParser parser = GalleryRouteParser();
    expect(
        await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/'))),
        'home');
    expect(
        await parser
            .parseRouteInformation(RouteInformation(uri: Uri.parse('/table'))),
        'table');
    expect(parser.restoreRouteInformation('home').uri.path, '/');
    expect(parser.restoreRouteInformation('chart').uri.path, '/chart');
  });

  testWidgets('memilih menu memperbarui halaman di router',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Table'));
    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    final Router<Object?> router =
        tester.widget(find.byWidgetPredicate((Widget w) => w is Router));
    expect(
        (router.routerDelegate as GalleryRouterDelegate).currentConfiguration,
        'table');
  });

  testWidgets('HP: menu tampil sebagai drawer samping, bukan panel bawah',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Buka menu'));
    await tester.pumpAndSettle();

    final Rect title = tester.getRect(find.text('idds_flutter'));
    expect(title.left, lessThan(40));
    // Panel bawah IDDS dimulai sekitar setengah layar; drawer samping di atas.
    expect(title.top, lessThan(100));
  });

  testWidgets('pencarian menu menyaring komponen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('Checkbox'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).first, 'toast');
    await tester.pumpAndSettle();
    expect(find.text('Toast'), findsOneWidget);
    expect(find.text('Checkbox'), findsNothing);

    await tester.enterText(find.byType(EditableText).first, 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada komponen "zzz".'), findsOneWidget);
  });

  testWidgets('alamat halaman gabungan lama dialihkan ke komponen pertamanya',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    final Router<Object?> router =
        tester.widget(find.byWidgetPredicate((Widget w) => w is Router));
    (router.routerDelegate as GalleryRouterDelegate).go('content');
    await tester.pumpAndSettle();
    expect(find.text('Siapa yang bisa mendaftar?'), findsOneWidget);
  });

  for (final Size size in <Size>[
    const Size(1440, 1000),
    const Size(390, 844)
  ]) {
    testWidgets(
        'semua halaman komponen tampil tanpa error (${size.width.toInt()}px)',
        (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const GalleryApp());
      await tester.pumpAndSettle();
      final Router<Object?> router =
          tester.widget(find.byWidgetPredicate((Widget w) => w is Router));
      final GalleryRouterDelegate delegate =
          router.routerDelegate as GalleryRouterDelegate;
      for (final String id in _pageIds) {
        delegate.go(id);
        // Spinner/progress tak tentu beranimasi terus; tunggu durasi tetap.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: 'halaman $id');
        expect(find.text('Cara pakai'), findsWidgets, reason: 'halaman $id');
      }
    });
  }
}

/// Semua halaman komponen (selain Beranda dan Brand & Warna).
const List<String> _pageIds = <String>[
  'button',
  'button-group',
  'action-menu',
  'text-field',
  'text-area',
  'password',
  'search',
  'phone',
  'otp',
  'checkbox',
  'radio',
  'toggle',
  'select',
  'dropdown',
  'upload',
  'date',
  'calendar',
  'time',
  'month-year',
  'avatar',
  'badge',
  'card',
  'list',
  'accordion',
  'divider',
  'table',
  'chart',
  'alert',
  'toast',
  'tooltip',
  'modal',
  'drawer',
  'bottom-sheet',
  'loading',
  'tab',
  'stepper',
  'breadcrumb',
  'pagination',
  'chip',
  'choice-grid',
  'theme-toggle',
];
