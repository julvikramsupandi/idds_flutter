import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

Widget _app(Widget child, {IddsThemeData? theme}) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    builder: (BuildContext context, Widget? _) => IddsTheme(
      data: theme ?? IddsThemeData(),
      child: Center(child: child),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final AnimatedContainer container = tester.widget<AnimatedContainer>(
    find.descendant(of: find.byType(IddsButton), matching: find.byType(AnimatedContainer)),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('memanggil onPressed saat ditekan', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(_app(IddsButton(onPressed: () => taps++, child: const Text('Simpan'))));
    await tester.tap(find.text('Simpan'));
    expect(taps, 1);
  });

  testWidgets('nonaktif bila onPressed null', (WidgetTester tester) async {
    await tester.pumpWidget(_app(const IddsButton(onPressed: null, child: Text('Simpan'))));
    await tester.tap(find.text('Simpan'), warnIfMissed: false);
    final IddsColors colors = IddsThemeData().colors;
    expect(_decoration(tester).color, colors.backgroundTertiary);
  });

  testWidgets('bisa diaktifkan dengan Enter dan Space', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      _app(IddsButton(onPressed: () => taps++, autofocus: true, child: const Text('Kirim'))),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 2);
  });

  testWidgets('primary memakai warna utama brand', (WidgetTester tester) async {
    final IddsThemeData theme = IddsThemeData(brand: IddsBrand.panrb);
    await tester.pumpWidget(_app(IddsButton(onPressed: () {}, child: const Text('OK')), theme: theme));
    expect(_decoration(tester).color, IddsBrand.panrb.primaryMainLight);
  });

  testWidgets('secondary memiliki garis tepi', (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(IddsButton(onPressed: () {}, hierarchy: IddsButtonHierarchy.secondary, child: const Text('Batal'))),
    );
    expect(_decoration(tester).border, isNotNull);
  });

  group('tinggi sesuai spesifikasi IDDS', () {
    const Map<IddsButtonSize, double> desktop = <IddsButtonSize, double>{
      IddsButtonSize.xl2: 56,
      IddsButtonSize.xl: 48,
      IddsButtonSize.lg: 44,
      IddsButtonSize.md: 40,
      IddsButtonSize.sm: 32,
    };
    const Map<IddsButtonSize, double> compact = <IddsButtonSize, double>{
      // padding + line-height dari media query max-width: 639px.
      IddsButtonSize.xl2: 44,
      IddsButtonSize.xl: 44,
      IddsButtonSize.lg: 36,
      IddsButtonSize.md: 32,
      IddsButtonSize.sm: 24,
    };

    for (final MapEntry<IddsButtonSize, double> e in desktop.entries) {
      testWidgets('${e.key.name} = ${e.value} di layar lebar', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        for (final IddsButtonHierarchy h in <IddsButtonHierarchy>[
          IddsButtonHierarchy.primary,
          IddsButtonHierarchy.secondary,
        ]) {
          await tester.pumpWidget(
            _app(IddsButton(onPressed: () {}, size: e.key, hierarchy: h, child: const Text('A'))),
          );
          expect(tester.getSize(find.byType(IddsButton)).height, e.value, reason: h.name);
        }
      });
    }

    for (final MapEntry<IddsButtonSize, double> e in compact.entries) {
      testWidgets('${e.key.name} = ${e.value} di layar < 640px', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(400, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(_app(IddsButton(onPressed: () {}, size: e.key, child: const Text('A'))));
        expect(tester.getSize(find.byType(IddsButton)).height, e.value);
      });
    }

    testWidgets('compactOnSmallScreens: false mempertahankan ukuran', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          IddsButton(onPressed: () {}, child: const Text('A')),
          theme: IddsThemeData(compactOnSmallScreens: false),
        ),
      );
      expect(tester.getSize(find.byType(IddsButton)).height, 40);
    });
  });
}
