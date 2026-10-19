import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:idds_flutter/src/foundation/idds_interactive.dart' show IddsInsetRing;

import 'test_app.dart';

const List<IddsSelectOption<String>> _provinces = <IddsSelectOption<String>>[
  IddsSelectOption<String>(value: 'jabar', label: 'Jawa Barat'),
  IddsSelectOption<String>(value: 'jateng', label: 'Jawa Tengah'),
  IddsSelectOption<String>(value: 'jatim', label: 'Jawa Timur'),
  IddsSelectOption<String>(value: 'bali', label: 'Bali', enabled: false),
  IddsSelectOption<String>(value: 'ntb', label: 'Nusa Tenggara Barat'),
];

/// Select terkendali sederhana untuk test.
class _SelectHarness extends StatefulWidget {
  const _SelectHarness({this.searchable = false, this.onChanged});

  final bool searchable;
  final ValueChanged<String?>? onChanged;

  @override
  State<_SelectHarness> createState() => _SelectHarnessState();
}

class _SelectHarnessState extends State<_SelectHarness> {
  String? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: IddsSelect<String>(
        options: _provinces,
        value: value,
        searchable: widget.searchable,
        onChanged: (String? v) {
          setState(() => value = v);
          widget.onChanged?.call(v);
        },
      ),
    );
  }
}

class _MultiHarness extends StatefulWidget {
  const _MultiHarness();

  @override
  State<_MultiHarness> createState() => _MultiHarnessState();
}

class _MultiHarnessState extends State<_MultiHarness> {
  Set<String> values = <String>{};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: IddsMultiSelect<String>(
        options: _provinces,
        values: values,
        showPreview: true,
        onChanged: (Set<String> v) => setState(() => values = v),
      ),
    );
  }
}

void main() {
  group('IddsSelect', () {
    testWidgets('membuka panel, memilih, lalu menutup', (WidgetTester tester) async {
      String? changed;
      await tester.pumpWidget(testApp(_SelectHarness(onChanged: (String? v) => changed = v)));
      expect(find.text('Pilih...'), findsOneWidget);
      expect(find.text('Jawa Tengah'), findsNothing);

      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();
      expect(find.text('Jawa Tengah'), findsOneWidget);

      await tester.tap(find.text('Jawa Tengah'));
      await tester.pumpAndSettle();
      expect(changed, 'jateng');
      // Panel tertutup; label hanya tampil di pemicu.
      expect(find.text('Jawa Tengah'), findsOneWidget);
      expect(find.text('Jawa Barat'), findsNothing);
    });

    testWidgets('opsi nonaktif tidak bisa dipilih', (WidgetTester tester) async {
      String? changed;
      await tester.pumpWidget(testApp(_SelectHarness(onChanged: (String? v) => changed = v)));
      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bali'));
      await tester.pumpAndSettle();
      expect(changed, isNull);
      expect(find.text('Bali'), findsOneWidget);
    });

    testWidgets('menekan di luar dan Esc menutup panel', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const _SelectHarness()));
      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();
      expect(find.text('Jawa Barat'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Jawa Barat'), findsNothing);

      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();
      expect(find.text('Jawa Barat'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Jawa Barat'), findsNothing);
    });

    testWidgets(
      'garis aktif hilang saat menekan di luar setelah panel tertutup',
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      (WidgetTester tester) async {
        bool active() => tester
            .widget<IddsInsetRing>(
              find.descendant(of: find.byType(IddsSelect<String>), matching: find.byType(IddsInsetRing)).first,
            )
            .visible;
        await tester.pumpWidget(testApp(const _SelectHarness()));

        // Pilih opsi: panel tertutup, pemicu tetap aktif (fokus kembali).
        await tester.tap(find.text('Pilih...'), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Jawa Tengah'), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(active(), isTrue);

        // Menekan area kosong melepas fokus.
        await tester.tapAt(const Offset(5, 5), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(active(), isFalse);

        // Menekan di luar saat panel terbuka: panel tertutup dan tidak aktif.
        await tester.tap(find.text('Jawa Tengah'), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(find.text('Jawa Barat'), findsOneWidget);
        await tester.tapAt(const Offset(5, 5), kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(find.text('Jawa Barat'), findsNothing);
        expect(active(), isFalse);
      },
    );

    testWidgets('panah dan Enter memilih opsi', (WidgetTester tester) async {
      String? changed;
      await tester.pumpWidget(testApp(_SelectHarness(onChanged: (String? v) => changed = v)));
      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();
      // Sorotan awal di opsi pertama; dua kali turun = Jawa Timur.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(changed, 'jatim');
    });

    testWidgets('pencarian menyaring opsi dan menampilkan teks kosong', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const _SelectHarness(searchable: true)));
      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'timur');
      await tester.pump();
      expect(find.text('Jawa Timur'), findsOneWidget);
      expect(find.text('Jawa Barat'), findsNothing);

      await tester.enterText(find.byType(EditableText), 'papua');
      await tester.pump();
      expect(find.text('Data tidak ditemukan'), findsOneWidget);
    });

    testWidgets('nonaktif bila onChanged null', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(
        const SizedBox(
          width: 300,
          child: IddsSelect<String>(options: _provinces, value: null, onChanged: null),
        ),
      ));
      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();
      expect(find.text('Jawa Barat'), findsNothing);
    });

    testWidgets('label, tanda wajib, dan pesan error', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(
        SizedBox(
          width: 300,
          child: IddsSelect<String>(
            label: const Text('Provinsi'),
            required: true,
            errorText: 'Wajib diisi',
            options: _provinces,
            value: null,
            onChanged: (_) {},
          ),
        ),
      ));
      expect(find.text('Provinsi'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('Wajib diisi'), findsOneWidget);
    });

    testWidgets('panel pindah ke atas bila ruang di bawah sempit', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 300,
            child: IddsSelect<String>(options: _provinces, value: null, onChanged: (_) {}),
          ),
        ),
      ));
      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();
      final double triggerTop = tester.getTopLeft(find.text('Pilih...')).dy;
      final double optionTop = tester.getTopLeft(find.text('Jawa Barat')).dy;
      expect(optionTop, lessThan(triggerTop));
    });
  });

  group('IddsMultiSelect', () {
    testWidgets('panel tetap terbuka dan teks pemicu mengikuti pilihan', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const _MultiHarness()));
      await tester.tap(find.text('Pilih...'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jawa Barat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jawa Tengah').last);
      await tester.pumpAndSettle();
      expect(find.text('Jawa Barat, Jawa Tengah'), findsOneWidget);
      // Masih terbuka.
      expect(find.text('Jawa Timur'), findsOneWidget);

      await tester.tap(find.text('Jawa Timur').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nusa Tenggara Barat').last);
      await tester.pumpAndSettle();
      expect(find.text('4 data terpilih'), findsOneWidget);
      expect(find.text('+1 lainnya'), findsOneWidget);

      // Menekan opsi terpilih menghapusnya.
      await tester.tap(find.text('Nusa Tenggara Barat').last);
      await tester.pumpAndSettle();
      expect(find.text('Jawa Barat, Jawa Tengah, Jawa Timur'), findsOneWidget);
    });
  });

  group('IddsActionMenu', () {
    testWidgets('menjalankan aksi lalu menutup', (WidgetTester tester) async {
      int edits = 0;
      await tester.pumpWidget(testApp(
        IddsActionMenu(
          items: <IddsActionMenuEntry>[
            const IddsActionMenuHeader('Data'),
            IddsActionMenuItem(label: 'Ubah', onTap: () => edits++),
            const IddsActionMenuItem(label: 'Arsipkan', onTap: null),
            const IddsActionMenuDivider(),
            IddsActionMenuItem(label: 'Hapus', onTap: () {}, type: IddsActionMenuItemType.danger),
          ],
        ),
      ));
      expect(find.text('Ubah'), findsNothing);
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      expect(find.text('DATA'), findsOneWidget);

      await tester.tap(find.text('Arsipkan'));
      await tester.pumpAndSettle();
      expect(find.text('Arsipkan'), findsOneWidget);

      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();
      expect(edits, 1);
      expect(find.text('Ubah'), findsNothing);
    });

    testWidgets('navigasi keyboard melewati aksi nonaktif', (WidgetTester tester) async {
      String? last;
      await tester.pumpWidget(testApp(
        IddsActionMenu(
          items: <IddsActionMenuEntry>[
            IddsActionMenuItem(label: 'Satu', onTap: () => last = 'satu'),
            const IddsActionMenuItem(label: 'Dua', onTap: null),
            IddsActionMenuItem(label: 'Tiga', onTap: () => last = 'tiga'),
          ],
        ),
      ));
      await tester.tap(find.text('Aksi'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(last, 'tiga');
    });
  });

  testWidgets('IddsDropdown terkendali sendiri', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(
      IddsDropdown(
        triggerBuilder: (BuildContext context, bool open, VoidCallback? toggle) => GestureDetector(
          onTap: toggle,
          child: Text(open ? 'Tutup' : 'Buka'),
        ),
        contentBuilder: (BuildContext context, VoidCallback close) => GestureDetector(
          onTap: close,
          child: const Text('Isi panel'),
        ),
      ),
    ));
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(find.text('Isi panel'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    await tester.tap(find.text('Isi panel'));
    await tester.pumpAndSettle();
    expect(find.text('Isi panel'), findsNothing);
  });

  testWidgets('IddsPagination menampilkan pilihan jumlah baris', (WidgetTester tester) async {
    int? size;
    await tester.pumpWidget(testApp(
      IddsPagination(
        currentPage: 1,
        totalPages: 5,
        onPageChanged: (_) {},
        pageSize: 10,
        onPageSizeChanged: (int v) => size = v,
      ),
    ));
    expect(find.text('Baris per halaman'), findsOneWidget);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('50'));
    await tester.pumpAndSettle();
    expect(size, 50);
  });
}
