import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:idds_flutter/material.dart';

import 'gallery_shell.dart';

void main() => runApp(const GalleryApp());

/// Font Inter dari google_fonts untuk semua teks IDDS (diunduh saat pertama
/// dipakai lalu disimpan di cache). Fungsi tingkat atas agar tema tetap sama
/// (==) di setiap build.
TextStyle interFont(TextStyle style) => GoogleFonts.inter(textStyle: style);

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  IddsBrand _brand = IddsBrand.inagov;
  Brightness _brightness = Brightness.light;

  late final GalleryRouterDelegate _router = GalleryRouterDelegate(
    builder: (BuildContext context, String page) => GalleryShell(
      page: page,
      onPageChanged: _router.go,
      brand: _brand,
      brightness: _brightness,
      onBrandChanged: (IddsBrand b) => setState(() => _brand = b),
      onBrightnessChanged: (Brightness b) => setState(() => _brightness = b),
    ),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData idds = IddsThemeData(brand: _brand, brightness: _brightness, textStyleBuilder: interFont);
    return MaterialApp.router(
      title: 'IDDS Flutter',
      debugShowCheckedModeBanner: false,
      theme: idds.toMaterialTheme(),
      builder: (BuildContext context, Widget? child) => AnimatedIddsTheme(data: idds, child: child!),
      routeInformationParser: const GalleryRouteParser(),
      routerDelegate: _router,
    );
  }
}

/// Mengubah URL menjadi id halaman galeri dan sebaliknya.
///
/// Di web, URL memakai hash: `/#/button` membuka halaman Button, `/#/`
/// membuka Beranda. Tombol kembali/maju browser ikut berfungsi.
class GalleryRouteParser extends RouteInformationParser<String> {
  const GalleryRouteParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    final List<String> segments = routeInformation.uri.pathSegments.where((String s) => s.isNotEmpty).toList();
    return SynchronousFuture<String>(segments.isEmpty ? GalleryShell.homePage : segments.first);
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(uri: Uri.parse(configuration == GalleryShell.homePage ? '/' : '/$configuration'));
  }
}

/// Menyimpan halaman yang sedang dibuka dan membangun [Navigator] tunggal
/// (dibutuhkan modal, drawer, dan dropdown).
class GalleryRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  GalleryRouterDelegate({required this.builder});

  /// Tombol kembali Android menutup modal/drawer yang sedang terbuka.
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final Widget Function(BuildContext context, String page) builder;

  String _page = GalleryShell.homePage;

  @override
  String get currentConfiguration => _page;

  /// Membuka halaman [page] dan mencatatnya di riwayat browser.
  void go(String page) {
    if (page == _page) return;
    _page = page;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(String configuration) {
    _page = configuration;
    notifyListeners();
    return SynchronousFuture<void>(null);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: <Page<void>>[
        MaterialPage<void>(key: const ValueKey<String>('galeri'), child: Builder(builder: (BuildContext context) => builder(context, _page))),
      ],
      onDidRemovePage: (Page<Object?> page) {},
    );
  }
}
