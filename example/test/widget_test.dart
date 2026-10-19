import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idds_flutter_example/main.dart';

void main() {
  // Test tidak punya akses internet; jangan coba mengunduh font.
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('layar lebar: sidebar dan beranda tampil', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('IDDS Flutter'), findsOneWidget);
    expect(find.text('Distribusi Pengguna'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    await tester.tap(find.text('Button'));
    await tester.pumpAndSettle();
    expect(find.text('Distribusi Pengguna'), findsNothing);
  });

  testWidgets('layar sempit: menu dibuka lewat drawer', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    expect(find.text('IDDS Flutter'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Buka menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grafik'));
    await tester.pumpAndSettle();
    expect(find.text('Kanal pengajuan'), findsOneWidget);
  });

  testWidgets('halaman komponen punya contoh kode yang bisa disalin', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final List<MethodCall> calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Button'));
    await tester.pumpAndSettle();
    expect(find.text('Cara pakai'), findsOneWidget);

    await tester.ensureVisible(find.text('Salin'));
    await tester.tap(find.text('Salin'));
    await tester.pump();
    final MethodCall copy = calls.firstWhere((MethodCall c) => c.method == 'Clipboard.setData');
    expect((copy.arguments as Map<Object?, Object?>)['text'], contains('IddsButton('));
    expect(find.text('Tersalin'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Salin'), findsOneWidget);
  });

  test('URL galeri: /#/button <-> halaman button', () async {
    const GalleryRouteParser parser = GalleryRouteParser();
    expect(await parser.parseRouteInformation(RouteInformation(uri: Uri.parse('/'))), 'home');
    expect(await parser.parseRouteInformation(RouteInformation(uri: Uri.parse('/table'))), 'table');
    expect(parser.restoreRouteInformation('home').uri.path, '/');
    expect(parser.restoreRouteInformation('chart').uri.path, '/chart');
  });

  testWidgets('memilih menu memperbarui halaman di router', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Table'));
    await tester.pumpAndSettle();
    final Router<Object?> router = tester.widget(find.byWidgetPredicate((Widget w) => w is Router));
    expect((router.routerDelegate as GalleryRouterDelegate).currentConfiguration, 'table');
  });
}
