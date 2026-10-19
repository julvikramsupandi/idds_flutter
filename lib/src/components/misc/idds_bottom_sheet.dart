import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/idds_overlay_route.dart';
import '../../foundation/idds_theme.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../modal/idds_modal.dart' show IddsDismissOnEscape;

/// Menampilkan panel dari bawah layar yang bisa ditarik ke bawah untuk
/// ditutup (Bottom Sheet IDDS).
///
/// Bila [locked] `true`, panel tidak bisa ditutup dengan menarik, menekan
/// latar, atau Esc; tutup dari kode dengan `Navigator.pop`.
///
/// ```dart
/// showIddsBottomSheet<void>(
///   context: context,
///   builder: (context) => const Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Isi panel'),
///   ),
/// );
/// ```
Future<T?> showIddsBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool locked = false,
  double maxHeightFactor = 0.9,
  bool showHandle = true,
  String barrierLabel = 'Tutup panel',
  bool useRootNavigator = true,
}) {
  return iddsPushOverlayRoute<T>(
    context,
    (Widget Function(Widget) wrapTheme) => IddsOverlayRoute<T>(
      barrierDismissible: !locked,
      barrierColor: const Color(0x7A1F1F1F),
      barrierLabel: barrierLabel,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: IddsDuration.slow,
      pageBuilder: (BuildContext context) => wrapTheme(
        _BottomSheet(
          locked: locked,
          maxHeightFactor: maxHeightFactor,
          showHandle: showHandle,
          child: Builder(builder: builder),
        ),
      ),
      transitionBuilder: (BuildContext context, Animation<double> animation, Widget child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: const Cubic(0.16, 1, 0.3, 1), reverseCurve: const Cubic(0.4, 0, 0.2, 1)),
        ),
        child: child,
      ),
    ),
    useRootNavigator: useRootNavigator,
  );
}

class _BottomSheet extends StatefulWidget {
  const _BottomSheet({required this.locked, required this.maxHeightFactor, required this.showHandle, required this.child});

  final bool locked;
  final double maxHeightFactor;
  final bool showHandle;
  final Widget child;

  @override
  State<_BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> with SingleTickerProviderStateMixin {
  final GlobalKey _panelKey = GlobalKey();
  late final AnimationController _settle = AnimationController(vsync: this, duration: IddsDuration.base);
  double _drag = 0;
  double _settleFrom = 0;

  @override
  void initState() {
    super.initState();
    _settle.addListener(() => setState(() => _drag = _settleFrom * (1 - Curves.easeOut.transform(_settle.value))));
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  double get _height => (_panelKey.currentContext?.findRenderObject() as RenderBox?)?.size.height ?? 1;

  void _onDragUpdate(DragUpdateDetails d) {
    if (widget.locked) return;
    _settle.stop();
    setState(() => _drag = math.max(0, _drag + d.delta.dy));
  }

  void _onDragEnd(DragEndDetails d) {
    if (widget.locked) return;
    final double velocity = d.primaryVelocity ?? 0;
    if (_drag > _height * 0.3 || velocity > 700) {
      Navigator.maybePop(context);
      return;
    }
    _settleFrom = _drag;
    _settle.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final Size screen = MediaQuery.sizeOf(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    const BorderRadius radius = BorderRadius.vertical(top: Radius.circular(IddsRadius.xl));

    final Widget panel = Container(
      key: _panelKey,
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: screen.height * widget.maxHeightFactor, maxWidth: 640),
      decoration: BoxDecoration(color: c.backgroundPrimary, borderRadius: radius, boxShadow: IddsShadow.xl),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.showHandle)
              Semantics(
                label: widget.locked ? null : 'Tarik ke bawah untuk menutup',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: IddsSpacing.s12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: c.strokeSecondary, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: padding.bottom),
                child: DefaultTextStyle(
                  style: IddsTheme.of(context).textStyle(
                    fontSize: IddsFontSize.sm,
                    lineHeight: IddsLineHeight.sm,
                    color: c.contentPrimary,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final Widget content = Align(
      alignment: Alignment.bottomCenter,
      child: Transform.translate(
        offset: Offset(0, _drag),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: panel,
        ),
      ),
    );

    if (widget.locked) return content;
    return IddsDismissOnEscape(onDismiss: () => Navigator.maybePop(context), child: content);
  }
}
