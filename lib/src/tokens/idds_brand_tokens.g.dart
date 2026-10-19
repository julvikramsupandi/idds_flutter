// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Source: @idds/styles 1.6.38 (dist/base.css), MIT License.
// Regenerate with `npm run generate` in tool/.

import 'dart:ui' show Color;

import '../foundation/idds_brand.dart';
import '../foundation/idds_color_scale.dart';

/// Brand resmi IDDS seperti yang didefinisikan di `@idds/styles`.
abstract final class IddsBrandTokens {
  /// Neutral: Tema bawaan (default) IDDS, monokrom.
  ///
  /// Sumber CSS: `:root` (default).
  ///
  /// Penyesuaian: `primaryMainDark` = `#ffffff` (CSS: `#141414`).
  ///
  /// Penyesuaian: `onPrimaryDark` = `#141414` (CSS: `#ffffff`).
  static const IddsBrand neutral = IddsBrand(
    id: 'neutral',
    name: 'Neutral',
    primary: IddsColorScale(
      shade25: Color(0xFFFFFFFF),
      shade50: Color(0xFFF8F8F7),
      shade100: Color(0xFFF5F5F5),
      shade200: Color(0xFFE5E5E5),
      shade300: Color(0xFFD4D4D4),
      shade400: Color(0xFFA3A3A3),
      shade500: Color(0xFF737373),
      shade600: Color(0xFF525252),
      shade700: Color(0xFF404040),
      shade800: Color(0xFF1F1F1F),
      shade900: Color(0xFF141414),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFF2F9FD),
      shade50: Color(0xFFE3F0FB),
      shade100: Color(0xFFC1E3F6),
      shade200: Color(0xFF8ACCEF),
      shade300: Color(0xFF4CB2E4),
      shade400: Color(0xFF269DD8),
      shade500: Color(0xFF177AB2),
      shade600: Color(0xFF146190),
      shade700: Color(0xFF145378),
      shade800: Color(0xFF164564),
      shade900: Color(0xFF0F2D42),
    ),
    primaryMainLight: Color(0xFF141414),
    primaryMainDark: Color(0xFFFFFFFF),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFF141414),
  );

  /// INAgov: Layanan Aparatur Negara.
  ///
  /// Sumber CSS: `[data-brand='inagov']`.
  static const IddsBrand inagov = IddsBrand(
    id: 'inagov',
    name: 'INAgov',
    primary: IddsColorScale(
      shade25: Color(0xFFF6F9FF),
      shade50: Color(0xFFEFF5FD),
      shade100: Color(0xFFC0D7F9),
      shade200: Color(0xFFA1C4F5),
      shade300: Color(0xFF629CEF),
      shade400: Color(0xFF196BCD),
      shade500: Color(0xFF0956C3),
      shade600: Color(0xFF0A489F),
      shade700: Color(0xFF083575),
      shade800: Color(0xFF022A5B),
      shade900: Color(0xFF041225),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFFFFFFF),
      shade50: Color(0xFFFFFFFF),
      shade100: Color(0xFFFFFFFF),
      shade200: Color(0xFFFFF5EE),
      shade300: Color(0xFFFFE8CC),
      shade400: Color(0xFFFFD2A6),
      shade500: Color(0xFFEDB98A),
      shade600: Color(0xFFD39663),
      shade700: Color(0xFFCC1515),
      shade800: Color(0xFF164564),
      shade900: Color(0xFF0F2D42),
    ),
    primaryMainLight: Color(0xFF196BCD),
    primaryMainDark: Color(0xFF196BCD),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFFFFFFFF),
  );

  /// INApas: Layanan paspor dan keimigrasian.
  ///
  /// Sumber CSS: `[data-brand='inapas']`.
  static const IddsBrand inapas = IddsBrand(
    id: 'inapas',
    name: 'INApas',
    primary: IddsColorScale(
      shade25: Color(0xFFFEF2F2),
      shade50: Color(0xFFF9DCDC),
      shade100: Color(0xFFF9CDC7),
      shade200: Color(0xFFFFA194),
      shade300: Color(0xFFFF5F42),
      shade400: Color(0xFFE8422D),
      shade500: Color(0xFFCC1515),
      shade600: Color(0xFFA00000),
      shade700: Color(0xFF680000),
      shade800: Color(0xFF290404),
      shade900: Color(0xFF140202),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFF2F9FD),
      shade50: Color(0xFFE3F0FB),
      shade100: Color(0xFFC1E3F6),
      shade200: Color(0xFF8ACCEF),
      shade300: Color(0xFF4CB2E4),
      shade400: Color(0xFF269DD8),
      shade500: Color(0xFF177AB2),
      shade600: Color(0xFF146190),
      shade700: Color(0xFF145378),
      shade800: Color(0xFF164564),
      shade900: Color(0xFF0F2D42),
    ),
    primaryMainLight: Color(0xFFCC1515),
    primaryMainDark: Color(0xFFE8422D),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFFFFFFFF),
  );

  /// INAku: Layanan warga.
  ///
  /// Sumber CSS: `[data-brand='inaku']`.
  static const IddsBrand inaku = IddsBrand(
    id: 'inaku',
    name: 'INAku',
    primary: IddsColorScale(
      shade25: Color(0xFFE8F1FC),
      shade50: Color(0xFFD9E9F9),
      shade100: Color(0xFFABD1FF),
      shade200: Color(0xFF629CEF),
      shade300: Color(0xFF3A78C1),
      shade400: Color(0xFF194472),
      shade500: Color(0xFF06264D),
      shade600: Color(0xFF041D35),
      shade700: Color(0xFF020F1F),
      shade800: Color(0xFF020B17),
      shade900: Color(0xFF01080F),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFF2F9FD),
      shade50: Color(0xFFE3F0FB),
      shade100: Color(0xFFC1E3F6),
      shade200: Color(0xFF8ACCEF),
      shade300: Color(0xFF4CB2E4),
      shade400: Color(0xFF269DD8),
      shade500: Color(0xFF177AB2),
      shade600: Color(0xFF146190),
      shade700: Color(0xFF145378),
      shade800: Color(0xFF164564),
      shade900: Color(0xFF0F2D42),
    ),
    primaryMainLight: Color(0xFF06264D),
    primaryMainDark: Color(0xFF3A78C1),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFFFFFFFF),
  );

  /// PANRB: Kementerian Pendayagunaan Aparatur Negara dan Reformasi Birokrasi.
  ///
  /// Sumber CSS: `[data-brand='panrb']`.
  static const IddsBrand panrb = IddsBrand(
    id: 'panrb',
    name: 'PANRB',
    primary: IddsColorScale(
      shade25: Color(0xFFFDF3F3),
      shade50: Color(0xFFFCE4E4),
      shade100: Color(0xFFFACECF),
      shade200: Color(0xFFF5ACAD),
      shade300: Color(0xFFED7C7E),
      shade400: Color(0xFFE15254),
      shade500: Color(0xFFCD3537),
      shade600: Color(0xFFB42B2D),
      shade700: Color(0xFF8F2527),
      shade800: Color(0xFF772526),
      shade900: Color(0xFF400F10),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFF8F7F8),
      shade50: Color(0xFFF0EEEE),
      shade100: Color(0xFFDED9DA),
      shade200: Color(0xFFC1B8BB),
      shade300: Color(0xFF9F9196),
      shade400: Color(0xFF847379),
      shade500: Color(0xFF6C5D62),
      shade600: Color(0xFF584C50),
      shade700: Color(0xFF4B4144),
      shade800: Color(0xFF41393B),
      shade900: Color(0xFF231F20),
    ),
    primaryMainLight: Color(0xFFB42B2D),
    primaryMainDark: Color(0xFFE15254),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFFFFFFFF),
  );

  /// BKN: Badan Kepegawaian Negara.
  ///
  /// Sumber CSS: `[data-brand='bkn']`.
  static const IddsBrand bkn = IddsBrand(
    id: 'bkn',
    name: 'BKN',
    primary: IddsColorScale(
      shade25: Color(0xFFFDF2F7),
      shade50: Color(0xFFFDE6F1),
      shade100: Color(0xFFFDCDE3),
      shade200: Color(0xFFFCA5CB),
      shade300: Color(0xFFF96DA7),
      shade400: Color(0xFFF24286),
      shade500: Color(0xFFDE1D5E),
      shade600: Color(0xFFC41249),
      shade700: Color(0xFFA2123C),
      shade800: Color(0xFF871436),
      shade900: Color(0xFF53041A),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFF2F9FD),
      shade50: Color(0xFFE3F0FB),
      shade100: Color(0xFFC1E3F6),
      shade200: Color(0xFF8ACCEF),
      shade300: Color(0xFF4CB2E4),
      shade400: Color(0xFF269DD8),
      shade500: Color(0xFF177AB2),
      shade600: Color(0xFF146190),
      shade700: Color(0xFF145378),
      shade800: Color(0xFF164564),
      shade900: Color(0xFF0F2D42),
    ),
    primaryMainLight: Color(0xFFDE1D5E),
    primaryMainDark: Color(0xFFDE1D5E),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFFFFFFFF),
  );

  /// LAN: Lembaga Administrasi Negara.
  ///
  /// Sumber CSS: `[data-brand='lan']`.
  static const IddsBrand lan = IddsBrand(
    id: 'lan',
    name: 'LAN',
    primary: IddsColorScale(
      shade25: Color(0xFFF3F6FC),
      shade50: Color(0xFFE5EDF9),
      shade100: Color(0xFFC6DAF1),
      shade200: Color(0xFF94BDE5),
      shade300: Color(0xFF5B9BD5),
      shade400: Color(0xFF3781C7),
      shade500: Color(0xFF2663A3),
      shade600: Color(0xFF1F4F85),
      shade700: Color(0xFF1E446E),
      shade800: Color(0xFF1E3A5C),
      shade900: Color(0xFF14263D),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFFFFDEB),
      shade50: Color(0xFFFDF9C8),
      shade100: Color(0xFFFBF38C),
      shade200: Color(0xFFF9E650),
      shade300: Color(0xFFF7D628),
      shade400: Color(0xFFF2BD1D),
      shade500: Color(0xFFD69009),
      shade600: Color(0xFFB1670C),
      shade700: Color(0xFF905110),
      shade800: Color(0xFF764111),
      shade900: Color(0xFF442204),
    ),
    primaryMainLight: Color(0xFF2663A3),
    primaryMainDark: Color(0xFF2663A3),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFFFFFFFF),
  );

  /// BGN: Badan Gizi Nasional.
  ///
  /// Sumber CSS: `[data-brand='bgn']`.
  static const IddsBrand bgn = IddsBrand(
    id: 'bgn',
    name: 'BGN',
    primary: IddsColorScale(
      shade25: Color(0xFFEBF8FF),
      shade50: Color(0xFFD3EEFF),
      shade100: Color(0xFFB1E2FF),
      shade200: Color(0xFF7BD4FF),
      shade300: Color(0xFF3EB8FF),
      shade400: Color(0xFF1194FF),
      shade500: Color(0xFF0070FF),
      shade600: Color(0xFF0058FF),
      shade700: Color(0xFF0048CF),
      shade800: Color(0xFF0641A2),
      shade900: Color(0xFF071E49),
    ),
    secondary: IddsColorScale(
      shade25: Color(0xFFFBF9F1),
      shade50: Color(0xFFF5F1DF),
      shade100: Color(0xFFEBE0BD),
      shade200: Color(0xFFDECA93),
      shade300: Color(0xFFD1B06C),
      shade400: Color(0xFFC5974A),
      shade500: Color(0xFFB8833E),
      shade600: Color(0xFF996835),
      shade700: Color(0xFF7B5431),
      shade800: Color(0xFF64462A),
      shade900: Color(0xFF352315),
    ),
    primaryMainLight: Color(0xFF0058FF),
    primaryMainDark: Color(0xFF0058FF),
    onPrimaryLight: Color(0xFFFFFFFF),
    onPrimaryDark: Color(0xFFFFFFFF),
  );

  /// Semua brand resmi, dengan [neutral] sebagai yang pertama.
  static const List<IddsBrand> values = <IddsBrand>[
    neutral,
    inagov,
    inapas,
    inaku,
    panrb,
    bkn,
    lan,
    bgn,
  ];
}
