import 'package:flutter/material.dart' show DefaultMaterialLocalizations, Material, MaterialLocalizations, MaterialType;
import 'package:flutter/widgets.dart';

/// Menyediakan ancestor yang dibutuhkan widget Material (mis. TextField) agar
/// komponen IDDS tetap bisa dipakai di `WidgetsApp` atau `CupertinoApp`.
Widget iddsMaterialShim(BuildContext context, Widget child) {
  Widget result = Material(type: MaterialType.transparency, child: child);
  if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null) {
    result = Localizations.override(
      context: context,
      delegates: const <LocalizationsDelegate<dynamic>>[DefaultMaterialLocalizations.delegate],
      child: result,
    );
  }
  return result;
}
