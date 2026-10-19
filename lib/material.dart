/// Integrasi idds_flutter dengan Material.
///
/// ```dart
/// import 'package:idds_flutter/idds_flutter.dart';
/// import 'package:idds_flutter/material.dart';
///
/// final idds = IddsThemeData(brand: IddsBrand.inagov);
/// MaterialApp(
///   theme: idds.toMaterialTheme(),
///   builder: (context, child) => IddsTheme(data: idds, child: child!),
/// );
/// ```
library;

import 'package:flutter/material.dart';

import 'idds_flutter.dart';

/// Membuat [ThemeData] Material dari tema IDDS, agar widget Material
/// (Scaffold, AppBar, TextField, …) memakai warna yang sama.
extension IddsMaterialTheme on IddsThemeData {
  /// [ThemeData] Material yang selaras dengan tema ini.
  ThemeData toMaterialTheme() {
    final IddsColors c = colors;
    final Color secondary = c.secondary.shade500;
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.primaryMain,
      onPrimary: c.onPrimary,
      secondary: secondary,
      onSecondary: IddsColorUtils.bestContrast(secondary, <Color>[c.baseWhite, c.baseBlack]),
      error: c.contentNegative,
      onError: c.baseWhite,
      surface: c.backgroundPrimary,
      onSurface: c.contentPrimary,
      onSurfaceVariant: c.contentSecondary,
      surfaceContainerLowest: c.backgroundPrimary,
      surfaceContainerLow: c.backgroundSecondary,
      surfaceContainer: c.backgroundSecondary,
      surfaceContainerHigh: c.backgroundTertiary,
      surfaceContainerHighest: c.backgroundTertiary,
      outline: c.strokeSecondary,
      outlineVariant: c.strokePrimary,
      scrim: c.backgroundOverlay,
    );
    final ThemeData base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      scaffoldBackgroundColor: c.backgroundPrimary,
      dividerColor: c.strokePrimary,
    );
    final IddsTextStyleBuilder? builder = textStyleBuilder;
    if (builder == null) return base;
    // Teks widget Material ikut memakai font dari textStyleBuilder.
    TextStyle? f(TextStyle? s) => s == null ? null : builder(s);
    TextTheme map(TextTheme t) => TextTheme(
          displayLarge: f(t.displayLarge),
          displayMedium: f(t.displayMedium),
          displaySmall: f(t.displaySmall),
          headlineLarge: f(t.headlineLarge),
          headlineMedium: f(t.headlineMedium),
          headlineSmall: f(t.headlineSmall),
          titleLarge: f(t.titleLarge),
          titleMedium: f(t.titleMedium),
          titleSmall: f(t.titleSmall),
          bodyLarge: f(t.bodyLarge),
          bodyMedium: f(t.bodyMedium),
          bodySmall: f(t.bodySmall),
          labelLarge: f(t.labelLarge),
          labelMedium: f(t.labelMedium),
          labelSmall: f(t.labelSmall),
        );
    return base.copyWith(textTheme: map(base.textTheme), primaryTextTheme: map(base.primaryTextTheme));
  }
}
