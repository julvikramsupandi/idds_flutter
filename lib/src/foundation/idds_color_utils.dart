import 'dart:math' as math;
import 'dart:ui' show Color;

/// Utilitas warna: kontras WCAG dan konversi ruang warna OKLCH.
abstract final class IddsColorUtils {
  /// Luminans relatif WCAG 2.x (0 = hitam, 1 = putih).
  static double relativeLuminance(Color color) {
    return 0.2126 * _toLinear(color.r) + 0.7152 * _toLinear(color.g) + 0.0722 * _toLinear(color.b);
  }

  /// Rasio kontras WCAG 2.x antara dua warna (1–21).
  ///
  /// Teks normal butuh minimal 4.5, teks besar dan komponen UI minimal 3.
  static double contrastRatio(Color a, Color b) {
    final double la = relativeLuminance(a);
    final double lb = relativeLuminance(b);
    final double lighter = math.max(la, lb);
    final double darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Memilih warna dari [candidates] yang kontrasnya paling tinggi terhadap
  /// [background].
  static Color bestContrast(Color background, List<Color> candidates) {
    Color best = candidates.first;
    double bestRatio = contrastRatio(background, best);
    for (final Color c in candidates.skip(1)) {
      final double ratio = contrastRatio(background, c);
      if (ratio > bestRatio) {
        best = c;
        bestRatio = ratio;
      }
    }
    return best;
  }

  /// Mengubah warna sRGB ke OKLCH.
  static Oklch toOklch(Color color) {
    final double r = _toLinear(color.r);
    final double g = _toLinear(color.g);
    final double b = _toLinear(color.b);
    final double l = _cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
    final double m = _cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
    final double s = _cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
    final double lightness = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s;
    final double aa = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
    final double bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;
    return Oklch(lightness, math.sqrt(aa * aa + bb * bb), math.atan2(bb, aa));
  }

  /// Mengubah OKLCH ke sRGB. Bila warna berada di luar gamut sRGB, chroma
  /// dikurangi sampai masuk gamut (lightness dan hue dipertahankan).
  static Color fromOklch(Oklch value, {double alpha = 1}) {
    List<double> rgb = _oklchToLinear(value.l, value.c, value.h);
    if (!_inGamut(rgb)) {
      double lo = 0;
      double hi = value.c;
      for (int i = 0; i < 24; i++) {
        final double mid = (lo + hi) / 2;
        if (_inGamut(_oklchToLinear(value.l, mid, value.h))) {
          lo = mid;
        } else {
          hi = mid;
        }
      }
      rgb = _oklchToLinear(value.l, lo, value.h);
    }
    int channel(double linear) => (_fromLinear(linear.clamp(0.0, 1.0)).clamp(0.0, 1.0) * 255).round();
    return Color.fromARGB((alpha * 255).round(), channel(rgb[0]), channel(rgb[1]), channel(rgb[2]));
  }

  static double _toLinear(double c) => c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  static double _fromLinear(double c) =>
      c <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1 / 2.4).toDouble() - 0.055;

  static double _cbrt(double x) => x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();

  static List<double> _oklchToLinear(double lightness, double chroma, double hue) {
    final double aa = chroma * math.cos(hue);
    final double bb = chroma * math.sin(hue);
    final double l = math.pow(lightness + 0.3963377774 * aa + 0.2158037573 * bb, 3).toDouble();
    final double m = math.pow(lightness - 0.1055613458 * aa - 0.0638541728 * bb, 3).toDouble();
    final double s = math.pow(lightness - 0.0894841775 * aa - 1.2914855480 * bb, 3).toDouble();
    return <double>[
      4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
      -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
      -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    ];
  }

  static bool _inGamut(List<double> rgb) => rgb.every((double c) => c >= -1e-4 && c <= 1 + 1e-4);
}

/// Warna dalam ruang OKLCH: lightness [l] (0–1), chroma [c], hue [h] (radian).
class Oklch {
  /// Membuat nilai OKLCH.
  const Oklch(this.l, this.c, this.h);

  /// Lightness perseptual, 0 (hitam) sampai 1 (putih).
  final double l;

  /// Chroma (intensitas warna), 0 = abu-abu.
  final double c;

  /// Hue dalam radian.
  final double h;

  @override
  String toString() => 'Oklch(l: ${l.toStringAsFixed(3)}, c: ${c.toStringAsFixed(3)}, h: ${h.toStringAsFixed(3)})';
}
