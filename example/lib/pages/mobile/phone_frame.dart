import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

/// Bingkai ponsel netral (tidak meniru merek tertentu) untuk menampilkan
/// layar aplikasi mobile di galeri web/desktop.
///
/// Isi bingkai mendapat [MediaQuery] selebar layar ponsel, sehingga
/// komponen IDDS memakai ukuran mobile (compact < 640px), lengkap dengan
/// area status bar dan indikator beranda sebagai `padding`. Bingkai juga
/// punya [Navigator] sendiri: bottom sheet, modal, dropdown, dan toast
/// tampil di dalam bingkai, bukan memenuhi jendela browser.
///
/// Bila ruang lebih sempit dari bingkai, bingkai diperkecil utuh.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame(
      {super.key, required this.child, this.screenSize = defaultScreenSize});

  /// Lebar layar ponsel Android umum (logical pixel).
  static const double defaultScreenWidth = 360;

  /// Ukuran layar bawaan.
  static const Size defaultScreenSize = Size(defaultScreenWidth, 740);

  /// Tebal bingkai.
  static const double bezel = 10;

  /// Lebar luar bingkai dengan ukuran layar bawaan.
  static const double defaultOuterWidth = defaultScreenWidth + bezel * 2;

  /// Tinggi status bar dan indikator beranda di dalam layar.
  static const double statusBarHeight = 36;
  static const double homeIndicatorHeight = 20;

  /// Ukuran layar di dalam bingkai.
  final Size screenSize;

  /// Isi layar, biasanya satu layar aplikasi contoh.
  final Widget child;

  /// Ukuran luar bingkai.
  Size get outerSize =>
      Size(screenSize.width + bezel * 2, screenSize.height + bezel * 2);

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final Size outer = outerSize;

    final Widget phone = Container(
      width: outer.width,
      height: outer.height,
      padding: const EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        // Bingkai tetap gelap di kedua mode; di mode gelap diberi garis agar
        // tidak menyatu dengan latar.
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(44),
        border: theme.isDark ? Border.all(color: c.strokeSecondary) : null,
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: _PhoneScreen(size: screenSize, child: child),
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scale = constraints.hasBoundedWidth
            ? math.min(1, constraints.maxWidth / outer.width)
            : 1;
        if (scale >= 1) return phone;
        return SizedBox(
          width: outer.width * scale,
          height: outer.height * scale,
          child: FittedBox(child: phone),
        );
      },
    );
  }
}

class _PhoneScreen extends StatelessWidget {
  const _PhoneScreen({required this.size, required this.child});

  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    const EdgeInsets safe = EdgeInsets.only(
        top: PhoneFrame.statusBarHeight,
        bottom: PhoneFrame.homeIndicatorHeight);
    final MediaQueryData parent =
        MediaQuery.maybeOf(context) ?? const MediaQueryData();

    return SizedBox.fromSize(
      size: size,
      child: MediaQuery(
        data: parent.copyWith(
          size: size,
          padding: safe,
          viewPadding: safe,
          viewInsets: EdgeInsets.zero,
          textScaler: TextScaler.noScaling,
        ),
        child: ColoredBox(
          color: c.backgroundPrimary,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: _ScreenChild(
                  screen: child,
                  // Route dibuat sekali; isi diambil dari _ScreenChild agar
                  // ikut berubah saat induk membangun ulang (mis. ganti brand).
                  child: Navigator(
                    onGenerateRoute: (RouteSettings settings) =>
                        PageRouteBuilder<void>(
                      settings: settings,
                      transitionDuration: Duration.zero,
                      pageBuilder: (BuildContext context, Animation<double> a,
                              Animation<double> b) =>
                          Builder(
                        builder: (BuildContext context) => context
                            .dependOnInheritedWidgetOfExactType<_ScreenChild>()!
                            .screen,
                      ),
                    ),
                  ),
                ),
              ),
              // Status bar & indikator beranda digambar di atas isi, seperti
              // ponsel sungguhan; isi memberi jarak lewat MediaQuery.padding.
              const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: PhoneFrame.statusBarHeight,
                  child: _StatusBar()),
              Positioned(
                bottom: 6,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 4,
                      decoration: BoxDecoration(
                          color: c.contentPrimary,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Meneruskan isi layar ke route di dalam [Navigator] bingkai.
class _ScreenChild extends InheritedWidget {
  const _ScreenChild({required this.screen, required super.child});

  final Widget screen;

  @override
  bool updateShouldNotify(_ScreenChild oldWidget) => oldWidget.screen != screen;
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final Color color = theme.colors.contentPrimary;
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s24),
          child: Row(
            children: <Widget>[
              Text(
                '09.41',
                style: theme.textStyle(
                  fontSize: IddsFontSize.sm,
                  lineHeight: IddsLineHeight.sm,
                  fontWeight: IddsFontWeight.semibold,
                  color: color,
                ),
              ),
              const Spacer(),
              // Kamera depan.
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                    color: Color(0xFF1F1F1F), shape: BoxShape.circle),
              ),
              const Spacer(),
              Icon(TablerIcons.antenna_bars_5, size: 16, color: color),
              const SizedBox(width: IddsSpacing.s4),
              Icon(TablerIcons.wifi, size: 16, color: color),
              const SizedBox(width: IddsSpacing.s4),
              Icon(TablerIcons.battery_3, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menampilkan toast di dalam bingkai ponsel terdekat (bukan di pojok
/// jendela browser). Di aplikasi sungguhan cukup `showIddsToast(context: …)`.
IddsToastController showPhoneToast(
  BuildContext context, {
  required Widget title,
  Widget? description,
  IddsToastState state = IddsToastState.normal,
}) {
  return showIddsToast(
    context: context,
    title: title,
    description: description,
    state: state,
    position: IddsToastPosition.topCenter,
    overlay: Navigator.of(context).overlay,
  );
}
