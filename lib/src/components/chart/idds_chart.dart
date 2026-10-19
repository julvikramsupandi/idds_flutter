import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/gestures.dart' show PointerHoverEvent;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_chart_colors.g.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Satu seri data untuk [IddsLineChart] dan [IddsBarChart].
@immutable
class IddsChartSeries {
  /// Membuat seri.
  const IddsChartSeries({required this.name, required this.values, this.color});

  /// Nama seri (legenda dan tooltip).
  final String name;

  /// Nilai per kategori, sejajar dengan `labels` grafik. `null` = kosong.
  final List<double?> values;

  /// Warna. Bawaan: [IddsChartColors.categorical] sesuai urutan seri.
  final Color? color;

  @override
  bool operator ==(Object other) =>
      other is IddsChartSeries && other.name == name && other.color == color && listEquals(other.values, values);

  @override
  int get hashCode => Object.hash(name, color, Object.hashAll(values));
}

/// Satu potong [IddsPieChart].
@immutable
class IddsChartSlice {
  /// Membuat potongan.
  const IddsChartSlice({required this.label, required this.value, this.color});

  /// Nama kategori.
  final String label;

  /// Nilai (bukan persen).
  final double value;

  /// Warna. Bawaan: [IddsChartColors.categorical] sesuai urutan.
  final Color? color;
}

/// Format angka ringkas berbahasa Indonesia: 950, 1,2 rb, 3,4 jt, 5 M, 1,1 T.
String iddsCompactNumber(num value) {
  final double v = value.toDouble();
  final double a = v.abs();
  String fmt(double n, String unit) {
    final String s = (n >= 100 || n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1)).replaceAll('.', ',');
    return '${v < 0 ? '-' : ''}$s $unit';
  }

  if (a >= 1e12) return fmt(a / 1e12, 'T');
  if (a >= 1e9) return fmt(a / 1e9, 'M');
  if (a >= 1e6) return fmt(a / 1e6, 'jt');
  if (a >= 1e3) return fmt(a / 1e3, 'rb');
  if (a == a.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(a < 10 ? 2 : 1).replaceAll('.', ',');
}

Color _seriesColor(int i, Color? custom) =>
    custom ?? IddsChartColors.categorical[i % IddsChartColors.categorical.length];

/// Skala sumbu Y dengan angka bulat.
class _Scale {
  _Scale(double dataMin, double dataMax, {int ticks = 4}) {
    double lo = math.min(0, dataMin);
    double hi = math.max(0, dataMax);
    if (hi == lo) hi = lo + 1;
    final double rawStep = (hi - lo) / ticks;
    final double mag = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final double norm = rawStep / mag;
    final double nice = norm <= 1 ? 1 : norm <= 2 ? 2 : norm <= 2.5 ? 2.5 : norm <= 5 ? 5 : 10;
    step = nice * mag;
    lo = (lo / step).floor() * step;
    hi = (hi / step).ceil() * step;
    min = lo;
    max = hi;
  }

  late final double min;
  late final double max;
  late final double step;

  List<double> get ticks => <double>[for (double v = min; v <= max + step / 2; v += step) v];

  double fraction(double v) => (v - min) / (max - min);
}

TextPainter _text(String s, TextStyle style, {double maxWidth = double.infinity}) =>
    TextPainter(text: TextSpan(text: s, style: style), textDirection: TextDirection.ltr, maxLines: 1, ellipsis: '…')
      ..layout(maxWidth: maxWidth);

// ---------------------------------------------------------------------------
// Bagian bersama: legenda, tooltip, bingkai interaktif.
// ---------------------------------------------------------------------------

enum _KeyShape { line, box }

class _Legend extends StatelessWidget {
  const _Legend({required this.items, required this.shape});

  final List<(String, Color)> items;
  final _KeyShape shape;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Wrap(
      spacing: IddsSpacing.s16,
      runSpacing: IddsSpacing.s4,
      children: <Widget>[
        for (final (String name, Color color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: IddsSpacing.s6,
            children: <Widget>[
              Container(
                width: shape == _KeyShape.line ? 14 : 10,
                height: shape == _KeyShape.line ? 2 : 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(shape == _KeyShape.line ? 1 : 2),
                ),
              ),
              Text(
                name,
                style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary),
              ),
            ],
          ),
      ],
    );
  }
}

/// Isi tooltip: judul, lalu baris nilai (nilai tebal, nama sekunder).
class _TooltipCard extends StatelessWidget {
  const _TooltipCard({required this.title, required this.rows});

  final String title;
  final List<(String, String, Color)> rows;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12, vertical: IddsSpacing.s8),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(IddsRadius.lg),
        border: Border.all(color: c.strokePrimary),
        boxShadow: IddsShadow.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: IddsSpacing.s4,
        children: <Widget>[
          Text(
            title,
            style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary),
          ),
          for (final (String name, String value, Color color) in rows)
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: IddsSpacing.s6,
              children: <Widget>[
                Container(width: 10, height: 2, color: color),
                Text(
                  value,
                  style: theme.textStyle(
                    fontSize: IddsFontSize.xs,
                    lineHeight: IddsLineHeight.xs,
                    fontWeight: IddsFontWeight.semibold,
                    color: c.contentPrimary,
                  ),
                ),
                Flexible(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Menempatkan tooltip di dekat titik [anchor] dan menjaganya tetap di dalam
/// area grafik.
class _TooltipLayout extends SingleChildLayoutDelegate {
  _TooltipLayout(this.anchor);

  final Offset anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = anchor.dx + 12;
    if (x + childSize.width > size.width) x = anchor.dx - 12 - childSize.width;
    double y = anchor.dy - childSize.height - 8;
    if (y < 0) y = anchor.dy + 12;
    return Offset(
      x.clamp(0, math.max(0, size.width - childSize.width)),
      y.clamp(0, math.max(0, size.height - childSize.height)),
    );
  }

  @override
  bool shouldRelayout(_TooltipLayout oldDelegate) => oldDelegate.anchor != anchor;
}

/// Bingkai interaktif: animasi masuk, deteksi sorot/ketuk, dan tooltip.
class _InteractiveChart extends StatefulWidget {
  const _InteractiveChart({
    required this.height,
    required this.painterBuilder,
    required this.hitTest,
    required this.tooltipBuilder,
    required this.semanticLabel,
    this.data,
  });

  final double height;

  /// Membuat painter untuk ukuran, kemajuan animasi, dan indeks yang disorot.
  final CustomPainter Function(Size size, double progress, int? hovered) painterBuilder;

  /// Indeks yang ditunjuk posisi [p], dan titik jangkar tooltip.
  final (int, Offset)? Function(Size size, Offset p) hitTest;

  /// Isi tooltip untuk indeks.
  final Widget Function(int index) tooltipBuilder;

  final String semanticLabel;

  /// Data grafik; animasi diulang bila berubah.
  final Object? data;

  @override
  State<_InteractiveChart> createState() => _InteractiveChartState();
}

class _InteractiveChartState extends State<_InteractiveChart> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
    ..forward();
  int? _hovered;
  Offset? _anchor;

  @override
  void didUpdateWidget(_InteractiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _anim.forward(from: 0);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _update(Size size, Offset p) {
    final (int, Offset)? hit = widget.hitTest(size, p);
    setState(() {
      _hovered = hit?.$1;
      _anchor = hit?.$2;
    });
  }

  void _clear() {
    if (_hovered != null) setState(() => _hovered = null);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: SizedBox(
        height: widget.height,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size size = Size(constraints.maxWidth, widget.height);
            return TapRegion(
              onTapOutside: (_) => _clear(),
              child: MouseRegion(
              onHover: (PointerHoverEvent e) => _update(size, e.localPosition),
              onExit: (_) => _clear(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails d) => _update(size, d.localPosition),
                // Hanya seret mendatar, agar gulir halaman tetap berfungsi.
                onHorizontalDragUpdate: (DragUpdateDetails d) => _update(size, d.localPosition),
                onHorizontalDragEnd: (_) => _clear(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _anim,
                        builder: (BuildContext context, Widget? _) => CustomPaint(
                          painter: widget.painterBuilder(size, Curves.easeOutCubic.transform(_anim.value), _hovered),
                        ),
                      ),
                    ),
                    if (_hovered != null && _anchor != null)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomSingleChildLayout(
                            delegate: _TooltipLayout(_anchor!),
                            child: widget.tooltipBuilder(_hovered!),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grafik kartesius (garis & batang tegak).
// ---------------------------------------------------------------------------

/// Tata letak area plot bersama.
class _Plot {
  _Plot({
    required Size size,
    required this.scale,
    required this.labels,
    required this.axisStyle,
    required this.format,
    required this.band,
  }) {
    double yLabelWidth = 0;
    for (final double t in scale.ticks) {
      yLabelWidth = math.max(yLabelWidth, _text(format(t), axisStyle).width);
    }
    final double xLabelHeight = _text('0', axisStyle).height;
    rect = Rect.fromLTRB(yLabelWidth + 8, 8, size.width - 8, size.height - xLabelHeight - 8);
  }

  final _Scale scale;
  final List<String> labels;
  final TextStyle axisStyle;
  final String Function(double) format;

  /// Batang: kategori menempati pita; garis: titik di ujung-ujung.
  final bool band;
  late final Rect rect;

  int get n => labels.length;

  double x(int i) {
    if (band) return rect.left + rect.width * (i + 0.5) / n;
    if (n <= 1) return rect.center.dx;
    return rect.left + rect.width * i / (n - 1);
  }

  double y(double v) => rect.bottom - rect.height * scale.fraction(v);

  int nearest(double px) {
    if (n == 0) return 0;
    if (band) return ((px - rect.left) / rect.width * n).floor().clamp(0, n - 1);
    if (n == 1) return 0;
    return ((px - rect.left) / rect.width * (n - 1)).round().clamp(0, n - 1);
  }

  void paintAxes(Canvas canvas, Color grid) {
    final Paint gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final double t in scale.ticks) {
      final double yy = y(t).roundToDouble() + 0.5;
      canvas.drawLine(Offset(rect.left, yy), Offset(rect.right, yy), gridPaint);
      final TextPainter tp = _text(format(t), axisStyle);
      tp.paint(canvas, Offset(rect.left - 8 - tp.width, y(t) - tp.height / 2));
    }
    // Label X: lewati sebagian bila tidak muat.
    if (n == 0) return;
    double maxW = 0;
    for (final String l in labels) {
      maxW = math.max(maxW, _text(l, axisStyle).width);
    }
    final double slot = band ? rect.width / n : (n > 1 ? rect.width / (n - 1) : rect.width);
    final int every = math.max(1, ((maxW + 8) / math.max(1, slot)).ceil());
    for (int i = 0; i < n; i += every) {
      final TextPainter tp = _text(labels[i], axisStyle, maxWidth: math.max(slot * every - 4, 24));
      double left = x(i) - tp.width / 2;
      left = left.clamp(0, rect.right + 8 - tp.width);
      tp.paint(canvas, Offset(left, rect.bottom + 6));
    }
  }
}

(double, double) _range(List<IddsChartSeries> series, {bool stacked = false, int count = 0}) {
  double lo = 0;
  double hi = 0;
  if (stacked) {
    for (int i = 0; i < count; i++) {
      double pos = 0;
      double neg = 0;
      for (final IddsChartSeries s in series) {
        final double v = i < s.values.length ? (s.values[i] ?? 0) : 0;
        if (v >= 0) {
          pos += v;
        } else {
          neg += v;
        }
      }
      hi = math.max(hi, pos);
      lo = math.min(lo, neg);
    }
  } else {
    for (final IddsChartSeries s in series) {
      for (final double? v in s.values) {
        if (v == null) continue;
        hi = math.max(hi, v);
        lo = math.min(lo, v);
      }
    }
  }
  return (lo, hi);
}

/// Grafik garis (Line Chart IDDS), opsional dengan area di bawah garis.
///
/// ```dart
/// IddsLineChart(
///   labels: const ['Jan', 'Feb', 'Mar', 'Apr'],
///   series: const [
///     IddsChartSeries(name: 'Permohonan', values: [120, 180, 150, 210]),
///     IddsChartSeries(name: 'Selesai', values: [100, 160, 140, 190]),
///   ],
/// )
/// ```
///
/// Menyorot atau mengetuk grafik menampilkan garis bantu dan tooltip berisi
/// nilai semua seri pada kategori itu.
class IddsLineChart extends StatelessWidget {
  /// Membuat grafik garis.
  const IddsLineChart({
    super.key,
    required this.labels,
    required this.series,
    this.height = 240,
    this.area = false,
    this.showPoints = false,
    this.curved = false,
    this.valueFormat = iddsCompactNumber,
    this.showLegend,
    this.semanticLabel,
  });

  /// Label kategori pada sumbu X (mis. bulan).
  final List<String> labels;

  /// Seri data.
  final List<IddsChartSeries> series;

  /// Tinggi area grafik (tanpa legenda).
  final double height;

  /// Isi area di bawah garis (10% warna seri).
  final bool area;

  /// Tampilkan titik di setiap nilai.
  final bool showPoints;

  /// Garis melengkung halus.
  final bool curved;

  /// Format nilai sumbu Y dan tooltip.
  final String Function(double value) valueFormat;

  /// Tampilkan legenda. Bawaan: bila lebih dari satu seri.
  final bool? showLegend;

  /// Ringkasan untuk pembaca layar.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final (double lo, double hi) = _range(series);
    final _Scale scale = _Scale(lo, hi);
    final TextStyle axis = theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary);
    final List<Color> colors = <Color>[for (int i = 0; i < series.length; i++) _seriesColor(i, series[i].color)];
    _Plot plotFor(Size size) => _Plot(size: size, scale: scale, labels: labels, axisStyle: axis, format: valueFormat, band: false);

    final Widget chart = _InteractiveChart(
      height: height,
      data: Object.hashAll(<Object>[...series, ...labels]),
      semanticLabel: semanticLabel ?? _describe('Grafik garis', labels, series, valueFormat),
      painterBuilder: (Size size, double t, int? hovered) => _LinePainter(
        plot: plotFor(size),
        series: series,
        colors: colors,
        progress: t,
        hovered: hovered,
        area: area,
        showPoints: showPoints,
        curved: curved,
        grid: c.strokePrimary,
        surface: c.backgroundPrimary,
        crosshair: c.strokeSecondary,
      ),
      hitTest: (Size size, Offset p) {
        if (labels.isEmpty) return null;
        final _Plot plot = plotFor(size);
        final int i = plot.nearest(p.dx);
        double top = plot.rect.bottom;
        for (final IddsChartSeries s in series) {
          final double? v = i < s.values.length ? s.values[i] : null;
          if (v != null) top = math.min(top, plot.y(v));
        }
        return (i, Offset(plot.x(i), top));
      },
      tooltipBuilder: (int i) => _TooltipCard(
        title: labels[i],
        rows: <(String, String, Color)>[
          for (int s = 0; s < series.length; s++)
            if (i < series[s].values.length && series[s].values[i] != null)
              (series[s].name, valueFormat(series[s].values[i]!), colors[s]),
        ],
      ),
    );

    return _withLegend(
      showLegend ?? series.length > 1,
      <(String, Color)>[for (int i = 0; i < series.length; i++) (series[i].name, colors[i])],
      area ? _KeyShape.box : _KeyShape.line,
      chart,
    );
  }
}

Widget _withLegend(bool show, List<(String, Color)> items, _KeyShape shape, Widget chart) {
  if (!show) return chart;
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: IddsSpacing.s12,
    children: <Widget>[_Legend(items: items, shape: shape), chart],
  );
}

String _describe(String kind, List<String> labels, List<IddsChartSeries> series, String Function(double) format) {
  final StringBuffer b = StringBuffer('$kind. ');
  for (final IddsChartSeries s in series) {
    b.write('${s.name}: ');
    b.write(<String>[
      for (int i = 0; i < labels.length && i < s.values.length; i++)
        if (s.values[i] != null) '${labels[i]} ${format(s.values[i]!)}',
    ].join(', '));
    b.write('. ');
  }
  return b.toString();
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.plot,
    required this.series,
    required this.colors,
    required this.progress,
    required this.hovered,
    required this.area,
    required this.showPoints,
    required this.curved,
    required this.grid,
    required this.surface,
    required this.crosshair,
  });

  final _Plot plot;
  final List<IddsChartSeries> series;
  final List<Color> colors;
  final double progress;
  final int? hovered;
  final bool area;
  final bool showPoints;
  final bool curved;
  final Color grid;
  final Color surface;
  final Color crosshair;

  @override
  void paint(Canvas canvas, Size size) {
    plot.paintAxes(canvas, grid);
    if (plot.n == 0) return;

    if (hovered != null) {
      final double hx = plot.x(hovered!);
      canvas.drawLine(
        Offset(hx, plot.rect.top),
        Offset(hx, plot.rect.bottom),
        Paint()
          ..color = crosshair
          ..strokeWidth = 1,
      );
    }

    // Animasi: garis "tumbuh" dari bawah.
    double ay(double v) => plot.rect.bottom - (plot.rect.bottom - plot.y(v)) * progress;

    for (int s = 0; s < series.length; s++) {
      final List<double?> values = series[s].values;
      final List<List<Offset>> segments = <List<Offset>>[<Offset>[]];
      for (int i = 0; i < plot.n && i < values.length; i++) {
        final double? v = values[i];
        if (v == null) {
          if (segments.last.isNotEmpty) segments.add(<Offset>[]);
          continue;
        }
        segments.last.add(Offset(plot.x(i), ay(v)));
      }
      for (final List<Offset> pts in segments) {
        if (pts.isEmpty) continue;
        final Path line = _path(pts);
        if (area && pts.length > 1) {
          final Path fill = Path.from(line)
            ..lineTo(pts.last.dx, plot.y(math.max(plot.scale.min, 0)))
            ..lineTo(pts.first.dx, plot.y(math.max(plot.scale.min, 0)))
            ..close();
          canvas.drawPath(fill, Paint()..color = colors[s].withValues(alpha: 0.1));
        }
        canvas.drawPath(
          line,
          Paint()
            ..color = colors[s]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
        if (pts.length == 1 || showPoints) {
          for (final Offset p in pts) {
            _dot(canvas, p, colors[s]);
          }
        }
      }
      if (hovered != null && hovered! < values.length && values[hovered!] != null) {
        _dot(canvas, Offset(plot.x(hovered!), ay(values[hovered!]!)), colors[s], radius: 5);
      }
    }
  }

  Path _path(List<Offset> pts) {
    final Path p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      if (curved) {
        final Offset a = pts[i - 1];
        final Offset b = pts[i];
        final double mx = (a.dx + b.dx) / 2;
        p.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
      } else {
        p.lineTo(pts[i].dx, pts[i].dy);
      }
    }
    return p;
  }

  /// Titik dengan cincin 2px warna permukaan.
  void _dot(Canvas canvas, Offset p, Color color, {double radius = 4}) {
    canvas.drawCircle(p, radius + 2, Paint()..color = surface);
    canvas.drawCircle(p, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}

/// Grafik batang (Bar Chart IDDS): tegak atau mendatar, berkelompok atau
/// bertumpuk.
///
/// ```dart
/// IddsBarChart(
///   labels: const ['Kota Gorontalo', 'Kab. Gorontalo', 'Bone Bolango'],
///   series: const [IddsChartSeries(name: 'Penerima', values: [420, 380, 215])],
/// )
/// ```
class IddsBarChart extends StatelessWidget {
  /// Membuat grafik batang.
  const IddsBarChart({
    super.key,
    required this.labels,
    required this.series,
    this.height,
    this.horizontal = false,
    this.stacked = false,
    this.showValues = false,
    this.valueFormat = iddsCompactNumber,
    this.showLegend,
    this.semanticLabel,
  });

  /// Label kategori.
  final List<String> labels;

  /// Seri data.
  final List<IddsChartSeries> series;

  /// Tinggi grafik. Bawaan: 240 (tegak) atau 40px per kategori (mendatar).
  final double? height;

  /// Batang mendatar, cocok untuk label kategori yang panjang atau peringkat.
  final bool horizontal;

  /// Tumpuk seri di satu batang.
  final bool stacked;

  /// Tampilkan nilai di ujung batang (hanya bila satu seri dan tidak bertumpuk).
  final bool showValues;

  /// Format nilai.
  final String Function(double value) valueFormat;

  /// Tampilkan legenda. Bawaan: bila lebih dari satu seri.
  final bool? showLegend;

  /// Ringkasan untuk pembaca layar.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final (double lo, double hi) = _range(series, stacked: stacked, count: labels.length);
    final _Scale scale = _Scale(lo, hi);
    final TextStyle axis = theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary);
    final TextStyle valueStyle = theme.textStyle(
      fontSize: IddsFontSize.xs,
      lineHeight: IddsLineHeight.xs,
      fontWeight: IddsFontWeight.medium,
      color: c.contentPrimary,
    );
    final List<Color> colors = <Color>[for (int i = 0; i < series.length; i++) _seriesColor(i, series[i].color)];
    final bool values = showValues && series.length == 1 && !stacked;
    final double h = height ?? (horizontal ? math.max(120, labels.length * 40.0 + 32) : 240);

    _BarGeometry geometryFor(Size size) => _BarGeometry(
          size: size,
          horizontal: horizontal,
          scale: scale,
          labels: labels,
          axisStyle: axis,
          format: valueFormat,
          valueSpace: values,
        );

    final Widget chart = _InteractiveChart(
      height: h,
      data: Object.hashAll(<Object>[...series, ...labels, stacked, horizontal]),
      semanticLabel: semanticLabel ?? _describe('Grafik batang', labels, series, valueFormat),
      painterBuilder: (Size size, double t, int? hovered) => _BarPainter(
        g: geometryFor(size),
        series: series,
        colors: colors,
        progress: t,
        hovered: hovered,
        stacked: stacked,
        showValues: values,
        valueStyle: valueStyle,
        format: valueFormat,
        grid: c.strokePrimary,
        hover: c.backgroundSecondary,
      ),
      hitTest: (Size size, Offset p) {
        if (labels.isEmpty) return null;
        final _BarGeometry g = geometryFor(size);
        final int? i = g.indexAt(p);
        if (i == null) return null;
        return (i, horizontal ? Offset(p.dx, g.center(i)) : Offset(g.center(i), p.dy));
      },
      tooltipBuilder: (int i) => _TooltipCard(
        title: labels[i],
        rows: <(String, String, Color)>[
          for (int s = 0; s < series.length; s++)
            if (i < series[s].values.length && series[s].values[i] != null)
              (series[s].name, valueFormat(series[s].values[i]!), colors[s]),
        ],
      ),
    );

    return _withLegend(
      showLegend ?? series.length > 1,
      <(String, Color)>[for (int i = 0; i < series.length; i++) (series[i].name, colors[i])],
      _KeyShape.box,
      chart,
    );
  }
}

class _BarGeometry {
  _BarGeometry({
    required Size size,
    required this.horizontal,
    required this.scale,
    required this.labels,
    required this.axisStyle,
    required this.format,
    required bool valueSpace,
  }) {
    if (horizontal) {
      double labelW = 0;
      for (final String l in labels) {
        labelW = math.max(labelW, _text(l, axisStyle).width);
      }
      labelW = math.min(labelW, size.width * 0.4);
      final double tickH = _text('0', axisStyle).height;
      double maxTickW = 0;
      for (final double t in scale.ticks) {
        maxTickW = math.max(maxTickW, _text(format(t), axisStyle).width);
      }
      rect = Rect.fromLTRB(
        labelW + 12,
        4,
        size.width - math.max(maxTickW / 2, valueSpace ? 40 : 8),
        size.height - tickH - 8,
      );
    } else {
      double yLabelWidth = 0;
      for (final double t in scale.ticks) {
        yLabelWidth = math.max(yLabelWidth, _text(format(t), axisStyle).width);
      }
      final double xLabelHeight = _text('0', axisStyle).height;
      rect = Rect.fromLTRB(yLabelWidth + 8, valueSpace ? 22 : 8, size.width - 8, size.height - xLabelHeight - 8);
    }
  }

  final bool horizontal;
  final _Scale scale;
  final List<String> labels;
  final TextStyle axisStyle;
  final String Function(double) format;
  late final Rect rect;

  int get n => labels.length;

  double get bandSize => (horizontal ? rect.height : rect.width) / math.max(1, n);

  double center(int i) => (horizontal ? rect.top : rect.left) + bandSize * (i + 0.5);

  /// Posisi nilai pada sumbu nilai.
  double pos(double v) =>
      horizontal ? rect.left + rect.width * scale.fraction(v) : rect.bottom - rect.height * scale.fraction(v);

  int? indexAt(Offset p) {
    final double along = horizontal ? p.dy - rect.top : p.dx - rect.left;
    final double length = horizontal ? rect.height : rect.width;
    if (along < 0 || along > length) return null;
    return (along / bandSize).floor().clamp(0, n - 1);
  }

  void paintAxes(Canvas canvas, Color grid) {
    final Paint gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final double t in scale.ticks) {
      final TextPainter tp = _text(format(t), axisStyle);
      if (horizontal) {
        final double xx = pos(t).roundToDouble() + 0.5;
        canvas.drawLine(Offset(xx, rect.top), Offset(xx, rect.bottom), gridPaint);
        tp.paint(canvas, Offset(pos(t) - tp.width / 2, rect.bottom + 6));
      } else {
        final double yy = pos(t).roundToDouble() + 0.5;
        canvas.drawLine(Offset(rect.left, yy), Offset(rect.right, yy), gridPaint);
        tp.paint(canvas, Offset(rect.left - 8 - tp.width, pos(t) - tp.height / 2));
      }
    }
    if (n == 0) return;
    if (horizontal) {
      for (int i = 0; i < n; i++) {
        final TextPainter tp = _text(labels[i], axisStyle, maxWidth: rect.left - 12);
        tp.paint(canvas, Offset(rect.left - 12 - tp.width, center(i) - tp.height / 2));
      }
    } else {
      double maxW = 0;
      for (final String l in labels) {
        maxW = math.max(maxW, _text(l, axisStyle).width);
      }
      final int every = math.max(1, ((maxW + 8) / math.max(1, bandSize)).ceil());
      for (int i = 0; i < n; i += every) {
        final TextPainter tp = _text(labels[i], axisStyle, maxWidth: math.max(bandSize * every - 4, 24));
        tp.paint(canvas, Offset((center(i) - tp.width / 2).clamp(0, rect.right + 8 - tp.width), rect.bottom + 6));
      }
    }
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.g,
    required this.series,
    required this.colors,
    required this.progress,
    required this.hovered,
    required this.stacked,
    required this.showValues,
    required this.valueStyle,
    required this.format,
    required this.grid,
    required this.hover,
  });

  final _BarGeometry g;
  final List<IddsChartSeries> series;
  final List<Color> colors;
  final double progress;
  final int? hovered;
  final bool stacked;
  final bool showValues;
  final TextStyle valueStyle;
  final String Function(double) format;
  final Color grid;
  final Color hover;

  static const double _maxThickness = 24;
  static const double _gap = 2;
  static const Radius _radius = Radius.circular(4);

  @override
  void paint(Canvas canvas, Size size) {
    if (hovered != null) {
      final double start = g.center(hovered!) - g.bandSize / 2;
      canvas.drawRect(
        g.horizontal
            ? Rect.fromLTWH(g.rect.left, start, g.rect.width, g.bandSize)
            : Rect.fromLTWH(start, g.rect.top, g.bandSize, g.rect.height),
        Paint()..color = hover,
      );
    }
    g.paintAxes(canvas, grid);
    if (g.n == 0 || series.isEmpty) return;

    final double zero = g.pos(math.max(g.scale.min, 0));
    final int groups = stacked ? 1 : series.length;
    final double usable = g.bandSize * 0.7;
    final double thickness = math.min(_maxThickness, (usable - _gap * (groups - 1)) / groups).clamp(2, _maxThickness);
    final double groupSize = thickness * groups + _gap * (groups - 1);

    for (int i = 0; i < g.n; i++) {
      final double bandStart = g.center(i) - groupSize / 2;
      double posBase = 0;
      double negBase = 0;
      for (int s = 0; s < series.length; s++) {
        final double? raw = i < series[s].values.length ? series[s].values[i] : null;
        if (raw == null) continue;
        final double v = raw * progress;
        final double offset = stacked ? 0 : s * (thickness + _gap);
        double from;
        double to;
        if (stacked) {
          if (v >= 0) {
            from = posBase;
            to = posBase + v;
            posBase = to;
          } else {
            from = negBase;
            to = negBase + v;
            negBase = to;
          }
        } else {
          from = 0;
          to = v;
        }
        double a = g.pos(from);
        final double b = g.pos(to);
        // Celah 2px warna permukaan antar segmen tumpukan.
        if (stacked && from != 0) {
          final double dir = b >= a ? 1 : -1;
          a += dir * _gap;
          if ((b - a) * dir <= 0) continue;
        }
        final bool positive = to >= from;
        final Rect r = g.horizontal
            ? Rect.fromLTRB(math.min(a, b), bandStart + offset, math.max(a, b), bandStart + offset + thickness)
            : Rect.fromLTRB(bandStart + offset, math.min(a, b), bandStart + offset + thickness, math.max(a, b));
        if (r.isEmpty) continue;
        // Ujung data membulat 4px, sisi dasar lurus. Segmen tumpukan di
        // tengah tidak dibulatkan.
        final bool isEnd = !stacked || _isLastSegment(i, s, positive);
        final RRect rr = !isEnd
            ? RRect.fromRectAndRadius(r, Radius.zero)
            : g.horizontal
                ? (positive
                    ? RRect.fromRectAndCorners(r, topRight: _radius, bottomRight: _radius)
                    : RRect.fromRectAndCorners(r, topLeft: _radius, bottomLeft: _radius))
                : (positive
                    ? RRect.fromRectAndCorners(r, topLeft: _radius, topRight: _radius)
                    : RRect.fromRectAndCorners(r, bottomLeft: _radius, bottomRight: _radius));
        canvas.drawRRect(rr, Paint()..color = colors[s]);

        if (showValues && progress >= 1) {
          final TextPainter tp = _text(format(raw), valueStyle);
          if (g.horizontal) {
            tp.paint(canvas, Offset(r.right + 6, r.center.dy - tp.height / 2));
          } else {
            tp.paint(canvas, Offset(r.center.dx - tp.width / 2, r.top - tp.height - 4));
          }
        }
      }
    }
    final Paint base = Paint()
      ..color = grid
      ..strokeWidth = 1;
    if (g.horizontal) {
      canvas.drawLine(Offset(zero, g.rect.top), Offset(zero, g.rect.bottom), base);
    } else {
      canvas.drawLine(Offset(g.rect.left, zero), Offset(g.rect.right, zero), base);
    }
  }

  bool _isLastSegment(int i, int s, bool positive) {
    for (int k = s + 1; k < series.length; k++) {
      final double? v = i < series[k].values.length ? series[k].values[i] : null;
      if (v != null && v != 0 && (v > 0) == positive) return false;
    }
    return true;
  }

  @override
  bool shouldRepaint(_BarPainter old) => true;
}

// ---------------------------------------------------------------------------
// Grafik lingkaran.
// ---------------------------------------------------------------------------

/// Grafik lingkaran atau donat (Pie Chart IDDS) dengan legenda berisi
/// persentase.
///
/// Gunakan untuk 2–6 bagian dari satu keseluruhan; lebih dari itu, grafik
/// batang mendatar lebih mudah dibaca.
class IddsPieChart extends StatelessWidget {
  /// Membuat grafik lingkaran.
  const IddsPieChart({
    super.key,
    required this.slices,
    this.size = 200,
    this.donut = false,
    this.centerLabel,
    this.centerValue,
    this.valueFormat = iddsCompactNumber,
    this.showLegend = true,
    this.semanticLabel,
  });

  /// Potongan-potongan.
  final List<IddsChartSlice> slices;

  /// Diameter lingkaran.
  final double size;

  /// Donat (berlubang di tengah).
  final bool donut;

  /// Teks kecil di tengah donat, misalnya "Total".
  final String? centerLabel;

  /// Teks besar di tengah donat. Bawaan: jumlah semua nilai.
  final String? centerValue;

  /// Format nilai.
  final String Function(double value) valueFormat;

  /// Tampilkan legenda dengan nilai dan persen.
  final bool showLegend;

  /// Ringkasan untuk pembaca layar.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double total = slices.fold(0, (double sum, IddsChartSlice s) => sum + math.max(0, s.value));
    final List<Color> colors = <Color>[for (int i = 0; i < slices.length; i++) _seriesColor(i, slices[i].color)];
    String percent(double v) => total == 0 ? '0%' : '${(v / total * 100).toStringAsFixed(v / total < 0.1 ? 1 : 0).replaceAll('.', ',')}%';

    final Widget pie = SizedBox(
      width: size,
      child: _InteractiveChart(
        height: size,
        data: Object.hashAll(<Object>[for (final IddsChartSlice s in slices) Object.hash(s.label, s.value)]),
        semanticLabel: semanticLabel ??
            'Grafik lingkaran. ${slices.map((IddsChartSlice s) => '${s.label} ${valueFormat(s.value)} (${percent(s.value)})').join(', ')}.',
        painterBuilder: (Size sz, double t, int? hovered) => _PiePainter(
          values: <double>[for (final IddsChartSlice s in slices) math.max(0, s.value)],
          colors: colors,
          progress: t,
          hovered: hovered,
          donut: donut,
          surface: c.backgroundPrimary,
          empty: c.backgroundTertiary,
        ),
        hitTest: (Size sz, Offset p) {
          final Offset center = sz.center(Offset.zero);
          final Offset d = p - center;
          final double r = math.min(sz.width, sz.height) / 2;
          if (d.distance > r || (donut && d.distance < r * 0.6) || total == 0) return null;
          double angle = math.atan2(d.dy, d.dx) + math.pi / 2;
          if (angle < 0) angle += math.pi * 2;
          double acc = 0;
          for (int i = 0; i < slices.length; i++) {
            acc += math.max(0, slices[i].value) / total * math.pi * 2;
            if (angle <= acc) return (i, p);
          }
          return null;
        },
        tooltipBuilder: (int i) => _TooltipCard(
          title: slices[i].label,
          rows: <(String, String, Color)>[('(${percent(slices[i].value)})', valueFormat(slices[i].value), colors[i])],
        ),
      ),
    );

    final Widget visual = !donut
        ? pie
        : Stack(
            alignment: Alignment.center,
            children: <Widget>[
              pie,
              IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      centerValue ?? valueFormat(total),
                      style: theme.textStyle(
                        fontSize: IddsFontSize.xl,
                        lineHeight: IddsLineHeight.lg,
                        fontWeight: IddsFontWeight.semibold,
                        color: c.contentPrimary,
                      ),
                    ),
                    if (centerLabel != null)
                      Text(
                        centerLabel!,
                        style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary),
                      ),
                  ],
                ),
              ),
            ],
          );

    if (!showLegend) return visual;
    final TextStyle legendStyle = theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary);
    final Widget legend = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: IddsSpacing.s8,
      children: <Widget>[
        for (int i = 0; i < slices.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: IddsSpacing.s8,
            children: <Widget>[
              Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], borderRadius: BorderRadius.circular(2))),
              Text(slices[i].label, style: legendStyle),
              Text(
                '${valueFormat(slices[i].value)} · ${percent(slices[i].value)}',
                style: theme.textStyle(
                  fontSize: IddsFontSize.xs,
                  lineHeight: IddsLineHeight.xs,
                  fontWeight: IddsFontWeight.medium,
                  color: c.contentPrimary,
                ),
              ),
            ],
          ),
      ],
    );
    return Wrap(
      spacing: IddsSpacing.s24,
      runSpacing: IddsSpacing.s16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[visual, legend],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter({
    required this.values,
    required this.colors,
    required this.progress,
    required this.hovered,
    required this.donut,
    required this.surface,
    required this.empty,
  });

  final List<double> values;
  final List<Color> colors;
  final double progress;
  final int? hovered;
  final bool donut;
  final Color surface;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double r = math.min(size.width, size.height) / 2;
    final double total = values.fold(0, (double a, double b) => a + b);
    final Rect rect = Rect.fromCircle(center: center, radius: r);
    if (total <= 0) {
      canvas.drawCircle(center, r, Paint()..color = empty);
    } else {
      double start = -math.pi / 2;
      final double sweepTotal = math.pi * 2 * progress;
      for (int i = 0; i < values.length; i++) {
        final double sweep = values[i] / total * sweepTotal;
        if (sweep <= 0) continue;
        final double grow = hovered == i ? 4 : 0;
        canvas.drawArc(
          rect.inflate(grow),
          start,
          sweep,
          true,
          Paint()..color = colors[i],
        );
        start += sweep;
      }
      // Celah 2px warna permukaan di antara potongan.
      if (values.where((double v) => v > 0).length > 1) {
        start = -math.pi / 2;
        final Paint gap = Paint()
          ..color = surface
          ..strokeWidth = 2;
        for (int i = 0; i < values.length; i++) {
          final double sweep = values[i] / total * sweepTotal;
          if (sweep <= 0) continue;
          canvas.drawLine(center, center + Offset(math.cos(start), math.sin(start)) * (r + 5), gap);
          start += sweep;
        }
      }
    }
    if (donut) canvas.drawCircle(center, r * 0.6, Paint()..color = surface);
  }

  @override
  bool shouldRepaint(_PiePainter old) => true;
}
