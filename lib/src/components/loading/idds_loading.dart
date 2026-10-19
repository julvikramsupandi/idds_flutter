import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_primitives.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Warna indikator memuat.
enum IddsLoadingColor {
  /// Warna brand (bawaan).
  primary,

  /// Abu-abu.
  secondary,

  /// Hijau.
  success,

  /// Kuning.
  warning,

  /// Merah.
  error,

  /// Biru panduan.
  info,
}

Color _loadingColor(IddsColors c, IddsLoadingColor color) => switch (color) {
      IddsLoadingColor.primary => c.primary.shade500,
      IddsLoadingColor.secondary => c.contentTertiary,
      IddsLoadingColor.success => c.positive.shade500,
      IddsLoadingColor.warning => c.warning.shade500,
      IddsLoadingColor.error => c.negative.shade500,
      IddsLoadingColor.info => c.guide.shade500,
    };

/// Warna jalur abu-abu; di dark mode memakai garis tepi agar tidak terlalu
/// terang.
Color _trackColor(IddsThemeData theme) =>
    theme.isDark ? theme.colors.strokePrimary : IddsPrimitives.neutral.shade300;

/// Lingkaran berputar dengan judul dan subjudul opsional (Spinner IDDS).
class IddsSpinner extends StatefulWidget {
  /// Membuat spinner.
  const IddsSpinner({
    super.key,
    this.size = 24,
    this.strokeWidth = 3,
    this.color = IddsLoadingColor.primary,
    this.title,
    this.subtitle,
    this.semanticLabel = 'Memuat',
  });

  /// Diameter.
  final double size;

  /// Tebal garis: 2 (tipis), 3 (sedang, bawaan), 4 (tebal), 6 (sangat tebal).
  final double strokeWidth;

  /// Warna bagian yang berputar.
  final IddsLoadingColor color;

  /// Judul di bawah spinner.
  final String? title;

  /// Subjudul di bawah judul.
  final String? subtitle;

  /// Label pembaca layar.
  final String semanticLabel;

  @override
  State<IddsSpinner> createState() => _IddsSpinnerState();
}

class _IddsSpinnerState extends State<IddsSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final Widget spinner = RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _ArcPainter(
          track: _trackColor(theme),
          color: _loadingColor(c, widget.color),
          strokeWidth: widget.strokeWidth,
          progress: 0.25,
        ),
      ),
    );
    return Semantics(
      label: widget.title ?? widget.semanticLabel,
      liveRegion: true,
      child: widget.title == null && widget.subtitle == null
          ? spinner
          : Column(
              mainAxisSize: MainAxisSize.min,
              spacing: IddsSpacing.s8,
              children: <Widget>[
                spinner,
                if (widget.title != null)
                  Text(
                    widget.title!,
                    textAlign: TextAlign.center,
                    style: theme.textStyle(
                      fontSize: IddsFontSize.base,
                      lineHeight: IddsLineHeight.base,
                      fontWeight: IddsFontWeight.semibold,
                      color: c.contentPrimary,
                    ),
                  ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    textAlign: TextAlign.center,
                    style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentSecondary),
                  ),
              ],
            ),
    );
  }
}

/// Jalur lingkaran dengan busur sepanjang [progress] (0–1) mulai dari atas.
class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.track, required this.color, required this.strokeWidth, required this.progress, this.round = false});

  final Color track;
  final Color color;
  final double strokeWidth;
  final double progress;
  final bool round;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (progress <= 0) return;
    // Seperti `border-top` pada lingkaran CSS: busur seperempat di atas.
    final double start = round ? -math.pi / 2 : -math.pi * 3 / 4;
    canvas.drawArc(
      rect,
      start,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      paint
        ..color = color
        ..strokeCap = round ? StrokeCap.round : StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.track != track || old.color != color || old.strokeWidth != strokeWidth || old.progress != progress || old.round != round;
}

/// Kemajuan berbentuk lingkaran kecil (Circle Progress Bar IDDS).
class IddsCircleProgress extends StatelessWidget {
  /// Membuat indikator lingkaran.
  const IddsCircleProgress({
    super.key,
    required this.value,
    this.diameter = 20,
    this.strokeWidth = 3,
    this.color,
    this.semanticLabel,
  });

  /// Kemajuan 0–1.
  final double value;

  /// Diameter.
  final double diameter;

  /// Tebal garis.
  final double strokeWidth;

  /// Warna kemajuan. Bawaan: warna utama brand.
  final Color? color;

  /// Label pembaca layar.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      label: semanticLabel,
      value: '${(value.clamp(0, 1) * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: value.clamp(0, 1).toDouble()),
        duration: IddsDuration.slow,
        curve: Curves.ease,
        builder: (BuildContext context, double v, Widget? _) => CustomPaint(
          size: Size.square(diameter),
          painter: _ArcPainter(
            track: c.backgroundTertiary,
            color: color ?? c.primaryMain,
            strokeWidth: strokeWidth,
            progress: v,
            round: true,
          ),
        ),
      ),
    );
  }
}

/// Tinggi [IddsProgressBar].
enum IddsProgressBarHeight {
  /// 2px.
  sm(2),

  /// 4px (bawaan).
  md(4),

  /// 6px.
  lg(6);

  const IddsProgressBarHeight(this.value);

  /// Tinggi dalam pixel.
  final double value;
}

/// Bilah kemajuan mendatar (Progress Bar / Linear Progress Indicator IDDS).
///
/// Bila [value] `null`, bilah bergerak bolak-balik untuk menandai proses
/// yang lamanya belum diketahui.
class IddsProgressBar extends StatefulWidget {
  /// Membuat bilah kemajuan.
  const IddsProgressBar({
    super.key,
    this.value,
    this.color = IddsLoadingColor.primary,
    this.height = IddsProgressBarHeight.md,
    this.semanticLabel,
  });

  /// Kemajuan 0–1, atau `null` untuk tak tentu.
  final double? value;

  /// Warna.
  final IddsLoadingColor color;

  /// Tinggi.
  final IddsProgressBarHeight height;

  /// Label pembaca layar.
  final String? semanticLabel;

  @override
  State<IddsProgressBar> createState() => _IddsProgressBarState();
}

class _IddsProgressBarState extends State<IddsProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    if (widget.value == null) _controller.repeat();
  }

  @override
  void didUpdateWidget(IddsProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final Color fill = _loadingColor(c, widget.color);
    final double h = widget.height.value;
    final double? value = widget.value?.clamp(0, 1).toDouble();

    return Semantics(
      label: widget.semanticLabel,
      value: value == null ? null : '${(value * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(h),
        child: Container(
          height: h,
          color: theme.isDark ? c.backgroundTertiary : IddsPrimitives.neutral.shade200,
          child: value != null
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    widthFactor: value,
                    heightFactor: 1,
                    child: ColoredBox(color: fill),
                  ),
                )
              : AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) => FractionallySizedBox(
                    // CSS: potongan 30% bergerak dari kiri ke kanan.
                    alignment: Alignment(-1.6 + 3.2 * _controller.value, 0),
                    widthFactor: 0.3,
                    heightFactor: 1,
                    child: child,
                  ),
                  child: ColoredBox(color: fill),
                ),
        ),
      ),
    );
  }
}

/// Warna [IddsSkeleton].
enum IddsSkeletonColor {
  /// Abu-abu (bawaan).
  gray,

  /// Biru (warna brand muda).
  blue,

  /// Hijau.
  green,

  /// Merah.
  red,

  /// Kuning.
  yellow,
}

/// Kotak penanda konten yang sedang dimuat, berdenyut pelan (Skeleton IDDS).
///
/// ```dart
/// Column(children: [
///   IddsSkeleton.circle(size: 48),
///   IddsSkeleton(height: 16, width: 200),
///   IddsSkeleton(height: 120),
/// ])
/// ```
class IddsSkeleton extends StatefulWidget {
  /// Membuat skeleton persegi panjang.
  const IddsSkeleton({
    super.key,
    this.width,
    this.height = 32,
    this.radius = IddsRadius.md,
    this.color = IddsSkeletonColor.gray,
  });

  /// Membuat skeleton lingkaran, misalnya untuk avatar.
  const IddsSkeleton.circle({super.key, double size = 48, this.color = IddsSkeletonColor.gray})
      : width = size,
        height = size,
        radius = 9999;

  /// Lebar. Bawaan: selebar yang tersedia.
  final double? width;

  /// Tinggi.
  final double height;

  /// Radius sudut.
  final double radius;

  /// Warna.
  final IddsSkeletonColor color;

  @override
  State<IddsSkeleton> createState() => _IddsSkeletonState();
}

class _IddsSkeletonState extends State<IddsSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool dark = theme.isDark;
    // CSS memakai warna 100/200; di dark mode warna terang diganti agar
    // tidak menyilaukan.
    final Color color = switch (widget.color) {
      IddsSkeletonColor.gray => dark ? c.backgroundTertiary : IddsPrimitives.neutral.shade200,
      IddsSkeletonColor.blue => dark ? c.primary.shade800 : c.primary.shade100,
      IddsSkeletonColor.green => dark ? c.positive.shade800 : c.positive.shade100,
      IddsSkeletonColor.red => dark ? c.negative.shade800 : c.negative.shade100,
      IddsSkeletonColor.yellow => dark ? c.warning.shade800 : c.warning.shade100,
    };
    return ExcludeSemantics(
      child: FadeTransition(
        // CSS: opacity 1 → 0,5 → 1 dalam 2 detik.
        opacity: Tween<double>(begin: 1, end: 0.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(widget.radius)),
        ),
      ),
    );
  }
}
