// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Source: @idds/styles 1.6.38 (dist/base.css), MIT License.
// Regenerate with `npm run generate` in tool/.

import 'dart:ui' show Brightness, Color;

import 'package:flutter/foundation.dart' show immutable;

import '../foundation/idds_brand.dart';
import '../foundation/idds_color_scale.dart';

/// Semua warna IDDS untuk satu brand dan satu mode (terang/gelap).
///
/// Dapatkan lewat `IddsTheme.of(context).colors`.
@immutable
class IddsColors {
  /// Membuat kumpulan warna secara manual. Biasanya cukup pakai
  /// [IddsColors.resolve].
  const IddsColors({
    required this.primary,
    required this.primaryMain,
    required this.onPrimary,
    required this.secondary,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundOverlay,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentTertiary,
    required this.contentGuide,
    required this.contentNegative,
    required this.contentPositive,
    required this.strokePrimary,
    required this.strokeSecondary,
    required this.strokeTertiary,
    required this.white,
    required this.black,
    required this.baseWhite,
    required this.baseBlack,
    required this.guide,
    required this.negative,
    required this.positive,
    required this.warning,
  });

  /// Menggabungkan warna [brand] dengan token semantik untuk [brightness].
  factory IddsColors.resolve(IddsBrand brand, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final IddsColors semantic = isDark ? _dark : _light;
    return semantic.copyWith(
      primary: brand.primary,
      primaryMain: isDark ? brand.primaryMainDark : brand.primaryMainLight,
      onPrimary: isDark ? brand.onPrimaryDark : brand.onPrimaryLight,
      secondary: brand.secondary,
    );
  }

  static const IddsColors _light = IddsColors(
    primary: IddsColorScale.empty,
    primaryMain: Color(0x00000000),
    onPrimary: Color(0x00000000),
    secondary: IddsColorScale.empty,
    backgroundPrimary: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFF8F8F7),
    backgroundTertiary: Color(0xFFF2F2F2),
    backgroundOverlay: Color(0x7A1F1F1F),
    contentPrimary: Color(0xFF1F1F1F),
    contentSecondary: Color(0xFF525252),
    contentTertiary: Color(0xFFA3A3A3),
    contentGuide: Color(0xFF0968F6),
    contentNegative: Color(0xFFF02D2D),
    contentPositive: Color(0xFF288034),
    strokePrimary: Color(0xFFE5E5E5),
    strokeSecondary: Color(0xFFA3A3A3),
    strokeTertiary: Color(0xFF1F1F1F),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF141414),
    baseWhite: Color(0xFFFFFFFF),
    baseBlack: Color(0xFF000000),
    guide: IddsPalette(
      shade50: Color(0xFFFAFCFF),
      shade100: Color(0xFFECF3FE),
      shade200: Color(0xFFDCEAFE),
      shade300: Color(0xFF84B4FB),
      shade400: Color(0xFF4D93FC),
      shade500: Color(0xFF0968F6),
      shade600: Color(0xFF0049B8),
      shade700: Color(0xFF002A69),
      shade800: Color(0xFF0E192A),
      shade900: Color(0xFF070E17),
    ),
    negative: IddsPalette(
      shade50: Color(0xFFFFFAFA),
      shade100: Color(0xFFFDEDED),
      shade200: Color(0xFFFFE0E0),
      shade300: Color(0xFFFFA0A0),
      shade400: Color(0xFFFF5C5C),
      shade500: Color(0xFFF02D2D),
      shade600: Color(0xFFD50B0B),
      shade700: Color(0xFF570303),
      shade800: Color(0xFF2A0303),
      shade900: Color(0xFF1D0202),
    ),
    positive: IddsPalette(
      shade50: Color(0xFFFAFFFA),
      shade100: Color(0xFFEDFDED),
      shade200: Color(0xFFE0FAE0),
      shade300: Color(0xFFA6F0A5),
      shade400: Color(0xFF4CE160),
      shade500: Color(0xFF3CC14E),
      shade600: Color(0xFF288034),
      shade700: Color(0xFF1B561A),
      shade800: Color(0xFF0C310D),
      shade900: Color(0xFF021D06),
    ),
    warning: IddsPalette(
      shade50: Color(0xFFFFFEFA),
      shade100: Color(0xFFFFF9EB),
      shade200: Color(0xFFFFF8D5),
      shade300: Color(0xFFFFE58A),
      shade400: Color(0xFFFFCC14),
      shade500: Color(0xFFEEBB04),
      shade600: Color(0xFF855F00),
      shade700: Color(0xFF553B06),
      shade800: Color(0xFF312102),
      shade900: Color(0xFF1C1402),
    ),
  );

  static const IddsColors _dark = IddsColors(
    primary: IddsColorScale.empty,
    primaryMain: Color(0x00000000),
    onPrimary: Color(0x00000000),
    secondary: IddsColorScale.empty,
    backgroundPrimary: Color(0xFF141414),
    backgroundSecondary: Color(0xFF1F1F1F),
    backgroundTertiary: Color(0xFF404040),
    backgroundOverlay: Color(0x7A1F1F1F),
    contentPrimary: Color(0xFFFFFFFF),
    contentSecondary: Color(0xFFA3A3A3),
    contentTertiary: Color(0xFF737373),
    contentGuide: Color(0xFF4D93FC),
    contentNegative: Color(0xFFFF5C5C),
    contentPositive: Color(0xFF3CC14E),
    strokePrimary: Color(0xFF404040),
    strokeSecondary: Color(0xFFA3A3A3),
    strokeTertiary: Color(0xFFE5E5E5),
    white: Color(0xFF141414),
    black: Color(0xFFFFFFFF),
    baseWhite: Color(0xFFFFFFFF),
    baseBlack: Color(0xFF000000),
    guide: IddsPalette(
      shade50: Color(0xFFFAFCFF),
      shade100: Color(0xFFECF3FE),
      shade200: Color(0xFFDCEAFE),
      shade300: Color(0xFF84B4FB),
      shade400: Color(0xFF4D93FC),
      shade500: Color(0xFF0968F6),
      shade600: Color(0xFF0049B8),
      shade700: Color(0xFF002A69),
      shade800: Color(0xFF0E192A),
      shade900: Color(0xFF070E17),
    ),
    negative: IddsPalette(
      shade50: Color(0xFFFFFAFA),
      shade100: Color(0xFFFDEDED),
      shade200: Color(0xFFFFE0E0),
      shade300: Color(0xFFFFA0A0),
      shade400: Color(0xFFFF5C5C),
      shade500: Color(0xFFF02D2D),
      shade600: Color(0xFFD50B0B),
      shade700: Color(0xFF570303),
      shade800: Color(0xFF2A0303),
      shade900: Color(0xFF1D0202),
    ),
    positive: IddsPalette(
      shade50: Color(0xFFFAFFFA),
      shade100: Color(0xFFEDFDED),
      shade200: Color(0xFFE0FAE0),
      shade300: Color(0xFFA6F0A5),
      shade400: Color(0xFF4CE160),
      shade500: Color(0xFF3CC14E),
      shade600: Color(0xFF288034),
      shade700: Color(0xFF1B561A),
      shade800: Color(0xFF0C310D),
      shade900: Color(0xFF021D06),
    ),
    warning: IddsPalette(
      shade50: Color(0xFFFFFEFA),
      shade100: Color(0xFFFFF9EB),
      shade200: Color(0xFFFFF8D5),
      shade300: Color(0xFFFFE58A),
      shade400: Color(0xFFFFCC14),
      shade500: Color(0xFFEEBB04),
      shade600: Color(0xFF855F00),
      shade700: Color(0xFF553B06),
      shade800: Color(0xFF312102),
      shade900: Color(0xFF1C1402),
    ),
  );

  /// Skala warna utama brand (25–900).
  final IddsColorScale primary;

  /// Warna utama brand untuk mode aktif (`--ina-primary-primary`).
  final Color primaryMain;

  /// Warna teks/ikon di atas [primaryMain].
  final Color onPrimary;

  /// Skala warna sekunder brand (25–900).
  final IddsColorScale secondary;

  /// Latar utama halaman dan komponen. (`--ina-background-primary`)
  final Color backgroundPrimary;

  /// Latar sekunder, mis. area yang dibedakan atau hover ringan. (`--ina-background-secondary`)
  final Color backgroundSecondary;

  /// Latar tersier, mis. komponen nonaktif atau hover kuat. (`--ina-background-tertiary`)
  final Color backgroundTertiary;

  /// Lapisan gelap di belakang modal dan drawer. (`--ina-background-overlay`)
  final Color backgroundOverlay;

  /// Teks dan ikon utama. (`--ina-content-primary`)
  final Color contentPrimary;

  /// Teks dan ikon sekunder. (`--ina-content-secondary`)
  final Color contentSecondary;

  /// Teks dan ikon tersier, placeholder, dan konten nonaktif. (`--ina-content-tertiary`)
  final Color contentTertiary;

  /// Tautan dan konten informatif. (`--ina-content-guide`)
  final Color contentGuide;

  /// Pesan error dan aksi destruktif. (`--ina-content-negative`)
  final Color contentNegative;

  /// Pesan sukses dan konfirmasi. (`--ina-content-positive`)
  final Color contentPositive;

  /// Garis tepi dan pembatas utama. (`--ina-stroke-primary`)
  final Color strokePrimary;

  /// Garis tepi dengan kontras sedang, mis. input. (`--ina-stroke-secondary`)
  final Color strokeSecondary;

  /// Garis tepi kontras tinggi, mis. cincin fokus. (`--ina-stroke-tertiary`)
  final Color strokeTertiary;

  /// Putih yang mengikuti mode (gelap di dark mode). (`--ina-white`)
  final Color white;

  /// Hitam yang mengikuti mode (terang di dark mode). (`--ina-black`)
  final Color black;

  /// Putih tetap di semua mode, mis. teks di atas warna brand. (`--ina-base-white`)
  final Color baseWhite;

  /// Hitam tetap di semua mode. (`--ina-base-black`)
  final Color baseBlack;

  /// Skala warna panduan/informasi (biru). (`--ina-guide-*`)
  final IddsPalette guide;

  /// Skala warna negatif/error (merah). (`--ina-negative-*`)
  final IddsPalette negative;

  /// Skala warna positif/sukses (hijau). (`--ina-positive-*`)
  final IddsPalette positive;

  /// Skala warna peringatan (kuning). (`--ina-warning-*`)
  final IddsPalette warning;

  /// Salinan dengan sebagian nilai diganti.
  IddsColors copyWith({
    IddsColorScale? primary,
    Color? primaryMain,
    Color? onPrimary,
    IddsColorScale? secondary,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundOverlay,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentTertiary,
    Color? contentGuide,
    Color? contentNegative,
    Color? contentPositive,
    Color? strokePrimary,
    Color? strokeSecondary,
    Color? strokeTertiary,
    Color? white,
    Color? black,
    Color? baseWhite,
    Color? baseBlack,
    IddsPalette? guide,
    IddsPalette? negative,
    IddsPalette? positive,
    IddsPalette? warning,
  }) {
    return IddsColors(
      primary: primary ?? this.primary,
      primaryMain: primaryMain ?? this.primaryMain,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundOverlay: backgroundOverlay ?? this.backgroundOverlay,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentTertiary: contentTertiary ?? this.contentTertiary,
      contentGuide: contentGuide ?? this.contentGuide,
      contentNegative: contentNegative ?? this.contentNegative,
      contentPositive: contentPositive ?? this.contentPositive,
      strokePrimary: strokePrimary ?? this.strokePrimary,
      strokeSecondary: strokeSecondary ?? this.strokeSecondary,
      strokeTertiary: strokeTertiary ?? this.strokeTertiary,
      white: white ?? this.white,
      black: black ?? this.black,
      baseWhite: baseWhite ?? this.baseWhite,
      baseBlack: baseBlack ?? this.baseBlack,
      guide: guide ?? this.guide,
      negative: negative ?? this.negative,
      positive: positive ?? this.positive,
      warning: warning ?? this.warning,
    );
  }

  /// Interpolasi linear antara dua kumpulan warna (untuk animasi tema).
  IddsColors lerp(IddsColors other, double t) {
    if (identical(this, other)) return this;
    return IddsColors(
      primary: IddsColorScale.lerp(primary, other.primary, t),
      primaryMain: Color.lerp(primaryMain, other.primaryMain, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: IddsColorScale.lerp(secondary, other.secondary, t),
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundTertiary: Color.lerp(backgroundTertiary, other.backgroundTertiary, t)!,
      backgroundOverlay: Color.lerp(backgroundOverlay, other.backgroundOverlay, t)!,
      contentPrimary: Color.lerp(contentPrimary, other.contentPrimary, t)!,
      contentSecondary: Color.lerp(contentSecondary, other.contentSecondary, t)!,
      contentTertiary: Color.lerp(contentTertiary, other.contentTertiary, t)!,
      contentGuide: Color.lerp(contentGuide, other.contentGuide, t)!,
      contentNegative: Color.lerp(contentNegative, other.contentNegative, t)!,
      contentPositive: Color.lerp(contentPositive, other.contentPositive, t)!,
      strokePrimary: Color.lerp(strokePrimary, other.strokePrimary, t)!,
      strokeSecondary: Color.lerp(strokeSecondary, other.strokeSecondary, t)!,
      strokeTertiary: Color.lerp(strokeTertiary, other.strokeTertiary, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      baseWhite: Color.lerp(baseWhite, other.baseWhite, t)!,
      baseBlack: Color.lerp(baseBlack, other.baseBlack, t)!,
      guide: IddsPalette.lerp(guide, other.guide, t),
      negative: IddsPalette.lerp(negative, other.negative, t),
      positive: IddsPalette.lerp(positive, other.positive, t),
      warning: IddsPalette.lerp(warning, other.warning, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IddsColors &&
          other.primary == primary &&
          other.primaryMain == primaryMain &&
          other.onPrimary == onPrimary &&
          other.secondary == secondary &&
          other.backgroundPrimary == backgroundPrimary &&
          other.backgroundSecondary == backgroundSecondary &&
          other.backgroundTertiary == backgroundTertiary &&
          other.backgroundOverlay == backgroundOverlay &&
          other.contentPrimary == contentPrimary &&
          other.contentSecondary == contentSecondary &&
          other.contentTertiary == contentTertiary &&
          other.contentGuide == contentGuide &&
          other.contentNegative == contentNegative &&
          other.contentPositive == contentPositive &&
          other.strokePrimary == strokePrimary &&
          other.strokeSecondary == strokeSecondary &&
          other.strokeTertiary == strokeTertiary &&
          other.white == white &&
          other.black == black &&
          other.baseWhite == baseWhite &&
          other.baseBlack == baseBlack &&
          other.guide == guide &&
          other.negative == negative &&
          other.positive == positive &&
          other.warning == warning;

  @override
  int get hashCode => Object.hashAll(<Object>[
        primary,
        primaryMain,
        onPrimary,
        secondary,
        backgroundPrimary,
        backgroundSecondary,
        backgroundTertiary,
        backgroundOverlay,
        contentPrimary,
        contentSecondary,
        contentTertiary,
        contentGuide,
        contentNegative,
        contentPositive,
        strokePrimary,
        strokeSecondary,
        strokeTertiary,
        white,
        black,
        baseWhite,
        baseBlack,
        guide,
        negative,
        positive,
        warning,
      ]);
}
