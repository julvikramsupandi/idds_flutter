import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;

const Color _transparent = Color(0x00000000);
const Color _white = Color(0xFFFFFFFF);

/// Skala warna brand IDDS dengan 11 langkah: 25, 50, 100, …, 900.
///
/// Angka kecil = terang, angka besar = gelap.
@immutable
class IddsColorScale {
  /// Membuat skala dari 11 warna.
  const IddsColorScale({
    required this.shade25,
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
  });

  /// Membuat skala dari daftar 11 warna, urut dari 25 sampai 900.
  factory IddsColorScale.fromList(List<Color> colors) {
    if (colors.length != steps.length) {
      throw ArgumentError.value(
        colors.length,
        'colors',
        'Harus berisi ${steps.length} warna (25–900)',
      );
    }
    return IddsColorScale(
      shade25: colors[0],
      shade50: colors[1],
      shade100: colors[2],
      shade200: colors[3],
      shade300: colors[4],
      shade400: colors[5],
      shade500: colors[6],
      shade600: colors[7],
      shade700: colors[8],
      shade800: colors[9],
      shade900: colors[10],
    );
  }

  /// Skala transparan, dipakai sebagai nilai awal internal.
  static const IddsColorScale empty = IddsColorScale(
    shade25: _transparent,
    shade50: _transparent,
    shade100: _transparent,
    shade200: _transparent,
    shade300: _transparent,
    shade400: _transparent,
    shade500: _transparent,
    shade600: _transparent,
    shade700: _transparent,
    shade800: _transparent,
    shade900: _transparent,
  );

  /// Langkah-langkah yang tersedia, urut dari terang ke gelap.
  static const List<int> steps = <int>[
    25,
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
  ];

  final Color shade25;
  final Color shade50;
  final Color shade100;
  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500;
  final Color shade600;
  final Color shade700;
  final Color shade800;
  final Color shade900;

  /// Semua warna, urut dari 25 sampai 900.
  List<Color> get colors => <Color>[
        shade25,
        shade50,
        shade100,
        shade200,
        shade300,
        shade400,
        shade500,
        shade600,
        shade700,
        shade800,
        shade900,
      ];

  /// Warna untuk [step], misalnya `scale[500]`.
  Color operator [](int step) {
    final int index = steps.indexOf(step);
    if (index < 0) {
      throw ArgumentError.value(step, 'step', 'Langkah tidak valid; pilih salah satu dari $steps');
    }
    return colors[index];
  }

  /// Interpolasi linear antara dua skala.
  static IddsColorScale lerp(IddsColorScale a, IddsColorScale b, double t) {
    if (identical(a, b)) return a;
    final List<Color> ca = a.colors;
    final List<Color> cb = b.colors;
    return IddsColorScale.fromList(<Color>[
      for (int i = 0; i < ca.length; i++) Color.lerp(ca[i], cb[i], t)!,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IddsColorScale) return false;
    final List<Color> a = colors;
    final List<Color> b = other.colors;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(colors);

  @override
  String toString() => 'IddsColorScale(${colors.join(', ')})';
}

/// Palet warna primitive/semantik IDDS dengan 10 langkah: 50, 100, …, 900.
@immutable
class IddsPalette {
  /// Membuat palet dari 10 warna.
  const IddsPalette({
    required this.shade50,
    required this.shade100,
    required this.shade200,
    required this.shade300,
    required this.shade400,
    required this.shade500,
    required this.shade600,
    required this.shade700,
    required this.shade800,
    required this.shade900,
  });

  /// Membuat palet dari daftar 10 warna, urut dari 50 sampai 900.
  factory IddsPalette.fromList(List<Color> colors) {
    if (colors.length != steps.length) {
      throw ArgumentError.value(
        colors.length,
        'colors',
        'Harus berisi ${steps.length} warna (50–900)',
      );
    }
    return IddsPalette(
      shade50: colors[0],
      shade100: colors[1],
      shade200: colors[2],
      shade300: colors[3],
      shade400: colors[4],
      shade500: colors[5],
      shade600: colors[6],
      shade700: colors[7],
      shade800: colors[8],
      shade900: colors[9],
    );
  }

  /// Langkah-langkah yang tersedia, urut dari terang ke gelap.
  static const List<int> steps = <int>[
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
  ];

  final Color shade50;
  final Color shade100;
  final Color shade200;
  final Color shade300;
  final Color shade400;
  final Color shade500;
  final Color shade600;
  final Color shade700;
  final Color shade800;
  final Color shade900;

  /// Semua warna, urut dari 50 sampai 900.
  List<Color> get colors => <Color>[
        shade50,
        shade100,
        shade200,
        shade300,
        shade400,
        shade500,
        shade600,
        shade700,
        shade800,
        shade900,
      ];

  /// Warna untuk [step], misalnya `palette[500]`.
  Color operator [](int step) {
    final int index = steps.indexOf(step);
    if (index < 0) {
      throw ArgumentError.value(step, 'step', 'Langkah tidak valid; pilih salah satu dari $steps');
    }
    return colors[index];
  }

  /// Mengubah palet menjadi [IddsColorScale] 11 langkah.
  ///
  /// Langkah 25 tidak ada di palet primitive, sehingga diambil dari
  /// [shade25] bila diberikan, atau dibuat dari setengah jalan antara
  /// putih dan [shade50].
  IddsColorScale toScale({Color? shade25}) {
    return IddsColorScale.fromList(<Color>[
      shade25 ?? Color.lerp(_white, shade50, 0.5)!,
      ...colors,
    ]);
  }

  /// Interpolasi linear antara dua palet.
  static IddsPalette lerp(IddsPalette a, IddsPalette b, double t) {
    if (identical(a, b)) return a;
    final List<Color> ca = a.colors;
    final List<Color> cb = b.colors;
    return IddsPalette.fromList(<Color>[
      for (int i = 0; i < ca.length; i++) Color.lerp(ca[i], cb[i], t)!,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IddsPalette) return false;
    final List<Color> a = colors;
    final List<Color> b = other.colors;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(colors);

  @override
  String toString() => 'IddsPalette(${colors.join(', ')})';
}
