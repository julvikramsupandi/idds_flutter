// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Source: @idds/styles 1.6.38 (dist/base.css), MIT License.
// Regenerate with `npm run generate` in tool/.

import 'dart:ui' show Color, Offset;

import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:flutter/painting.dart' show BoxShadow;

/// Jarak (spacing) IDDS dalam logical pixel.
///
/// Nama mengikuti nilai pixel agar tidak ambigu: [s16] = 16px
/// (`--ina-spacing-4` di CSS).
abstract final class IddsSpacing {
  /// `--ina-spacing-0`.
  static const double s0 = 0.0;

  /// `--ina-spacing-0-5`.
  static const double s2 = 2.0;

  /// `--ina-spacing-1`.
  static const double s4 = 4.0;

  /// `--ina-spacing-1-5`.
  static const double s6 = 6.0;

  /// `--ina-spacing-2`.
  static const double s8 = 8.0;

  /// `--ina-spacing-2-5`.
  static const double s10 = 10.0;

  /// `--ina-spacing-3`.
  static const double s12 = 12.0;

  /// `--ina-spacing-3-5`.
  static const double s14 = 14.0;

  /// `--ina-spacing-4`.
  static const double s16 = 16.0;

  /// `--ina-spacing-4-5`.
  static const double s18 = 18.0;

  /// `--ina-spacing-5`.
  static const double s20 = 20.0;

  /// `--ina-spacing-5-5`.
  static const double s22 = 22.0;

  /// `--ina-spacing-6`.
  static const double s24 = 24.0;

  /// `--ina-spacing-6-5`.
  static const double s26 = 26.0;

  /// `--ina-spacing-7`.
  static const double s28 = 28.0;

  /// `--ina-spacing-7-5`.
  static const double s30 = 30.0;

  /// `--ina-spacing-8`.
  static const double s32 = 32.0;

  /// `--ina-spacing-8-5`.
  static const double s34 = 34.0;

  /// `--ina-spacing-9`.
  static const double s36 = 36.0;

  /// `--ina-spacing-9-5`.
  static const double s38 = 38.0;

  /// `--ina-spacing-10`.
  static const double s40 = 40.0;

  /// `--ina-spacing-10-5`.
  static const double s42 = 42.0;

  /// `--ina-spacing-11`.
  static const double s44 = 44.0;

  /// `--ina-spacing-11-5`.
  static const double s46 = 46.0;

  /// `--ina-spacing-12`.
  static const double s48 = 48.0;

  /// `--ina-spacing-12-5`.
  static const double s50 = 50.0;

  /// `--ina-spacing-13`.
  static const double s52 = 52.0;

  /// `--ina-spacing-13-5`.
  static const double s54 = 54.0;

  /// `--ina-spacing-14`.
  static const double s56 = 56.0;

  /// `--ina-spacing-14-5`.
  static const double s58 = 58.0;

  /// `--ina-spacing-15`.
  static const double s60 = 60.0;

  /// `--ina-spacing-15-5`.
  static const double s62 = 62.0;

  /// `--ina-spacing-16`.
  static const double s64 = 64.0;

  /// `--ina-spacing-16-5`.
  static const double s66 = 66.0;

  /// `--ina-spacing-17`.
  static const double s68 = 68.0;

  /// `--ina-spacing-17-5`.
  static const double s70 = 70.0;

  /// `--ina-spacing-18`.
  static const double s72 = 72.0;

  /// `--ina-spacing-18-5`.
  static const double s74 = 74.0;

  /// `--ina-spacing-19`.
  static const double s76 = 76.0;

  /// `--ina-spacing-19-5`.
  static const double s78 = 78.0;

  /// `--ina-spacing-20`.
  static const double s80 = 80.0;

  /// `--ina-spacing-20-5`.
  static const double s82 = 82.0;

  /// `--ina-spacing-21`.
  static const double s84 = 84.0;

  /// `--ina-spacing-21-5`.
  static const double s86 = 86.0;

  /// `--ina-spacing-22`.
  static const double s88 = 88.0;

  /// `--ina-spacing-22-5`.
  static const double s90 = 90.0;

  /// `--ina-spacing-23`.
  static const double s92 = 92.0;

  /// `--ina-spacing-23-5`.
  static const double s94 = 94.0;

  /// `--ina-spacing-24`.
  static const double s96 = 96.0;
}

/// Radius sudut IDDS dalam logical pixel (`--ina-radius-*`).
abstract final class IddsRadius {
  /// `--ina-radius-sm` (2px).
  static const double sm = 2.0;

  /// `--ina-radius-base` (4px).
  static const double base = 4.0;

  /// `--ina-radius-md` (6px).
  static const double md = 6.0;

  /// `--ina-radius-lg` (8px).
  static const double lg = 8.0;

  /// `--ina-radius-xl` (12px).
  static const double xl = 12.0;

  /// `--ina-radius-2xl` (16px).
  static const double xl2 = 16.0;

  /// `--ina-radius-full` (9999px).
  static const double full = 9999.0;
}

/// Bayangan IDDS (`--ina-shadow-*`).
abstract final class IddsShadow {
  /// `--ina-shadow-sm`.
  static const List<BoxShadow> sm = <BoxShadow>[
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: 0.0,
    ),
  ];

  /// `--ina-shadow-base`.
  static const List<BoxShadow> base = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 1.0),
      blurRadius: 3.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 1.0),
      blurRadius: 2.0,
      spreadRadius: -1.0,
    ),
  ];

  /// `--ina-shadow-md`.
  static const List<BoxShadow> md = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 4.0),
      blurRadius: 6.0,
      spreadRadius: -1.0,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 2.0),
      blurRadius: 4.0,
      spreadRadius: -2.0,
    ),
  ];

  /// `--ina-shadow-lg`.
  static const List<BoxShadow> lg = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 10.0),
      blurRadius: 15.0,
      spreadRadius: -3.0,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 4.0),
      blurRadius: 6.0,
      spreadRadius: -4.0,
    ),
  ];

  /// `--ina-shadow-xl`.
  static const List<BoxShadow> xl = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 20.0),
      blurRadius: 25.0,
      spreadRadius: -5.0,
    ),
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0.0, 8.0),
      blurRadius: 10.0,
      spreadRadius: -6.0,
    ),
  ];
}

/// Durasi transisi IDDS (`--ina-transition-*`).
abstract final class IddsDuration {
  /// `--ina-transition-fast` (150ms ease-in-out).
  static const Duration fast = Duration(milliseconds: 150);

  /// `--ina-transition-base` (200ms ease-in-out).
  static const Duration base = Duration(milliseconds: 200);

  /// `--ina-transition-slow` (300ms ease-in-out).
  static const Duration slow = Duration(milliseconds: 300);
}

/// Kurva transisi IDDS. CSS `ease-in-out` setara dengan [Curves.easeInOut].
abstract final class IddsCurves {
  /// `ease-in-out`.
  static const Curve standard = Curves.easeInOut;
}

/// Breakpoint responsif IDDS dalam logical pixel (`--ina-breakpoint-*`).
abstract final class IddsBreakpoint {
  /// `--ina-breakpoint-sm`.
  static const double sm = 640.0;

  /// `--ina-breakpoint-md`.
  static const double md = 768.0;

  /// `--ina-breakpoint-lg`.
  static const double lg = 1024.0;

  /// `--ina-breakpoint-xl`.
  static const double xl = 1280.0;
}
