import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

Finder _icon(IddsIconData data) => find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == data);

void main() {
  group('iddsFormatFileSize / iddsValidateFile', () {
    test('format ukuran seperti versi web', () {
      expect(iddsFormatFileSize(0), '0 Bytes');
      expect(iddsFormatFileSize(512), '512 Bytes');
      expect(iddsFormatFileSize(1536), '1.5 KB');
      expect(iddsFormatFileSize(2 * 1024 * 1024), '2 MB');
      expect(iddsFormatFileSize(2359296), '2.25 MB');
    });

    test('validasi nama, ekstensi, dan ukuran', () {
      expect(iddsValidateFile(name: 'ktp.pdf', size: 1000, allowedExtensions: <String>['pdf']), isNull);
      expect(
        iddsValidateFile(name: 'ktp.exe', size: 1000, allowedExtensions: <String>['pdf', '.png']),
        'Ekstensi file harus: pdf, png',
      );
      expect(iddsValidateFile(name: 'a.pdf', size: 3 * 1048576, maxSize: 2 * 1048576), 'Ukuran file maksimal 2.00 MB');
      expect(iddsValidateFile(name: 'a<b>.pdf', size: 1), 'Nama file mengandung karakter yang tidak diizinkan');
    });
  });

  group('IddsFileUpload', () {
    testWidgets('menekan area memanggil onPick; nonaktif bila null', (WidgetTester tester) async {
      int picks = 0;
      await tester.pumpWidget(testApp(SizedBox(width: 500, child: IddsFileUpload(files: const <IddsUploadFile>[], onPick: () => picks++))));
      expect(find.text('Unggah File'), findsOneWidget);
      await tester.tap(find.text('Pilih File'));
      await tester.tap(find.text('Unggah File'));
      expect(picks, 2);

      await tester.pumpWidget(testApp(const SizedBox(width: 500, child: IddsFileUpload(files: <IddsUploadFile>[], onPick: null))));
      await tester.tap(find.text('Pilih File'));
      expect(picks, 2);
    });

    testWidgets('status berkas dan aksinya', (WidgetTester tester) async {
      final List<String> log = <String>[];
      await tester.pumpWidget(testApp(SizedBox(
        width: 500,
        child: IddsFileUpload(
          onPick: () {},
          onRemove: (int i) => log.add('hapus $i'),
          onRetry: (int i) => log.add('ulang $i'),
          onCancel: (int i) => log.add('batal $i'),
          files: const <IddsUploadFile>[
            IddsUploadFile(name: 'ktp.pdf', size: 1536, status: IddsFileStatus.success),
            IddsUploadFile(name: 'kk.pdf', size: 2048, status: IddsFileStatus.uploading, progress: 0.4),
            IddsUploadFile(name: 'foto.png', size: 10, status: IddsFileStatus.error, error: 'Gagal mengunggah'),
          ],
        ),
      )));
      expect(find.text('ktp.pdf'), findsOneWidget);
      expect(find.text('1.5 KB'), findsOneWidget);
      expect(find.text('2 KB · 40%'), findsOneWidget);
      expect(find.text('Gagal mengunggah'), findsOneWidget);

      await tester.tap(_icon(IddsIcons.trash).first);
      await tester.tap(_icon(IddsIcons.x));
      await tester.tap(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.refresh).last);
      await tester.tap(_icon(IddsIcons.trash).last);
      expect(log, <String>['hapus 0', 'batal 1', 'ulang 2', 'hapus 2']);
      // Spinner berputar terus; hentikan sebelum test selesai.
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('lebih dari 5 berkas disembunyikan', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: IddsFileUpload(
            onPick: () {},
            files: <IddsUploadFile>[
              for (int i = 1; i <= 7; i++) IddsUploadFile(name: 'berkas$i.pdf', size: 100, status: IddsFileStatus.success),
            ],
            errors: const <String>['Maksimal 7 file yang dapat diupload'],
          ),
        ),
      )));
      expect(find.text('berkas5.pdf'), findsOneWidget);
      expect(find.text('berkas6.pdf'), findsNothing);
      expect(find.text('Maksimal 7 file yang dapat diupload'), findsOneWidget);
      await tester.ensureVisible(find.text('Lihat Selengkapnya'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lihat Selengkapnya'));
      await tester.pumpAndSettle();
      expect(find.text('berkas7.pdf'), findsOneWidget);
      expect(find.text('Sembunyikan'), findsOneWidget);
    });
  });

  group('IddsSingleFileUpload', () {
    testWidgets('kosong, mengunggah, dan berhasil', (WidgetTester tester) async {
      int picks = 0;
      int removes = 0;
      Widget build(IddsUploadFile? file) => testApp(IddsSingleFileUpload(
            file: file,
            onPick: () => picks++,
            onRemove: () => removes++,
          ));

      await tester.pumpWidget(build(null));
      await tester.tap(find.text('Unggah File'));
      expect(picks, 1);

      await tester.pumpWidget(build(const IddsUploadFile(name: 'ktp.pdf', size: 1, status: IddsFileStatus.uploading, progress: 0.75)));
      await tester.pumpAndSettle();
      expect(find.text('75%'), findsOneWidget);

      await tester.pumpWidget(build(const IddsUploadFile(name: 'ktp.pdf', size: 1, status: IddsFileStatus.success)));
      await tester.pumpAndSettle();
      expect(find.text('ktp.pdf'), findsOneWidget);
      // Sudah ada berkas: menekan kotak tidak membuka pemilih.
      await tester.tap(find.text('ktp.pdf'));
      expect(picks, 1);
      await tester.tap(_icon(IddsIcons.trash));
      expect(removes, 1);
    });

    testWidgets('pesan error menggantikan keterangan', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(IddsSingleFileUpload(
        file: const IddsUploadFile(name: 'a.exe', size: 1, status: IddsFileStatus.error, error: 'Ekstensi file harus: pdf'),
        onPick: () {},
      )));
      expect(find.text('Ekstensi file harus: pdf'), findsOneWidget);
      expect(find.text('Unggah File'), findsOneWidget);
    });
  });
}
