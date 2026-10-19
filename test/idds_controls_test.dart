import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

void main() {
  group('IddsCheckbox', () {
    testWidgets('mengirim nilai kebalikan saat ditekan', (WidgetTester tester) async {
      bool? received;
      await tester.pumpWidget(
        testApp(IddsCheckbox(value: false, onChanged: (bool v) => received = v, label: 'Setuju')),
      );
      await tester.tap(find.text('Setuju'));
      expect(received, isTrue);
    });

    testWidgets('nonaktif tidak bereaksi', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsCheckbox(value: false, onChanged: null, label: 'Setuju')));
      await tester.tap(find.text('Setuju'), warnIfMissed: false);
      // Tidak ada callback; cukup pastikan tidak error.
      expect(find.text('Setuju'), findsOneWidget);
    });

    testWidgets('kotak 20px di layar lebar, 16px di layar < 768px', (WidgetTester tester) async {
      Size boxSize() => tester.getSize(
            find.descendant(of: find.byType(IddsCheckbox), matching: find.byType(AnimatedContainer)),
          );
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpWidget(testApp(IddsCheckbox(value: true, onChanged: (_) {})));
      expect(boxSize(), const Size.square(20));

      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpWidget(testApp(IddsCheckbox(value: true, onChanged: (_) {})));
      // Perubahan ukuran dianimasikan; tunggu sampai selesai.
      await tester.pumpAndSettle();
      expect(boxSize(), const Size.square(16));
    });

    testWidgets('tercentang menampilkan ikon, indeterminate menampilkan strip', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(IddsCheckbox(value: true, onChanged: (_) {})));
      expect(tester.widget<IddsIcon>(find.byType(IddsIcon)).icon, IddsIcons.check);
      await tester.pumpWidget(testApp(IddsCheckbox(value: false, indeterminate: true, onChanged: (_) {})));
      expect(tester.widget<IddsIcon>(find.byType(IddsIcon)).icon, IddsIcons.minus);
      await tester.pumpWidget(testApp(IddsCheckbox(value: false, onChanged: (_) {})));
      expect(find.byType(IddsIcon), findsNothing);
    });

    testWidgets('bisa diaktifkan dengan Space', (WidgetTester tester) async {
      int count = 0;
      await tester.pumpWidget(testApp(IddsCheckbox(value: false, autofocus: true, onChanged: (_) => count++)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(count, 1);
    });
  });

  group('IddsRadioGroup', () {
    const List<IddsRadioOption<String>> options = <IddsRadioOption<String>>[
      IddsRadioOption<String>(value: 'L', label: 'Laki-laki'),
      IddsRadioOption<String>(value: 'P', label: 'Perempuan'),
      IddsRadioOption<String>(value: 'X', label: 'Tidak tersedia', enabled: false),
    ];

    testWidgets('memilih pilihan', (WidgetTester tester) async {
      String? selected;
      await tester.pumpWidget(
        testApp(
          IddsRadioGroup<String>(
            label: 'Jenis kelamin',
            options: options,
            value: 'L',
            onChanged: (String v) => selected = v,
          ),
        ),
      );
      await tester.tap(find.text('Perempuan'));
      expect(selected, 'P');
    });

    testWidgets('pilihan nonaktif tidak bisa dipilih', (WidgetTester tester) async {
      String? selected;
      await tester.pumpWidget(
        testApp(IddsRadioGroup<String>(options: options, value: 'L', onChanged: (String v) => selected = v)),
      );
      await tester.tap(find.text('Tidak tersedia'), warnIfMissed: false);
      expect(selected, isNull);
    });

    testWidgets('menampilkan tanda wajib dan teks bantuan', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          IddsRadioGroup<String>(
            label: 'Jenis kelamin',
            required: true,
            helperText: 'Pilih salah satu',
            options: options,
            value: null,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Jenis kelamin *', findRichText: true), findsOneWidget);
      expect(find.text('Pilih salah satu'), findsOneWidget);
    });
  });

  group('IddsToggle', () {
    testWidgets('mengirim nilai kebalikan', (WidgetTester tester) async {
      bool? received;
      await tester.pumpWidget(testApp(IddsToggle(value: true, onChanged: (bool v) => received = v)));
      await tester.tap(find.byType(IddsToggle));
      expect(received, isFalse);
    });

    testWidgets('ukuran track sesuai spesifikasi', (WidgetTester tester) async {
      for (final IddsToggleSize size in IddsToggleSize.values) {
        await tester.pumpWidget(testApp(IddsToggle(value: false, size: size, onChanged: (_) {})));
        // Perubahan ukuran antarvarian dianimasikan; tunggu sampai selesai.
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(IddsToggle)), Size(size.trackWidth, size.trackHeight));
      }
    });
  });

  group('IddsTextField', () {
    testWidgets('mengetik memanggil onChanged', (WidgetTester tester) async {
      String? value;
      await tester.pumpWidget(testApp(IddsTextField(onChanged: (String v) => value = v)));
      await tester.enterText(find.byType(EditableText), 'Gorontalo');
      expect(value, 'Gorontalo');
    });

    testWidgets('fokus tidak membuat ulang input (regresi: harus klik berkali-kali)', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsTextField()));
      final EditableTextState before = tester.state<EditableTextState>(find.byType(EditableText));
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      final EditableTextState after = tester.state<EditableTextState>(find.byType(EditableText));
      expect(identical(before, after), isTrue);
      expect(after.widget.focusNode.hasFocus, isTrue);
      await tester.enterText(find.byType(EditableText), 'langsung bisa');
      expect(find.text('langsung bisa'), findsOneWidget);
    });

    testWidgets('klik di mana saja di dalam kotak memfokuskan input', (WidgetTester tester) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(testApp(IddsTextField(focusNode: node, prefixIcon: const SizedBox.square(dimension: 20))));
      final Rect box = tester.getRect(find.byType(AnimatedContainer).first);
      // Pojok kiri atas: di luar baris teks.
      await tester.tapAt(box.topLeft + const Offset(4, 4));
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('tombol hapus mengosongkan isi', (WidgetTester tester) async {
      int cleared = 0;
      String? value;
      await tester.pumpWidget(
        testApp(IddsTextField(initialValue: 'abc', onChanged: (String v) => value = v, onClear: () => cleared++)),
      );
      await tester.tap(find.bySemanticsLabel('Hapus input'));
      await tester.pump();
      expect(value, '');
      expect(cleared, 1);
      expect(find.bySemanticsLabel('Hapus input'), findsNothing);
    });

    testWidgets('penghitung karakter dan batas maxLength', (WidgetTester tester) async {
      await tester.pumpWidget(testApp(const IddsTextField(maxLength: 5, showCharCount: true)));
      await tester.enterText(find.byType(EditableText), 'Indonesia');
      await tester.pump();
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('statusMessage menggantikan helperText', (WidgetTester tester) async {
      await tester.pumpWidget(
        testApp(
          const IddsTextField(
            helperText: 'Bantuan',
            status: IddsTextFieldStatus.error,
            statusMessage: 'Wajib diisi',
          ),
        ),
      );
      expect(find.text('Wajib diisi'), findsOneWidget);
      expect(find.text('Bantuan'), findsNothing);
    });

    testWidgets(
      'teks berada tepat di tengah kolom (termasuk density compact di desktop)',
      (WidgetTester tester) async {
        await tester.pumpWidget(testApp(const IddsTextField(initialValue: 'Gorontalo')));
        final Rect box = tester.getRect(find.byType(AnimatedContainer).first);
        final Rect input = tester.getRect(find.byType(EditableText));
        expect(input.center.dy, moreOrLessEquals(box.center.dy, epsilon: 0.5));
      },
      variant: TargetPlatformVariant.all(),
    );

    testWidgets('tinggi md: 44 / 40 / 36 sesuai lebar layar', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<double> heightAt(double width) async {
        tester.view.physicalSize = Size(width, 800);
        await tester.pumpWidget(testApp(const IddsTextField()));
        // Perubahan tinggi dianimasikan; tunggu sampai selesai.
        await tester.pumpAndSettle();
        return tester.getSize(find.byType(AnimatedContainer).first).height;
      }

      expect(await heightAt(1024), 44);
      expect(await heightAt(700), 40);
      expect(await heightAt(400), 36);
    });
  });
}
