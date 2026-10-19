import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;

import '../tokens/idds_brand_tokens.g.dart';
import 'idds_color_scale.dart';
import 'idds_color_utils.dart';

/// Identitas warna sebuah lembaga: skala primary, skala secondary, dan
/// warna utama untuk mode terang dan gelap.
///
/// Pakai salah satu brand resmi ([IddsBrand.inagov], [IddsBrand.panrb], …)
/// atau buat brand sendiri dengan [IddsBrand.fromSeed],
/// [IddsBrand.fromPalette], atau [IddsBrand.fromScale].
@immutable
class IddsBrand {
  /// Membuat brand dengan semua nilai ditentukan manual.
  const IddsBrand({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.primaryMainLight,
    required this.primaryMainDark,
    required this.onPrimaryLight,
    required this.onPrimaryDark,
  });

  /// Membuat brand dari satu warna.
  ///
  /// Skala 25–900 dibuat di ruang warna OKLCH dengan kurva terang-gelap
  /// yang diturunkan dari rata-rata skala brand resmi IDDS. [seed] sendiri
  /// dipakai persis sebagai warna utama mode terang dan ditempatkan di
  /// langkah skala yang terangnya paling mirip.
  ///
  /// Warna utama mode gelap dan warna teks di atasnya dipilih otomatis
  /// berdasarkan kontras WCAG (lihat [IddsBrand.fromScale]).
  ///
  /// ```dart
  /// IddsBrand.fromSeed(const Color(0xFF7C3AED), name: 'Ungu');
  /// ```
  factory IddsBrand.fromSeed(
    Color seed, {
    String id = 'custom',
    String name = 'Custom',
    IddsColorScale? secondary,
  }) {
    final Oklch o = IddsColorUtils.toOklch(seed);
    int anchor = 0;
    for (int i = 1; i < _targetLightness.length; i++) {
      if ((_targetLightness[i] - o.l).abs() < (_targetLightness[anchor] - o.l).abs()) {
        anchor = i;
      }
    }
    final IddsColorScale scale = IddsColorScale.fromList(<Color>[
      for (int i = 0; i < _targetLightness.length; i++)
        if (i == anchor)
          seed
        else
          IddsColorUtils.fromOklch(
            Oklch(_targetLightness[i], o.c * _relativeChroma[i] / _relativeChroma[anchor], o.h),
          ),
    ]);
    return IddsBrand.fromScale(
      scale,
      mainStep: IddsColorScale.steps[anchor],
      id: id,
      name: name,
      secondary: secondary,
    );
  }

  /// Membuat brand dari palet IDDS, misalnya `IddsPrimitives.violet`.
  ///
  /// Langkah 25 dibuat dari palet (lihat [IddsPalette.toScale]).
  factory IddsBrand.fromPalette(
    IddsPalette palette, {
    int mainStep = 500,
    String id = 'custom',
    String name = 'Custom',
    IddsColorScale? secondary,
  }) {
    return IddsBrand.fromScale(
      palette.toScale(),
      mainStep: mainStep,
      id: id,
      name: name,
      secondary: secondary,
    );
  }

  /// Membuat brand dari skala 25–900 yang sudah jadi.
  ///
  /// - Warna utama mode terang = `scale[mainStep]`.
  /// - Warna utama mode gelap = langkah pertama dari [mainStep], 400, 300,
  ///   atau 200 (yang tidak lebih gelap dari [mainStep]) yang kontrasnya
  ///   minimal 3:1 terhadap latar gelap. Aturan ini mengikuti pola brand
  ///   resmi, yang turun ke langkah 400 atau 300 di dark mode.
  /// - Warna teks di atasnya = putih atau hitam, mana yang kontrasnya lebih
  ///   tinggi.
  /// - [secondary] bawaan sama dengan brand [neutral], seperti perilaku
  ///   `:root` di CSS IDDS.
  factory IddsBrand.fromScale(
    IddsColorScale scale, {
    int mainStep = 500,
    String id = 'custom',
    String name = 'Custom',
    IddsColorScale? secondary,
  }) {
    final Color mainLight = scale[mainStep];
    Color? mainDark;
    for (final int step in <int>[mainStep, 400, 300, 200]) {
      if (step > mainStep) continue;
      final Color candidate = scale[step];
      if (IddsColorUtils.contrastRatio(candidate, _darkBackground) >= 3) {
        mainDark = candidate;
        break;
      }
    }
    mainDark ??= scale[200];
    return IddsBrand(
      id: id,
      name: name,
      primary: scale,
      secondary: secondary ?? neutral.secondary,
      primaryMainLight: mainLight,
      primaryMainDark: mainDark,
      onPrimaryLight: IddsColorUtils.bestContrast(mainLight, _onColors),
      onPrimaryDark: IddsColorUtils.bestContrast(mainDark, _onColors),
    );
  }

  /// Tema bawaan IDDS (monokrom). Setara `default` di `@idds/react`.
  static const IddsBrand neutral = IddsBrandTokens.neutral;

  /// INAgov, Layanan Aparatur Negara.
  static const IddsBrand inagov = IddsBrandTokens.inagov;

  /// INApas, layanan paspor dan keimigrasian.
  static const IddsBrand inapas = IddsBrandTokens.inapas;

  /// INAku, layanan warga.
  static const IddsBrand inaku = IddsBrandTokens.inaku;

  /// Kementerian PAN RB.
  static const IddsBrand panrb = IddsBrandTokens.panrb;

  /// Badan Kepegawaian Negara.
  static const IddsBrand bkn = IddsBrandTokens.bkn;

  /// Lembaga Administrasi Negara.
  static const IddsBrand lan = IddsBrandTokens.lan;

  /// Badan Gizi Nasional.
  static const IddsBrand bgn = IddsBrandTokens.bgn;

  /// Semua brand resmi.
  static const List<IddsBrand> values = IddsBrandTokens.values;

  /// Latar dark mode IDDS (`--ina-background-primary` gelap).
  static const Color _darkBackground = Color(0xFF141414);
  static const List<Color> _onColors = <Color>[Color(0xFFFFFFFF), Color(0xFF141414)];

  /// Rata-rata lightness OKLCH per langkah dari brand resmi IDDS
  /// (INAgov, INApas, PANRB, BKN, LAN, BGN; INAku dikecualikan karena
  /// skalanya sengaja sangat gelap).
  static const List<double> _targetLightness = <double>[
    0.973,
    0.942,
    0.885,
    0.810,
    0.705,
    0.615,
    0.541,
    0.477,
    0.401,
    0.339,
    0.227,
  ];

  /// Rata-rata chroma relatif (terhadap chroma tertinggi) per langkah dari
  /// brand yang sama.
  static const List<double> _relativeChroma = <double>[
    0.060,
    0.129,
    0.270,
    0.484,
    0.777,
    0.926,
    0.970,
    0.889,
    0.719,
    0.549,
    0.340,
  ];

  /// ID unik, misalnya `'inagov'`.
  final String id;

  /// Nama untuk ditampilkan, misalnya `'INAgov'`.
  final String name;

  /// Skala warna primary (`--ina-primary-25` … `--ina-primary-900`).
  final IddsColorScale primary;

  /// Skala warna secondary (`--ina-secondary-25` … `--ina-secondary-900`).
  final IddsColorScale secondary;

  /// Warna utama di mode terang (`--ina-primary-primary`).
  final Color primaryMainLight;

  /// Warna utama di mode gelap.
  final Color primaryMainDark;

  /// Warna teks/ikon di atas [primaryMainLight].
  final Color onPrimaryLight;

  /// Warna teks/ikon di atas [primaryMainDark].
  final Color onPrimaryDark;

  /// Salinan dengan sebagian nilai diganti.
  IddsBrand copyWith({
    String? id,
    String? name,
    IddsColorScale? primary,
    IddsColorScale? secondary,
    Color? primaryMainLight,
    Color? primaryMainDark,
    Color? onPrimaryLight,
    Color? onPrimaryDark,
  }) {
    return IddsBrand(
      id: id ?? this.id,
      name: name ?? this.name,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      primaryMainLight: primaryMainLight ?? this.primaryMainLight,
      primaryMainDark: primaryMainDark ?? this.primaryMainDark,
      onPrimaryLight: onPrimaryLight ?? this.onPrimaryLight,
      onPrimaryDark: onPrimaryDark ?? this.onPrimaryDark,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IddsBrand &&
          other.id == id &&
          other.name == name &&
          other.primary == primary &&
          other.secondary == secondary &&
          other.primaryMainLight == primaryMainLight &&
          other.primaryMainDark == primaryMainDark &&
          other.onPrimaryLight == onPrimaryLight &&
          other.onPrimaryDark == onPrimaryDark;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        primary,
        secondary,
        primaryMainLight,
        primaryMainDark,
        onPrimaryLight,
        onPrimaryDark,
      );

  @override
  String toString() => 'IddsBrand($id)';
}
