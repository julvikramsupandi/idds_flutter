import 'package:flutter/widgets.dart';

import '../tokens/idds_dimension_tokens.g.dart';
import 'idds_theme_data.dart';

/// Memberikan [IddsThemeData] ke semua komponen IDDS di bawahnya.
///
/// Bisa dipakai bersama `MaterialApp`, `CupertinoApp`, atau `WidgetsApp`:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => IddsTheme(
///     data: IddsThemeData(brand: IddsBrand.inagov),
///     child: child!,
///   ),
/// )
/// ```
class IddsTheme extends StatelessWidget {
  /// Menerapkan [data] ke [child].
  const IddsTheme({super.key, required this.data, required this.child});

  /// Tema yang diterapkan.
  final IddsThemeData data;

  /// Subtree yang menerima tema.
  final Widget child;

  static final IddsThemeData _fallback = IddsThemeData();

  /// Tema terdekat, atau tema bawaan (Neutral, terang) bila tidak ada
  /// [IddsTheme] di atas [context].
  static IddsThemeData of(BuildContext context) => maybeOf(context) ?? _fallback;

  /// Tema terdekat, atau `null` bila tidak ada.
  static IddsThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedIddsTheme>()?.theme.data;
  }

  @override
  Widget build(BuildContext context) => _InheritedIddsTheme(theme: this, child: child);
}

class _InheritedIddsTheme extends InheritedTheme {
  const _InheritedIddsTheme({required this.theme, required super.child});

  final IddsTheme theme;

  @override
  Widget wrap(BuildContext context, Widget child) => IddsTheme(data: theme.data, child: child);

  @override
  bool updateShouldNotify(_InheritedIddsTheme oldWidget) => theme.data != oldWidget.theme.data;
}

/// Versi [IddsTheme] yang menganimasikan perubahan warna, misalnya saat
/// berganti brand atau mode gelap.
class AnimatedIddsTheme extends ImplicitlyAnimatedWidget {
  /// Menerapkan [data] ke [child] dengan animasi.
  const AnimatedIddsTheme({
    super.key,
    required this.data,
    required this.child,
    super.curve = IddsCurves.standard,
    super.duration = IddsDuration.slow,
    super.onEnd,
  });

  /// Tema tujuan.
  final IddsThemeData data;

  /// Subtree yang menerima tema.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedIddsTheme> createState() => _AnimatedIddsThemeState();
}

class _AnimatedIddsThemeState extends AnimatedWidgetBaseState<AnimatedIddsTheme> {
  _IddsThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data = visitor(
      _data,
      widget.data,
      (dynamic value) => _IddsThemeDataTween(begin: value as IddsThemeData),
    ) as _IddsThemeDataTween?;
  }

  @override
  Widget build(BuildContext context) {
    return IddsTheme(data: _data!.evaluate(animation), child: widget.child);
  }
}

class _IddsThemeDataTween extends Tween<IddsThemeData> {
  _IddsThemeDataTween({super.begin});

  @override
  IddsThemeData lerp(double t) => IddsThemeData.lerp(begin!, end!, t);
}
