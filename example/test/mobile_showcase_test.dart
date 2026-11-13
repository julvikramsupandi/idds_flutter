import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idds_flutter_example/main.dart';
import 'package:idds_flutter_example/pages/mobile/phone_frame.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpGallery(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GalleryApp());
    await tester.pumpAndSettle();
  }

  /// Bingkai ke-[index]: 0 Masuk, 1 Beranda, 2 Form Pengajuan.
  Finder frame(int index) => find.byType(PhoneFrame).at(index);

  testWidgets('isi bingkai memakai lebar layar ponsel',
      (WidgetTester tester) async {
    await pumpGallery(tester);
    expect(find.byType(PhoneFrame), findsNWidgets(3));
    final BuildContext inside = tester.element(find.descendant(
        of: frame(0), matching: find.text('Masuk ke akun Anda')));
    expect(MediaQuery.sizeOf(inside).width, PhoneFrame.defaultScreenWidth);
  });

  testWidgets(
      'bottom sheet layanan terbuka di dalam bingkai, lalu membuka form',
      (WidgetTester tester) async {
    await pumpGallery(tester);
    await tester
        .tap(find.descendant(of: frame(1), matching: find.text('KTP-el')));
    await tester.pumpAndSettle();

    final Finder apply = find.text('Ajukan Sekarang');
    expect(apply, findsOneWidget);
    final Rect phone = tester.getRect(frame(1));
    expect(phone.contains(tester.getCenter(apply)), isTrue);

    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(apply, findsNothing);
    expect(
        find.descendant(of: frame(1), matching: find.text('Pengajuan KTP-el')),
        findsOneWidget);

    await tester.tap(find.descendant(
        of: frame(1), matching: find.byIcon(TablerIcons.arrow_left)));
    await tester.pumpAndSettle();
    expect(
        find.descendant(of: frame(1), matching: find.text('Pengajuan KTP-el')),
        findsNothing);
  });

  testWidgets('form pengajuan memvalidasi langkah pertama',
      (WidgetTester tester) async {
    await pumpGallery(tester);
    await tester
        .tap(find.descendant(of: frame(2), matching: find.text('Lanjut')));
    await tester.pump();
    expect(find.text('Nama lengkap wajib diisi'), findsOneWidget);
    expect(find.text('NIK wajib diisi'), findsOneWidget);

    final Finder toast = find.text('Lengkapi data terlebih dahulu');
    await tester.pump(const Duration(milliseconds: 300));
    expect(toast, findsOneWidget);
    expect(tester.getRect(frame(2)).contains(tester.getCenter(toast)), isTrue);

    // Biarkan toast tertutup sendiri agar tidak ada timer tersisa.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
