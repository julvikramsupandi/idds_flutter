/// Palet warna dasar (primitive) IDDS.
///
/// Diimpor terpisah dengan sengaja: komponen dan layar sebaiknya memakai
/// token semantik (`IddsTheme.of(context).colors`). Primitive berguna untuk
/// ilustrasi, grafik, atau membuat brand sendiri dengan
/// `IddsBrand.fromPalette(IddsPrimitives.violet)`.
library;

export 'src/foundation/idds_color_scale.dart' show IddsPalette;
export 'src/tokens/idds_brand_tokens.g.dart';
export 'src/tokens/idds_primitives.g.dart';
