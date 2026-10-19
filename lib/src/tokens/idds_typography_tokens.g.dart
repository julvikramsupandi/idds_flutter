// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Source: @idds/styles 1.6.38 (dist/base.css), MIT License.
// Regenerate with `npm run generate` in tool/.

import 'dart:ui' show FontWeight;

/// Ukuran font IDDS dalam logical pixel (`--ina-font-*`).
abstract final class IddsFontSize {
  /// `--ina-font-3xs` (8px).
  static const double xs3 = 8.0;

  /// `--ina-font-2xs` (10px).
  static const double xs2 = 10.0;

  /// `--ina-font-xs` (12px).
  static const double xs = 12.0;

  /// `--ina-font-sm` (14px).
  static const double sm = 14.0;

  /// `--ina-font-base` (16px).
  static const double base = 16.0;

  /// `--ina-font-lg` (18px).
  static const double lg = 18.0;

  /// `--ina-font-xl` (20px).
  static const double xl = 20.0;

  /// `--ina-font-2xl` (24px).
  static const double xl2 = 24.0;

  /// `--ina-font-3xl` (30px).
  static const double xl3 = 30.0;

  /// `--ina-font-4xl` (36px).
  static const double xl4 = 36.0;
}

/// Tinggi baris IDDS dalam logical pixel (`--ina-line-height-*`).
///
/// Untuk [TextStyle.height], bagi dengan ukuran font:
/// `height: IddsLineHeight.sm / IddsFontSize.sm`.
abstract final class IddsLineHeight {
  /// `--ina-line-height-xs` (16px).
  static const double xs = 16.0;

  /// `--ina-line-height-sm` (20px).
  static const double sm = 20.0;

  /// `--ina-line-height-base` (24px).
  static const double base = 24.0;

  /// `--ina-line-height-lg` (28px).
  static const double lg = 28.0;

  /// `--ina-line-height-xl` (32px).
  static const double xl = 32.0;
}

/// Ketebalan font IDDS (`--ina-font-*`).
abstract final class IddsFontWeight {
  /// `--ina-font-thin` (100).
  static const FontWeight thin = FontWeight.w100;

  /// `--ina-font-extralight` (200).
  static const FontWeight extralight = FontWeight.w200;

  /// `--ina-font-light` (300).
  static const FontWeight light = FontWeight.w300;

  /// `--ina-font-normal` (400).
  static const FontWeight normal = FontWeight.w400;

  /// `--ina-font-medium` (500).
  static const FontWeight medium = FontWeight.w500;

  /// `--ina-font-semibold` (600).
  static const FontWeight semibold = FontWeight.w600;

  /// `--ina-font-bold` (700).
  static const FontWeight bold = FontWeight.w700;

  /// `--ina-font-extrabold` (800).
  static const FontWeight extrabold = FontWeight.w800;

  /// `--ina-font-black` (900).
  static const FontWeight black = FontWeight.w900;
}
