import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/widgets.dart';

/// Ikon garis (stroke) dalam kotak 24×24, ditulis sebagai path SVG.
///
/// Ikon bawaan IDDS diambil dari [Tabler Icons](https://tabler.io/icons)
/// (MIT), pustaka ikon resmi IDDS.
@immutable
class IddsIconData {
  /// Membuat ikon dari daftar path SVG (koordinat 0–24).
  const IddsIconData(this.paths);

  /// Path SVG. Perintah yang didukung: M, L, H, V, C, A, Z (huruf besar
  /// dan kecil).
  final List<String> paths;

  @override
  bool operator ==(Object other) => other is IddsIconData && listEquals(other.paths, paths);

  @override
  int get hashCode => Object.hashAll(paths);
}

/// Ikon yang dipakai komponen IDDS.
abstract final class IddsIcons {
  /// `check`.
  static const IddsIconData check = IddsIconData(<String>['M5 12l5 5l10 -10']);

  /// `minus`.
  static const IddsIconData minus = IddsIconData(<String>['M5 12l14 0']);

  /// `x`.
  static const IddsIconData x = IddsIconData(<String>['M18 6l-12 12', 'M6 6l12 12']);

  /// `chevron-left`.
  static const IddsIconData chevronLeft = IddsIconData(<String>['M15 6l-6 6l6 6']);

  /// `chevron-right`.
  static const IddsIconData chevronRight = IddsIconData(<String>['M9 6l6 6l-6 6']);

  /// `chevron-down`.
  static const IddsIconData chevronDown = IddsIconData(<String>['M6 9l6 6l6 -6']);

  /// `chevron-up`.
  static const IddsIconData chevronUp = IddsIconData(<String>['M6 15l6 -6l6 6']);

  /// `search`.
  static const IddsIconData search = IddsIconData(<String>[
    'M10 10m-7 0a7 7 0 1 0 14 0a7 7 0 1 0 -14 0',
    'M21 21l-6 -6',
  ]);

  /// `calendar`.
  static const IddsIconData calendar = IddsIconData(<String>[
    'M4 7a2 2 0 0 1 2 -2h12a2 2 0 0 1 2 2v12a2 2 0 0 1 -2 2h-12a2 2 0 0 1 -2 -2v-12z',
    'M16 3v4',
    'M8 3v4',
    'M4 11h16',
    'M11 15h1',
    'M12 15v3',
  ]);

  /// `upload`.
  static const IddsIconData upload = IddsIconData(<String>[
    'M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2 -2v-2',
    'M7 9l5 -5l5 5',
    'M12 4l0 12',
  ]);

  /// `trash`.
  static const IddsIconData trash = IddsIconData(<String>[
    'M4 7l16 0',
    'M10 11l0 6',
    'M14 11l0 6',
    'M5 7l1 12a2 2 0 0 0 2 2h8a2 2 0 0 0 2 -2l1 -12',
    'M9 7v-3a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v3',
  ]);

  /// `refresh`.
  static const IddsIconData refresh = IddsIconData(<String>['M4.05 11a8 8 0 1 1 .5 4m-.5 5v-5h5']);

  /// `circle-check`.
  static const IddsIconData circleCheck = IddsIconData(<String>[
    'M3 12a9 9 0 1 0 18 0a9 9 0 1 0 -18 0',
    'M9 12l2 2l4 -4',
  ]);

  /// `circle-x`.
  static const IddsIconData circleX = IddsIconData(<String>[
    'M3 12a9 9 0 1 0 18 0a9 9 0 1 0 -18 0',
    'M10 10l4 4m0 -4l-4 4',
  ]);

  /// `file`.
  static const IddsIconData file = IddsIconData(<String>[
    'M14 3v4a1 1 0 0 0 1 1h4',
    'M17 21h-10a2 2 0 0 1 -2 -2v-14a2 2 0 0 1 2 -2h7l5 5v11a2 2 0 0 1 -2 2z',
  ]);

  /// `arrow-up`.
  static const IddsIconData arrowUp = IddsIconData(<String>['M12 5l0 14', 'M16 9l-4 -4', 'M8 9l4 -4']);

  /// `arrow-down`.
  static const IddsIconData arrowDown = IddsIconData(<String>['M12 5l0 14', 'M16 15l-4 4', 'M8 15l4 4']);

  /// `eye`.
  static const IddsIconData eye = IddsIconData(<String>[
    'M10 12a2 2 0 1 0 4 0a2 2 0 0 0 -4 0',
    'M21 12c-2.4 4 -5.4 6 -9 6c-3.6 0 -6.6 -2 -9 -6c2.4 -4 5.4 -6 9 -6c3.6 0 6.6 2 9 6',
  ]);

  /// `eye-off`.
  static const IddsIconData eyeOff = IddsIconData(<String>[
    'M10.585 10.587a2 2 0 0 0 2.829 2.828',
    'M16.681 16.673a8.717 8.717 0 0 1 -4.681 1.327c-3.6 0 -6.6 -2 -9 -6c1.272 -2.12 2.712 -3.678 4.32 -4.674m2.86 -1.146a9.055 9.055 0 0 1 1.82 -.18c3.6 0 6.6 2 9 6c-.666 1.11 -1.379 2.067 -2.138 2.87',
    'M3 3l18 18',
  ]);

  /// `clock`.
  static const IddsIconData clock = IddsIconData(<String>[
    'M3 12a9 9 0 1 0 18 0a9 9 0 0 0 -18 0',
    'M12 7v5l3 3',
  ]);

  /// `sun`.
  static const IddsIconData sun = IddsIconData(<String>[
    'M12 12m-4 0a4 4 0 1 0 8 0a4 4 0 1 0 -8 0',
    'M3 12h1m8 -9v1m8 8h1m-9 8v1m-6.4 -15.4l.7 .7m12.1 -.7l-.7 .7m0 11.4l.7 .7m-12.1 -.7l-.7 .7',
  ]);

  /// `moon`.
  static const IddsIconData moon = IddsIconData(<String>[
    'M12 3c.132 0 .263 0 .393 0a7.5 7.5 0 0 0 7.92 12.446a9 9 0 1 1 -8.313 -12.454z',
  ]);

  /// `chevrons-left`.
  static const IddsIconData chevronsLeft = IddsIconData(<String>['M11 7l-5 5l5 5', 'M17 7l-5 5l5 5']);

  /// `chevrons-right`.
  static const IddsIconData chevronsRight = IddsIconData(<String>['M7 7l5 5l-5 5', 'M13 7l5 5l-5 5']);

  /// `info-circle`.
  static const IddsIconData infoCircle = IddsIconData(<String>[
    'M3 12a9 9 0 1 0 18 0a9 9 0 0 0 -18 0',
    'M12 9h.01',
    'M11 12h1v4h1',
  ]);

  /// `alert-circle`.
  static const IddsIconData alertCircle = IddsIconData(<String>[
    'M3 12a9 9 0 1 0 18 0a9 9 0 0 0 -18 0',
    'M12 8v4',
    'M12 16h.01',
  ]);

  /// `alert-triangle`.
  static const IddsIconData alertTriangle = IddsIconData(<String>[
    'M12 9v4',
    'M10.363 3.591l-8.106 13.534a1.914 1.914 0 0 0 1.636 2.871h16.214a1.914 1.914 0 0 0 1.636 -2.87l-8.106 -13.536a1.914 1.914 0 0 0 -3.274 0z',
    'M12 16h.01',
  ]);

  /// `box` (garis putus), ikon Alert varian neutral.
  static const IddsIconData box = IddsIconData(<String>[
    'M6 17.6l-2 -1.1v-2.5',
    'M4 10v-2.5l2 -1.1',
    'M10 4.1l2 -1.1l2 1.1',
    'M18 6.4l2 1.1v2.5',
    'M20 14v2.5l-2 1.12',
    'M14 19.9l-2 1.1l-2 -1.1',
    'M12 12l2 -1.1',
    'M18 8.6l2 -1.1',
    'M12 12l0 2.5',
    'M12 18.5l0 2.5',
    'M12 12l-2 -1.12',
    'M6 8.6l-2 -1.1',
  ]);
}

/// Menggambar [IddsIconData].
///
/// Ukuran dan warna bawaan diambil dari [IconTheme] terdekat, sama seperti
/// widget `Icon`.
class IddsIcon extends StatelessWidget {
  /// Membuat ikon.
  const IddsIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 2,
    this.semanticLabel,
  });

  /// Data ikon.
  final IddsIconData icon;

  /// Ukuran sisi dalam pixel.
  final double? size;

  /// Warna garis.
  final Color? color;

  /// Tebal garis dalam satuan kotak 24×24 (seperti atribut `stroke` Tabler).
  final double strokeWidth;

  /// Label untuk pembaca layar. Bila `null`, ikon dianggap dekoratif.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);
    final double s = size ?? theme.size ?? 24;
    final Color c = color ?? theme.color ?? const Color(0xFF000000);
    final Widget painted = SizedBox.square(
      dimension: s,
      child: CustomPaint(painter: _IconPainter(icon, c, strokeWidth)),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: painted);
    return Semantics(label: semanticLabel, child: painted);
  }
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.color, this.strokeWidth);

  final IddsIconData icon;
  final Color color;
  final double strokeWidth;

  static final Map<String, Path> _cache = <String, Path>{};

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide / 24;
    canvas.save();
    canvas.scale(scale);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      ..isAntiAlias = true;
    for (final String d in icon.paths) {
      canvas.drawPath(_cache.putIfAbsent(d, () => parseSvgPath(d)), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}

/// Mengubah atribut `d` SVG menjadi [Path].
///
/// Mendukung M, L, H, V, C, A, dan Z (absolut dan relatif). Cukup untuk ikon
/// garis seperti Tabler.
Path parseSvgPath(String d) {
  final Path path = Path();
  final List<String> tokens = RegExp(r'[MmLlHhVvCcAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
      .allMatches(d)
      .map((Match m) => m.group(0)!)
      .toList();
  int i = 0;
  String command = 'M';
  double x = 0;
  double y = 0;
  double startX = 0;
  double startY = 0;

  bool isCommand(String t) => RegExp(r'^[A-Za-z]$').hasMatch(t);
  double next() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    if (isCommand(tokens[i])) command = tokens[i++];
    final bool rel = command == command.toLowerCase();
    switch (command.toUpperCase()) {
      case 'M':
        final double nx = next() + (rel ? x : 0);
        final double ny = next() + (rel ? y : 0);
        path.moveTo(nx, ny);
        x = startX = nx;
        y = startY = ny;
        // Pasangan koordinat berikutnya setelah M diperlakukan sebagai L.
        command = rel ? 'l' : 'L';
      case 'L':
        x = next() + (rel ? x : 0);
        y = next() + (rel ? y : 0);
        path.lineTo(x, y);
      case 'H':
        x = next() + (rel ? x : 0);
        path.lineTo(x, y);
      case 'V':
        y = next() + (rel ? y : 0);
        path.lineTo(x, y);
      case 'C':
        final double ox = rel ? x : 0;
        final double oy = rel ? y : 0;
        final double x1 = next() + ox;
        final double y1 = next() + oy;
        final double x2 = next() + ox;
        final double y2 = next() + oy;
        x = next() + ox;
        y = next() + oy;
        path.cubicTo(x1, y1, x2, y2, x, y);
      case 'A':
        final double rx = next();
        final double ry = next();
        final double rotation = next();
        final bool largeArc = next() != 0;
        final bool sweep = next() != 0;
        x = next() + (rel ? x : 0);
        y = next() + (rel ? y : 0);
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rotation,
          largeArc: largeArc,
          clockwise: sweep,
        );
      case 'Z':
        path.close();
        x = startX;
        y = startY;
        if (i < tokens.length && !isCommand(tokens[i])) {
          throw FormatException('Angka setelah Z tanpa perintah baru', d);
        }
      default:
        throw FormatException('Perintah path SVG tidak didukung: $command', d);
    }
  }
  return path;
}
