import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:idds_flutter/primitives.dart';

import '../sections/common.dart';

/// Brand yang bisa dipilih di galeri: 8 brand resmi + 2 contoh kustom.
final List<IddsBrand> galleryBrands = <IddsBrand>[
  ...IddsBrand.values,
  IddsBrand.fromSeed(const Color(0xFF7C3AED), id: 'ungu-seed', name: 'Ungu (fromSeed)'),
  IddsBrand.fromPalette(IddsPrimitives.violet, id: 'violet', name: 'Violet (fromPalette)'),
];

class BrandPage extends StatelessWidget {
  const BrandPage({super.key, required this.brand, required this.onBrandChanged});

  final IddsBrand brand;
  final ValueChanged<IddsBrand> onBrandChanged;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final TextStyle caption = theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary);
    return GallerySection(
      title: 'Brand & Warna',
      subtitle: '8 brand resmi IDDS, ditambah dua contoh brand kustom dari IddsBrand.fromSeed dan IddsBrand.fromPalette.',
      usage: 'Bungkus aplikasi dengan IddsTheme (atau AnimatedIddsTheme agar pergantian tema beranimasi). Untuk widget Material, pakai toMaterialTheme() dari package:idds_flutter/material.dart. Warna diambil lewat IddsTheme.of(context).colors.',
      code: _brandCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          children: <Widget>[
            for (final IddsBrand b in galleryBrands)
              IddsButton(
                size: IddsButtonSize.sm,
                hierarchy: b.id == brand.id ? IddsButtonHierarchy.primary : IddsButtonHierarchy.secondary,
                onPressed: () => onBrandChanged(b),
                child: Text(b.name),
              ),
          ],
        ),
        const SizedBox(height: IddsSpacing.s24),
        _ScaleStrip(label: 'Primary', colors: c.primary.colors, main: c.primaryMain, caption: caption),
        const SizedBox(height: IddsSpacing.s8),
        _ScaleStrip(label: 'Secondary', colors: c.secondary.colors, caption: caption),
        const SizedBox(height: IddsSpacing.s24),
        const GalleryCaption('Palet grafik (IddsChartColors.categorical)'),
        const SizedBox(height: IddsSpacing.s8),
        Row(
          children: <Widget>[
            for (final Color color in IddsChartColors.categorical) Expanded(child: Container(height: 24, color: color)),
          ],
        ),
      ],
    );
  }
}

class _ScaleStrip extends StatelessWidget {
  const _ScaleStrip({required this.label, required this.colors, required this.caption, this.main});

  final String label;
  final List<Color> colors;
  final Color? main;
  final TextStyle caption;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Row(
      children: <Widget>[
        SizedBox(width: 80, child: Text(label, style: caption)),
        for (int i = 0; i < colors.length; i++)
          Expanded(
            child: IddsTooltip(
              message: '${IddsColorScale.steps[i]}',
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: colors[i],
                  border: colors[i] == main ? Border.all(color: c.strokeTertiary, width: 2) : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

const String _brandCode = r'''
import 'package:google_fonts/google_fonts.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:idds_flutter/material.dart';

// Font Inter dari package google_fonts
TextStyle inter(TextStyle style) => GoogleFonts.inter(textStyle: style);

final IddsThemeData idds = IddsThemeData(
  brand: IddsBrand.inagov, // neutral, inagov, inapas, inaku, panrb, bkn, lan, bgn
  brightness: Brightness.light,
  textStyleBuilder: inter,
);

MaterialApp(
  theme: idds.toMaterialTheme(),
  builder: (BuildContext context, Widget? child) => AnimatedIddsTheme(data: idds, child: child!),
  home: const HomePage(),
)

// Brand instansi sendiri dari satu warna
final IddsBrand agency = IddsBrand.fromSeed(const Color(0xFF0E7490), id: 'dinas', name: 'Dinas');

// Memakai warna di widget
final IddsColors c = IddsTheme.of(context).colors;
Container(color: c.primary.shade100, child: Text('Halo', style: TextStyle(color: c.contentPrimary)))
''';
