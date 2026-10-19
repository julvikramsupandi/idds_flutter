import 'dart:ui' show Brightness, Color, FontWeight, TextBaseline, TextLeadingDistribution;

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/painting.dart' show TextStyle;

import '../tokens/idds_colors.g.dart';
import '../tokens/idds_typography_tokens.g.dart';
import 'idds_brand.dart';

/// Mengubah gaya teks IDDS, lihat [IddsThemeData.textStyleBuilder].
typedef IddsTextStyleBuilder = TextStyle Function(TextStyle style);

/// Konfigurasi visual IDDS: brand, mode terang/gelap, dan font.
///
/// ```dart
/// IddsTheme(
///   data: IddsThemeData(brand: IddsBrand.panrb, brightness: Brightness.dark),
///   child: const MyApp(),
/// )
/// ```
@immutable
class IddsThemeData {
  /// Membuat tema. [colors] dihitung otomatis dari [brand] dan
  /// [brightness] bila tidak diberikan.
  factory IddsThemeData({
    IddsBrand brand = IddsBrand.neutral,
    Brightness brightness = Brightness.light,
    IddsColors? colors,
    String? fontFamily = defaultFontFamily,
    List<String>? fontFamilyFallback,
    IddsTextStyleBuilder? textStyleBuilder,
    bool compactOnSmallScreens = true,
  }) {
    return IddsThemeData.raw(
      brand: brand,
      brightness: brightness,
      colors: colors ?? IddsColors.resolve(brand, brightness),
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      textStyleBuilder: textStyleBuilder,
      compactOnSmallScreens: compactOnSmallScreens,
    );
  }

  /// Tema terang.
  factory IddsThemeData.light({IddsBrand brand = IddsBrand.neutral}) =>
      IddsThemeData(brand: brand);

  /// Tema gelap.
  factory IddsThemeData.dark({IddsBrand brand = IddsBrand.neutral}) =>
      IddsThemeData(brand: brand, brightness: Brightness.dark);

  /// Membuat tema tanpa menghitung ulang warna.
  const IddsThemeData.raw({
    required this.brand,
    required this.brightness,
    required this.colors,
    required this.fontFamily,
    required this.fontFamilyFallback,
    this.textStyleBuilder,
    required this.compactOnSmallScreens,
  });

  /// Font resmi IDDS. Font ini tidak dibundel di package: daftarkan Inter di
  /// aplikasi Anda (lihat README), atau Flutter akan memakai font sistem.
  static const String defaultFontFamily = 'Inter';

  /// Brand aktif.
  final IddsBrand brand;

  /// Mode terang atau gelap.
  final Brightness brightness;

  /// Semua warna untuk [brand] dan [brightness].
  final IddsColors colors;

  /// Keluarga font untuk semua komponen.
  final String? fontFamily;

  /// Font cadangan bila [fontFamily] tidak memiliki glyph tertentu.
  final List<String>? fontFamilyFallback;

  /// Mengubah setiap gaya teks dari [textStyle] sebelum dipakai komponen,
  /// misalnya untuk font dari package google_fonts:
  ///
  /// ```dart
  /// IddsThemeData(textStyleBuilder: (style) => GoogleFonts.inter(textStyle: style))
  /// ```
  ///
  /// google_fonts mendaftarkan setiap ketebalan sebagai keluarga font
  /// tersendiri, jadi cukup mengisi [fontFamily] dengan
  /// `GoogleFonts.inter().fontFamily` hanya memuat ketebalan regular.
  final IddsTextStyleBuilder? textStyleBuilder;

  /// Bila `true`, komponen memakai ukuran satu tingkat lebih kecil saat lebar
  /// layar di bawah 640px, sama seperti versi web IDDS.
  final bool compactOnSmallScreens;

  /// Apakah tema ini mode gelap.
  bool get isDark => brightness == Brightness.dark;

  /// Gaya teks IDDS dengan font tema ini.
  ///
  /// [lineHeight] dalam pixel, misalnya [IddsLineHeight.sm].
  TextStyle textStyle({
    required double fontSize,
    required double lineHeight,
    FontWeight fontWeight = IddsFontWeight.normal,
    Color? color,
  }) {
    final TextStyle style = TextStyle(
      // inherit: false agar gaya dari luar tidak ikut tercampur. Gaya seperti
      // ini wajib punya fontSize dan textBaseline (diperiksa oleh TextField).
      inherit: false,
      textBaseline: TextBaseline.alphabetic,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      height: lineHeight / fontSize,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: fontWeight,
      color: color ?? colors.contentPrimary,
    );
    return textStyleBuilder?.call(style) ?? style;
  }

  /// Salinan dengan sebagian nilai diganti. Warna dihitung ulang bila
  /// [brand] atau [brightness] berubah dan [colors] tidak diberikan.
  IddsThemeData copyWith({
    IddsBrand? brand,
    Brightness? brightness,
    IddsColors? colors,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    IddsTextStyleBuilder? textStyleBuilder,
    bool? compactOnSmallScreens,
  }) {
    final IddsBrand newBrand = brand ?? this.brand;
    final Brightness newBrightness = brightness ?? this.brightness;
    final bool recolor = newBrand != this.brand || newBrightness != this.brightness;
    return IddsThemeData.raw(
      brand: newBrand,
      brightness: newBrightness,
      colors: colors ?? (recolor ? IddsColors.resolve(newBrand, newBrightness) : this.colors),
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      textStyleBuilder: textStyleBuilder ?? this.textStyleBuilder,
      compactOnSmallScreens: compactOnSmallScreens ?? this.compactOnSmallScreens,
    );
  }

  /// Interpolasi antara dua tema, dipakai oleh [AnimatedIddsTheme].
  static IddsThemeData lerp(IddsThemeData a, IddsThemeData b, double t) {
    if (identical(a, b)) return a;
    final IddsThemeData discrete = t < 0.5 ? a : b;
    return IddsThemeData.raw(
      brand: discrete.brand,
      brightness: discrete.brightness,
      colors: a.colors.lerp(b.colors, t),
      fontFamily: discrete.fontFamily,
      fontFamilyFallback: discrete.fontFamilyFallback,
      textStyleBuilder: discrete.textStyleBuilder,
      compactOnSmallScreens: discrete.compactOnSmallScreens,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IddsThemeData &&
          other.brand == brand &&
          other.brightness == brightness &&
          other.colors == colors &&
          other.fontFamily == fontFamily &&
          listEquals(other.fontFamilyFallback, fontFamilyFallback) &&
          other.textStyleBuilder == textStyleBuilder &&
          other.compactOnSmallScreens == compactOnSmallScreens;

  @override
  int get hashCode => Object.hash(
        brand,
        brightness,
        colors,
        fontFamily,
        fontFamilyFallback == null ? null : Object.hashAll(fontFamilyFallback!),
        textStyleBuilder,
        compactOnSmallScreens,
      );
}
