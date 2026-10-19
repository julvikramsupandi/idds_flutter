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

  @override
  Widget build(BuildContext context) {
    final IddsThemeData idds = IddsThemeData(brand: _brand, brightness: _brightness, textStyleBuilder: interFont);
    return MaterialApp(
      title: 'idds_flutter',
      debugShowCheckedModeBanner: false,
      theme: idds.toMaterialTheme(),
      builder: (BuildContext context, Widget? child) => AnimatedIddsTheme(data: idds, child: child!),
      home: GalleryShell(
        brand: _brand,
        brightness: _brightness,
        onBrandChanged: (IddsBrand b) => setState(() => _brand = b),
        onBrightnessChanged: (Brightness b) => setState(() => _brightness = b),
      ),
    );
  }
}
