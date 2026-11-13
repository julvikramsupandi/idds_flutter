import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idds_flutter/idds_flutter.dart';

/// Logo brand untuk contoh di Beranda. Brand tanpa berkas logo (Neutral,
/// INApas, INAku, BGN, brand kustom) ditampilkan sebagai teks nama brand.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.brand, this.height = 32});

  final IddsBrand brand;

  /// Tinggi logo.
  final double height;

  static const Map<String, String> _assets = <String, String>{
    'inagov': 'assets/logos/inagov.svg',
    'panrb': 'assets/logos/panrb.svg',
    'lan': 'assets/logos/lan.svg',
    'bkn': 'assets/logos/bkn.svg',
  };

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final String? asset = _assets[brand.id];
    if (asset == null) {
      return Text(
        brand.name,
        style: theme.textStyle(
          fontSize: IddsFontSize.xl2,
          lineHeight: IddsLineHeight.xl,
          fontWeight: IddsFontWeight.bold,
          color: theme.colors.primaryMain,
        ),
      );
    }
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SvgPicture.asset(
        asset,
        height: height,
        semanticsLabel: 'Logo ${brand.name}',
        // Teks logo PANRB hampir hitam (#231F20) dan tidak terbaca di mode
        // gelap, jadi diganti warna teks utama.
        colorMapper: theme.isDark ? _DarkTextMapper(theme.colors.contentPrimary) : null,
      ),
    );
  }
}

/// Mengganti warna hampir hitam pada logo dengan [color].
class _DarkTextMapper extends ColorMapper {
  const _DarkTextMapper(this.color);

  final Color color;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color original) {
    final bool nearBlack = original.r < 0.2 && original.g < 0.2 && original.b < 0.2;
    return nearBlack ? color.withValues(alpha: original.a) : original;
  }

  @override
  bool operator ==(Object other) => other is _DarkTextMapper && other.color == color;

  @override
  int get hashCode => color.hashCode;
}
