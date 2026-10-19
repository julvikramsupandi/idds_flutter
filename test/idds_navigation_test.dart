import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

void main() {
  group('IddsChipGroup', () {
    const List<IddsChipOption<String>> options = <IddsChipOption<String>>[
      IddsChipOption<String>(value: 'a', label: 'Satu'),
      IddsChipOption<String>(value: 'b', label: 'Dua'),
      IddsChipOption<String>(value: 'c', label: 'Tiga', enabled: false),
    ];

    testWidgets('satu pilihan: memilih dan membatalkan', (WidgetTester tester) async {
      Set<String>? result;
      await tester.pumpWidget(
        testApp(IddsChipGroup<String>(options: options, selected: const <String>{'a'}, onChanged: (Set<String> v) => result = v)),
      );
      await tester.tap(find.text('Dua'));
      expect(result, <String>{'b'});
      await tester.tap(find.text('Satu'));
      expect(result, isEmpty);
    });

    testWidgets('banyak pilihan menambah ke himpunan', (WidgetTester tester) async {
      Set<String>? result;
      await tester.pumpWidget(
        testApp(
          IddsChipGroup<String>(
            options: options,
            multiple: true,
            selected: const <String>{'a'},
            onChanged: (Set<String> v) => result = v,
          ),
        ),
      );
      await tester.tap(find.text('Dua'));
      expect(result, <String>{'a', 'b'});
    });

    testWidgets('pilihan nonaktif diabaikan', (WidgetTester tester) async {
      Set<String>? result;
      await tester.pumpWidget(
        testApp(IddsChipGroup<String>(options: options, selected: const <String>{}, onChanged: (Set<String> v) => result = v)),
      );
      await tester.tap(find.text('Tiga'), warnIfMissed: false);
      expect(result, isNull);
    });

    testWidgets('chip selebar isinya, tinggi sesuai ukuran', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(IddsChip(label: const Text('A'), selected: false, onPressed: () {})));
      final Size size = tester.getSize(find.byType(IddsChip));
      expect(size.height, 32);
      expect(size.width, lessThan(100));
    });
  });

  group('IddsButtonGroup', () {
    testWidgets('memilih segmen', (WidgetTester tester) async {
      int? result;
      await tester.pumpWidget(
        testApp(
          IddsButtonGroup<int>(
            value: 1,
            onChanged: (int v) => result = v,
            options: const <IddsButtonGroupOption<int>>[
              IddsButtonGroupOption<int>(value: 1, label: Text('Harian')),
              IddsButtonGroupOption<int>(value: 2, label: Text('Bulanan')),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Bulanan'));
      expect(result, 2);
    });
  });

  group('IddsBreadcrumb', () {
    testWidgets('langkah sebelumnya bisa ditekan, langkah terakhir tidak', (WidgetTester tester) async {
      int home = 0;
      int last = 0;
      await tester.pumpWidget(
        testApp(
          IddsBreadcrumb(
            maxLength: 5,
            items: <IddsBreadcrumbItem>[
              IddsBreadcrumbItem(label: 'Beranda', onTap: () => home++),
              IddsBreadcrumbItem(label: 'Beasiswa Gorontalo', onTap: () => last++),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Beranda'));
      expect(home, 1);
      expect(find.text('Beasi...'), findsOneWidget);
      await tester.tap(find.text('Beasi...'));
      expect(last, 0);
    });
  });

  group('IddsTabMenu', () {
    const List<IddsTabItem<String>> items = <IddsTabItem<String>>[
      IddsTabItem<String>(value: 'a', label: Text('Profil')),
      IddsTabItem<String>(value: 'b', label: Text('Dokumen')),
      IddsTabItem<String>(value: 'c', label: Text('Arsip'), enabled: false),
    ];

    for (final Axis direction in Axis.values) {
      for (final IddsTabVariant variant in IddsTabVariant.values) {
        testWidgets('${direction.name} ${variant.name}: memilih tab', (WidgetTester tester) async {
          String? result;
          await tester.pumpWidget(
            testApp(
              IddsTabMenu<String>(
                items: items,
                value: 'a',
                direction: direction,
                variant: variant,
                onChanged: (String v) => result = v,
              ),
            ),
          );
          await tester.tap(find.text('Dokumen'));
          expect(result, 'b');
          await tester.tap(find.text('Arsip'), warnIfMissed: false);
          expect(result, 'b');
        });
      }
    }

    testWidgets('fullWidth membagi rata lebar', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          SizedBox(
            width: 600,
            child: IddsTabMenu<String>(items: items, value: 'a', fullWidth: true, onChanged: (_) {}),
          ),
        ),
      );
      expect(tester.getSize(find.byType(IddsTabMenu<String>)).width, 600);
    });
  });

  group('IddsStepper', () {
    const List<IddsStep> steps = <IddsStep>[
      IddsStep(label: 'Data diri'),
      IddsStep(label: 'Dokumen'),
      IddsStep(label: 'Konfirmasi'),
    ];

    testWidgets('langkah selesai menampilkan centang, sisanya nomor', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const SizedBox(width: 600, child: IddsStepper(steps: steps, currentStep: 1))));
      expect(find.byType(IddsIcon), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('onStepTap mengirim indeks', (WidgetTester tester) async {
      int? tapped;
      await tester.pumpWidget(
        testApp(
          IddsStepper(
            steps: steps,
            currentStep: 0,
            direction: Axis.vertical,
            onStepTap: (int i) => tapped = i,
          ),
        ),
      );
      await tester.tap(find.text('Konfirmasi'));
      expect(tapped, 2);
    });
  });

  group('IddsPagination', () {
    test('nomor halaman yang tampil', () {
      expect(IddsPagination.visiblePages(1, 10), <int>[1, 2, 3]);
      expect(IddsPagination.visiblePages(5, 10), <int>[4, 5, 6]);
      expect(IddsPagination.visiblePages(10, 10), <int>[8, 9, 10]);
      expect(IddsPagination.visiblePages(1, 2), <int>[1, 2]);
    });

    testWidgets('tombol navigasi', (WidgetTester tester) async {
      int? page;
      await tester.pumpWidget(
        testApp(IddsPagination(currentPage: 5, totalPages: 10, onPageChanged: (int p) => page = p)),
      );
      await tester.tap(find.bySemanticsLabel('Halaman berikutnya'));
      expect(page, 6);
      await tester.tap(find.bySemanticsLabel('Halaman terakhir'));
      expect(page, 10);
      await tester.tap(find.bySemanticsLabel('Halaman 4'));
      expect(page, 4);
    });

    testWidgets('mengisi nomor halaman lalu Enter', (WidgetTester tester) async {
      int? page;
      await tester.pumpWidget(
        testApp(IddsPagination(currentPage: 1, totalPages: 10, onPageChanged: (int p) => page = p)),
      );
      await tester.enterText(find.byType(EditableText), '99');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(page, 10);
    });

    testWidgets('totalPages 0 tidak menampilkan apa-apa', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(IddsPagination(currentPage: 1, totalPages: 0, onPageChanged: (_) {})));
      expect(find.text('Halaman'), findsNothing);
    });
  });

  group('IddsChipGroup kustomisasi', () {
    const List<IddsChipOption<int>> dayOptions = <IddsChipOption<int>>[
      IddsChipOption<int>(value: 7, label: '7 hari'),
      IddsChipOption<int>(value: 30, label: '30 hari'),
    ];

    testWidgets('mengisi nilai kustom lalu Enter', (WidgetTester tester) async {
      Set<int>? result;
      await tester.pumpWidget(testApp(
        SizedBox(
          width: 600,
          child: IddsChipGroup<int>(
            options: dayOptions,
            selected: const <int>{7},
            onChanged: (Set<int> v) => result = v,
            customization: IddsChipCustomization.integer(suffix: 'hari'),
          ),
        ),
      ));
      expect(find.byType(EditableText), findsNothing);
      await tester.tap(find.text('Kustomisasi'));
      await tester.pumpAndSettle();
      expect(find.byType(EditableText), findsOneWidget);

      await tester.enterText(find.byType(EditableText), '45');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(result, <int>{45});
      expect(find.byType(EditableText), findsNothing);
    });

    testWidgets('nilai kustom tampil di label dan dipakai sebagai isian awal', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(
        SizedBox(
          width: 600,
          child: IddsChipGroup<int>(
            options: dayOptions,
            selected: const <int>{45},
            onChanged: (_) {},
            customization: IddsChipCustomization.integer(suffix: 'hari'),
          ),
        ),
      ));
      expect(find.text('Kustomisasi: 45 hari'), findsOneWidget);
      await tester.tap(find.text('Kustomisasi: 45 hari'));
      await tester.pumpAndSettle();
      expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, '45');
    });

    testWidgets('banyak pilihan: mengganti nilai kustom lama, isian kosong menghapusnya', (WidgetTester tester) async {
      Set<String>? result;
      await tester.pumpWidget(testApp(
        SizedBox(
          width: 600,
          child: IddsChipGroup<String>(
            multiple: true,
            options: const <IddsChipOption<String>>[IddsChipOption<String>(value: 'a', label: 'A')],
            selected: const <String>{'a', 'lama'},
            onChanged: (Set<String> v) => result = v,
            customization: IddsChipCustomization.text(),
          ),
        ),
      ));
      await tester.tap(find.text('Kustomisasi: lama'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), 'baru');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(result, <String>{'a', 'baru'});

      await tester.tap(find.text('Kustomisasi: lama'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(result, <String>{'a'});
    });
  });
}
