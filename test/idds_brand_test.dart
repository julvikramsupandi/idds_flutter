import 'dart:ui' show Brightness, Color;

import 'package:flutter/painting.dart' show TextStyle;
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:idds_flutter/primitives.dart';

void main() {
  group('brand resmi (nilai dari @idds/styles 1.6.38)', () {
    test('warna utama mode terang sesuai --ina-primary-primary', () {
      expect(IddsBrand.neutral.primaryMainLight, const Color(0xFF141414));
      expect(IddsBrand.inagov.primaryMainLight, const Color(0xFF196BCD));
      expect(IddsBrand.inapas.primaryMainLight, const Color(0xFFCC1515));
      expect(IddsBrand.inaku.primaryMainLight, const Color(0xFF06264D));
      expect(IddsBrand.panrb.primaryMainLight, const Color(0xFFB42B2D));
      expect(IddsBrand.bkn.primaryMainLight, const Color(0xFFDE1D5E));
      expect(IddsBrand.lan.primaryMainLight, const Color(0xFF2663A3));
      expect(IddsBrand.bgn.primaryMainLight, const Color(0xFF0058FF));
    });

    test('override dark mode diterapkan', () {
      expect(IddsBrand.panrb.primaryMainDark, IddsBrand.panrb.primary.shade400);
      expect(IddsBrand.inagov.primaryMainDark, IddsBrand.inagov.primary.shade400);
      expect(IddsBrand.inapas.primaryMainDark, IddsBrand.inapas.primary.shade400);
      expect(IddsBrand.inaku.primaryMainDark, IddsBrand.inaku.primary.shade300);
      // Brand tanpa override tetap memakai warna terang.
      expect(IddsBrand.bkn.primaryMainDark, IddsBrand.bkn.primaryMainLight);
    });

    test('warna utama dark mode terlihat di latar gelap (regresi Neutral)', () {
      const Color darkBackground = Color(0xFF141414);
      expect(IddsBrand.neutral.primaryMainDark, const Color(0xFFFFFFFF));
      expect(IddsBrand.neutral.onPrimaryDark, darkBackground);
      for (final IddsBrand b in IddsBrand.values) {
        expect(
          IddsColorUtils.contrastRatio(b.primaryMainDark, darkBackground),
          greaterThan(2.9),
          reason: b.id,
        );
      }
    });

    test('secondary yang tidak didefinisikan diwarisi dari :root', () {
      expect(IddsBrand.inapas.secondary, IddsBrand.neutral.secondary);
      expect(IddsBrand.inagov.secondary.shade900, IddsBrand.neutral.secondary.shade900);
    });

    test('ada 8 brand dengan id unik', () {
      expect(IddsBrand.values, hasLength(8));
      expect(IddsBrand.values.map((IddsBrand b) => b.id).toSet(), hasLength(8));
    });
  });

  group('IddsColors.resolve', () {
    test('menggabungkan brand dan token semantik', () {
      final IddsColors light = IddsColors.resolve(IddsBrand.panrb, Brightness.light);
      final IddsColors dark = IddsColors.resolve(IddsBrand.panrb, Brightness.dark);
      expect(light.primaryMain, const Color(0xFFB42B2D));
      expect(dark.primaryMain, const Color(0xFFE15254));
      expect(light.backgroundPrimary, const Color(0xFFFFFFFF));
      expect(dark.backgroundPrimary, const Color(0xFF141414));
      expect(light.contentPrimary, const Color(0xFF1F1F1F));
      expect(dark.contentPrimary, const Color(0xFFFFFFFF));
    });
  });

  group('IddsBrand.fromSeed', () {
    const Color purple = Color(0xFF7C3AED);
    final IddsBrand brand = IddsBrand.fromSeed(purple, name: 'Ungu');

    test('seed dipakai persis sebagai warna utama', () {
      expect(brand.primaryMainLight, purple);
      expect(brand.primary.colors, contains(purple));
      expect(brand.name, 'Ungu');
    });

    test('skala urut dari terang ke gelap', () {
      final List<double> lum = brand.primary.colors.map(IddsColorUtils.relativeLuminance).toList();
      for (int i = 1; i < lum.length; i++) {
        expect(lum[i], lessThan(lum[i - 1]), reason: 'langkah ${IddsColorScale.steps[i]}');
      }
    });

    test('warna teks memenuhi kontras', () {
      expect(IddsColorUtils.contrastRatio(brand.primaryMainLight, brand.onPrimaryLight), greaterThanOrEqualTo(4.5));
    });

    test('warna utama dark mode terlihat di latar gelap', () {
      for (final Color seed in <Color>[purple, const Color(0xFF06264D), const Color(0xFFB42B2D)]) {
        final IddsBrand b = IddsBrand.fromSeed(seed);
        expect(
          IddsColorUtils.contrastRatio(b.primaryMainDark, const Color(0xFF141414)),
          greaterThanOrEqualTo(3),
          reason: '$seed',
        );
      }
    });

    test('seed terang memakai teks gelap', () {
      final IddsBrand yellow = IddsBrand.fromSeed(const Color(0xFFFFCC00));
      expect(yellow.onPrimaryLight, const Color(0xFF141414));
    });
  });

  group('IddsBrand.fromPalette', () {
    test('memakai palet primitive', () {
      final IddsBrand violet = IddsBrand.fromPalette(IddsPrimitives.violet);
      expect(violet.primaryMainLight, IddsPrimitives.violet.shade500);
      expect(violet.primary.shade900, IddsPrimitives.violet.shade900);
      expect(violet.secondary, IddsBrand.neutral.secondary);
    });
  });

  group('IddsColorUtils', () {
    test('kontras hitam-putih = 21', () {
      expect(
        IddsColorUtils.contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
    });

    test('OKLCH bolak-balik mempertahankan warna', () {
      for (final Color c in <Color>[const Color(0xFF196BCD), const Color(0xFFB42B2D), const Color(0xFF808080)]) {
        final Color back = IddsColorUtils.fromOklch(IddsColorUtils.toOklch(c));
        expect(back, c);
      }
    });
  });

  group('IddsThemeData.textStyle', () {
    test('memenuhi syarat TextField untuk gaya inherit: false', () {
      final TextStyle style = IddsThemeData().textStyle(fontSize: 14, lineHeight: 20);
      expect(style.inherit, isFalse);
      expect(style.fontSize, 14);
      expect(style.textBaseline, isNotNull);
    });
  });

  group('IddsColorScale', () {
    test('operator [] dan langkah tidak valid', () {
      expect(IddsBrand.inagov.primary[400], const Color(0xFF196BCD));
      expect(() => IddsBrand.inagov.primary[450], throwsArgumentError);
    });
  });

  group('IddsThemeData.textStyleBuilder', () {
    TextStyle mark(TextStyle s) => s.copyWith(fontFamily: 'Font_${s.fontWeight?.value}');

    test('setiap gaya teks melewati builder, termasuk ketebalannya', () {
      final IddsThemeData theme = IddsThemeData(textStyleBuilder: mark);
      final TextStyle style = theme.textStyle(fontSize: 14, lineHeight: 20, fontWeight: IddsFontWeight.semibold);
      expect(style.fontFamily, 'Font_600');
      expect(style.fontSize, 14);
    });

    test('ikut disalin dan memengaruhi kesamaan tema', () {
      final IddsThemeData a = IddsThemeData(textStyleBuilder: mark);
      expect(a.copyWith(brightness: Brightness.dark).textStyleBuilder, same(mark));
      expect(a == IddsThemeData(textStyleBuilder: mark), isTrue);
      expect(a == IddsThemeData(), isFalse);
    });
  });
}
