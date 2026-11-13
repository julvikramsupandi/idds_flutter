import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Memperluas area tekan [child] menjadi minimal [minSize] × [minSize]
/// **tanpa mengubah tata letak**: ukuran dan posisi gambar tetap seperti CSS
/// IDDS, hanya titik sentuh di sekitarnya ikut diterima.
///
/// Dipakai untuk tombol kecil (mis. X pada Alert/Toast) agar memenuhi target
/// sentuh 48 dp di layar sentuh (WCAG 2.5.8). Area tambahan hanya bekerja di
/// dalam batas induknya, karena induk tidak meneruskan sentuhan di luar
/// ukurannya sendiri.
class IddsHitArea extends SingleChildRenderObjectWidget {
  /// Membuat area tekan minimal [minSize].
  const IddsHitArea({super.key, this.minSize = 48, super.child});

  /// Sisi minimal area tekan.
  final double minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderIddsHitArea(minSize);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderIddsHitArea).minSize = minSize;
  }
}

class _RenderIddsHitArea extends RenderProxyBox {
  _RenderIddsHitArea(this.minSize);

  double minSize;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final double dx = math.max(0, (minSize - size.width) / 2);
    final double dy = math.max(0, (minSize - size.height) / 2);
    final Rect area =
        Rect.fromLTRB(-dx, -dy, size.width + dx, size.height + dy);
    if (!area.contains(position)) return false;
    // Titik di area tambahan dijepit ke dalam anak, agar detektor gestur anak
    // (yang hanya menerima titik di dalam ukurannya; tepi kanan/bawah
    // eksklusif) tetap terpicu.
    final Offset inside = Offset(
      position.dx.clamp(0, math.max(0, size.width - 0.5)).toDouble(),
      position.dy.clamp(0, math.max(0, size.height - 0.5)).toDouble(),
    );
    if (hitTestChildren(result, position: inside) || hitTestSelf(inside)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}
