#!/usr/bin/env node
/**
 * Generator token idds_flutter.
 *
 * Membaca token desain dari package npm `@idds/styles` (dist/base.css, MIT)
 * dan menuliskannya sebagai kode Dart di lib/src/tokens/. Bila ekspor
 * variabel Figma ada di tool/figma/, generator juga membuat warna grafik
 * dan laporan semua nilai yang berbeda antara Figma dan CSS
 * (tool/reports/figma-diff.md).
 *
 * Cara pakai (dari tool/):
 *   npm install
 *   npm run generate
 *
 * Berkas hasil generate jangan diedit manual: ubah skrip ini (atau naikkan
 * versi @idds/styles di package.json), lalu generate ulang.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const TOOL_DIR = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(TOOL_DIR, '..');
const STYLES_DIR = path.join(TOOL_DIR, 'node_modules', '@idds', 'styles');
const OUT_DIR = path.join(ROOT, 'lib', 'src', 'tokens');
const FIGMA_DIR = path.join(TOOL_DIR, 'figma');
const REPORT_PATH = path.join(TOOL_DIR, 'reports', 'figma-diff.md');

// ---------------------------------------------------------------------------
// Konfigurasi
// ---------------------------------------------------------------------------

/** Brand sesuai urutan tampil. `neutral` adalah bawaan `:root` di CSS. */
const BRANDS = [
  { id: 'neutral', css: null, name: 'Neutral', description: 'Tema bawaan (default) IDDS, monokrom.' },
  { id: 'inagov', css: 'inagov', name: 'INAgov', description: 'Layanan Aparatur Negara.' },
  { id: 'inapas', css: 'inapas', name: 'INApas', description: 'Layanan paspor dan keimigrasian.' },
  { id: 'inaku', css: 'inaku', name: 'INAku', description: 'Layanan warga.' },
  { id: 'panrb', css: 'panrb', name: 'PANRB', description: 'Kementerian Pendayagunaan Aparatur Negara dan Reformasi Birokrasi.' },
  { id: 'bkn', css: 'bkn', name: 'BKN', description: 'Badan Kepegawaian Negara.' },
  { id: 'lan', css: 'lan', name: 'LAN', description: 'Lembaga Administrasi Negara.' },
  { id: 'bgn', css: 'bgn', name: 'BGN', description: 'Badan Gizi Nasional.' },
];

/**
 * Penyimpangan yang disengaja dari @idds/styles, diterapkan setelah CSS
 * dibaca. Masing-masing memperbaiki nilai yang membuat komponen tidak bisa
 * dipakai, dan dicatat di tool/reports/figma-diff.md agar bisa dilaporkan
 * ke IDDS.
 */
const FIXES = [
  {
    brand: 'neutral',
    field: 'primaryMainDark',
    value: '#ffffff',
    reason:
      'Di CSS, `--ina-primary-primary` brand default tetap `#141414` di dark mode, sama dengan `--ina-background-primary` gelap (kontras 1:1), sehingga tombol primary tidak terlihat. Dibalik menjadi putih.',
  },
  {
    brand: 'neutral',
    field: 'onPrimaryDark',
    value: '#141414',
    reason: 'Teks di atas warna utama putih (lihat baris di atas) dibuat gelap.',
  },
];

const SCALE_STEPS = [25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
const PALETTE_STEPS = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

/** Palet primitive di IddsPrimitives (nama CSS → nama Dart). */
const PRIMITIVE_PALETTES = [
  'neutral', 'blue', 'cyan', 'teal', 'green', 'lime', 'yellow', 'orange',
  'coral', 'red', 'pink', 'magenta', 'violet', 'purple', 'lilac', 'indigo',
];

/** Warna semantik tunggal: field Dart → variabel CSS (tanpa --ina-). */
const SEMANTIC_COLORS = [
  ['backgroundPrimary', 'background-primary', 'Latar utama halaman dan komponen.'],
  ['backgroundSecondary', 'background-secondary', 'Latar sekunder, mis. area yang dibedakan atau hover ringan.'],
  ['backgroundTertiary', 'background-tertiary', 'Latar tersier, mis. komponen nonaktif atau hover kuat.'],
  ['backgroundOverlay', 'background-overlay', 'Lapisan gelap di belakang modal dan drawer.'],
  ['contentPrimary', 'content-primary', 'Teks dan ikon utama.'],
  ['contentSecondary', 'content-secondary', 'Teks dan ikon sekunder.'],
  ['contentTertiary', 'content-tertiary', 'Teks dan ikon tersier, placeholder, dan konten nonaktif.'],
  ['contentGuide', 'content-guide', 'Tautan dan konten informatif.'],
  ['contentNegative', 'content-negative', 'Pesan error dan aksi destruktif.'],
  ['contentPositive', 'content-positive', 'Pesan sukses dan konfirmasi.'],
  ['strokePrimary', 'stroke-primary', 'Garis tepi dan pembatas utama.'],
  ['strokeSecondary', 'stroke-secondary', 'Garis tepi dengan kontras sedang, mis. input.'],
  ['strokeTertiary', 'stroke-tertiary', 'Garis tepi kontras tinggi, mis. cincin fokus.'],
  ['white', 'white', 'Putih yang mengikuti mode (gelap di dark mode).'],
  ['black', 'black', 'Hitam yang mengikuti mode (terang di dark mode).'],
  ['baseWhite', 'base-white', 'Putih tetap di semua mode, mis. teks di atas warna brand.'],
  ['baseBlack', 'base-black', 'Hitam tetap di semua mode.'],
];

/** Skala semantik: field Dart → awalan CSS. */
const SEMANTIC_SCALES = [
  ['guide', 'guide', 'Skala warna panduan/informasi (biru).'],
  ['negative', 'negative', 'Skala warna negatif/error (merah).'],
  ['positive', 'positive', 'Skala warna positif/sukses (hijau).'],
  ['warning', 'warning', 'Skala warna peringatan (kuning).'],
];

// ---------------------------------------------------------------------------
// Membaca CSS
// ---------------------------------------------------------------------------

function parseCss(css) {
  const clean = css.replace(/\/\*[\s\S]*?\*\//g, '');
  const blocks = [];
  const re = /([^{}]+)\{([^{}]*)\}/g;
  let m;
  while ((m = re.exec(clean)) !== null) {
    // Teks sebelum selektor bisa berisi at-rule seperti `@import ...;`.
    const selector = m[1].split(';').pop().replace(/\s+/g, ' ').replace(/"/g, "'").trim();
    const vars = {};
    for (const decl of m[2].split(';')) {
      const i = decl.indexOf(':');
      if (i < 0) continue;
      const name = decl.slice(0, i).trim();
      if (!name.startsWith('--')) continue;
      vars[name] = decl.slice(i + 1).replace(/!important/g, '').replace(/\s+/g, ' ').trim();
    }
    if (Object.keys(vars).length) blocks.push({ selector, vars });
  }
  return blocks;
}

function collectScopes(blocks) {
  const root = {};
  let light = {};
  let dark = {};
  const brand = {};
  const brandDark = {};
  for (const { selector, vars } of blocks) {
    let m;
    if (selector === ':root') Object.assign(root, vars);
    else if (selector === ":root, [data-theme='light']") light = { ...light, ...vars };
    else if (selector === "[data-theme='dark']") dark = { ...dark, ...vars };
    else if ((m = selector.match(/^\[data-brand='(\w+)'\]$/))) brand[m[1]] = { ...(brand[m[1]] || {}), ...vars };
    else if ((m = selector.match(/^\[data-theme='dark'\]\[data-brand='(\w+)'\]$/)))
      brandDark[m[1]] = { ...(brandDark[m[1]] || {}), ...vars };
  }
  return { root, light, dark, brand, brandDark };
}

/** Menyelesaikan `var(--x, fallback)` terhadap daftar scope berurutan. */
function resolve(value, scopes, seen = new Set()) {
  return value.replace(/var\(\s*(--[\w-]+)\s*(?:,\s*([^)]+))?\)/g, (_, name, fallback) => {
    if (seen.has(name)) throw new Error(`Circular CSS variable: ${name}`);
    for (const scope of scopes) {
      if (name in scope) return resolve(scope[name], scopes, new Set([...seen, name]));
    }
    if (fallback !== undefined) return resolve(fallback.trim(), scopes, seen);
    throw new Error(`Unresolved CSS variable: ${name}`);
  });
}

function lookup(name, scopes) {
  const key = `--ina-${name}`;
  for (const scope of scopes) if (key in scope) return resolve(scope[key], scopes);
  throw new Error(`Missing CSS variable: ${key}`);
}

// ---------------------------------------------------------------------------
// Konversi nilai
// ---------------------------------------------------------------------------

/** '#rgb', '#rrggbb', atau '#rrggbbaa' → angka 0xAARRGGBB. */
function hexToArgb(hex) {
  let h = hex.trim().replace('#', '');
  if (h.length === 3) h = h.split('').map((c) => c + c).join('');
  if (h.length === 6) h += 'ff';
  if (h.length !== 8 || /[^0-9a-f]/i.test(h)) throw new Error(`Unsupported color: ${hex}`);
  const rgb = parseInt(h.slice(0, 6), 16);
  const a = parseInt(h.slice(6, 8), 16);
  return ((a << 24) >>> 0) + rgb;
}

function argbHex(argb) {
  return '0x' + argb.toString(16).toUpperCase().padStart(8, '0');
}

function color(value) {
  return `Color(${argbHex(hexToArgb(value))})`;
}

/** '1rem' → 16, '12px' → 12, '0rem' → 0. */
function toPx(value) {
  const m = value.trim().match(/^(-?[\d.]+)(rem|px)?$/);
  if (!m) throw new Error(`Unsupported length: ${value}`);
  const n = parseFloat(m[1]);
  return m[2] === 'rem' ? n * 16 : n;
}

function dartDouble(n) {
  return Number.isInteger(n) ? `${n}.0` : `${n}`;
}

/** Akhiran ukuran CSS → identifier Dart: 3xs → xs3, 2xl → xl2. */
function sizeName(s) {
  const m = s.match(/^(\d)(\w+)$/);
  return m ? `${m[2]}${m[1]}` : s;
}

function parseShadow(value) {
  // Pisahkan di koma yang tidak berada di dalam tanda kurung.
  const parts = [];
  let depth = 0;
  let cur = '';
  for (const ch of value) {
    if (ch === '(') depth++;
    if (ch === ')') depth--;
    if (ch === ',' && depth === 0) {
      parts.push(cur.trim());
      cur = '';
    } else cur += ch;
  }
  if (cur.trim()) parts.push(cur.trim());
  return parts.map((p) => {
    const cm = p.match(/rgba\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*\)/);
    if (!cm) throw new Error(`Unsupported shadow: ${p}`);
    const [x, y, blur, spread] = p.replace(cm[0], '').trim().split(/\s+/).map(toPx);
    const [r, g, b] = cm.slice(1, 4).map(Number);
    const a = Math.round(Number(cm[4]) * 255);
    const argb = ((a << 24) >>> 0) + (r << 16) + (g << 8) + b;
    return { x, y, blur, spread: spread ?? 0, color: argbHex(argb) };
  });
}

// ---------------------------------------------------------------------------
// Model token
// ---------------------------------------------------------------------------

function buildModel(scopes) {
  const { root, light, dark, brand, brandDark } = scopes;
  const lightScopes = [light, root];
  const darkScopes = [dark, light, root];

  const primitives = {};
  for (const p of PRIMITIVE_PALETTES) {
    primitives[p] = {};
    const steps = p === 'neutral' ? [25, ...PALETTE_STEPS, 1000] : PALETTE_STEPS;
    for (const s of steps) primitives[p][s] = lookup(`${p}-${s}`, [root]);
  }
  const overlay = lookup('overlay', [root]);

  const brands = BRANDS.map((b) => {
    const own = b.css ? brand[b.css] : {};
    if (b.css && !own) throw new Error(`Brand not found in CSS: ${b.css}`);
    const ownDark = (b.css && brandDark[b.css]) || {};
    // Brand hanya menimpa sebagian variabel; sisanya memakai :root, sama
    // seperti cascade di browser.
    const l = [own, light, root];
    const d = [ownDark, own, dark, light, root];
    const scale = (prefix) => Object.fromEntries(SCALE_STEPS.map((s) => [s, lookup(`${prefix}-${s}`, l)]));
    const inherited = (prefix) =>
      SCALE_STEPS.filter((s) => !(`--ina-${prefix}-${s}` in own)).filter(() => b.css !== null);
    return {
      ...b,
      primary: scale('primary'),
      secondary: scale('secondary'),
      primaryMainLight: lookup('primary-primary', l),
      primaryMainDark: lookup('primary-primary', d),
      onPrimaryLight: lookup('base-white', l),
      onPrimaryDark: lookup('base-white', d),
      inheritedSecondary: inherited('secondary'),
      extraVars: Object.keys(own).filter((k) => !/^--ina-(primary|secondary|accent)-/.test(k)),
    };
  });

  for (const fix of FIXES) {
    const b = brands.find((x) => x.id === fix.brand);
    fix.original = b[fix.field];
    b[fix.field] = fix.value;
  }

  const semantic = (sc) => ({
    colors: Object.fromEntries(SEMANTIC_COLORS.map(([dart, css]) => [dart, lookup(css, sc)])),
    scales: Object.fromEntries(
      SEMANTIC_SCALES.map(([dart, css]) => [dart, Object.fromEntries(PALETTE_STEPS.map((s) => [s, lookup(`${css}-${s}`, sc)]))]),
    ),
  });

  const varsWith = (prefix) =>
    Object.keys(root)
      .filter((k) => k.startsWith(`--ina-${prefix}-`))
      .map((k) => [k.slice(`--ina-${prefix}-`.length), lookup(k.slice(6), [root])]);

  return {
    primitives,
    overlay,
    brands,
    light: semantic(lightScopes),
    dark: semantic(darkScopes),
    fontSizes: varsWith('font').filter(([k, v]) => /(rem|px)$/.test(v)),
    fontWeights: varsWith('font').filter(([, v]) => /^\d+$/.test(v)),
    lineHeights: varsWith('line-height'),
    spacing: varsWith('spacing'),
    radius: varsWith('radius'),
    shadows: varsWith('shadow').filter(([k]) => k !== 'color'),
    transitions: varsWith('transition'),
    breakpoints: varsWith('breakpoint'),
  };
}

// ---------------------------------------------------------------------------
// Penulis kode Dart
// ---------------------------------------------------------------------------

function header(version, extra = '') {
  return `// GENERATED CODE - DO NOT MODIFY BY HAND.
//
// Source: @idds/styles ${version} (dist/base.css), MIT License.${extra}
// Regenerate with \`npm run generate\` in tool/.
`;
}

function scaleLiteral(cls, scale, steps, indent) {
  const pad = ' '.repeat(indent);
  const lines = steps.map((s) => `${pad}  shade${s}: ${color(scale[s])},`);
  return `${cls}(\n${lines.join('\n')}\n${pad})`;
}

function emitPrimitives(model, version) {
  const out = [header(version)];
  out.push(`import 'dart:ui' show Color;

import '../foundation/idds_color_scale.dart';

/// Palet warna dasar (primitive) IDDS.
///
/// Komponen sebaiknya memakai token semantik di [IddsColors]. Gunakan
/// primitive hanya untuk kebutuhan khusus, misalnya ilustrasi atau grafik.
abstract final class IddsPrimitives {`);
  for (const p of PRIMITIVE_PALETTES) {
    out.push(`  /// \`--ina-${p}-50\` … \`--ina-${p}-900\`.`);
    out.push(`  static const IddsPalette ${p} = ${scaleLiteral('IddsPalette', model.primitives[p], PALETTE_STEPS, 2)};\n`);
  }
  out.push(`  /// \`--ina-neutral-25\`.
  static const Color neutral25 = ${color(model.primitives.neutral[25])};

  /// \`--ina-neutral-1000\`.
  static const Color neutral1000 = ${color(model.primitives.neutral[1000])};

  /// \`--ina-overlay\`.
  static const Color overlay = ${color(model.overlay)};

  /// Semua palet berdasarkan nama.
  static const Map<String, IddsPalette> palettes = <String, IddsPalette>{
${PRIMITIVE_PALETTES.map((p) => `    '${p}': ${p},`).join('\n')}
  };
}
`);
  return out.join('\n');
}

function emitBrands(model, version) {
  const out = [header(version)];
  out.push(`import 'dart:ui' show Color;

import '../foundation/idds_brand.dart';
import '../foundation/idds_color_scale.dart';

/// Brand resmi IDDS seperti yang didefinisikan di \`@idds/styles\`.
abstract final class IddsBrandTokens {`);
  for (const b of model.brands) {
    const sel = b.css ? `\`[data-brand='${b.css}']\`` : '`:root` (default)';
    out.push(`  /// ${b.name}: ${b.description}
  ///
  /// Sumber CSS: ${sel}.${FIXES.filter((f) => f.brand === b.id).map((f) => `\n  ///\n  /// Penyesuaian: \`${f.field}\` = \`${f.value}\` (CSS: \`${f.original}\`).`).join('')}
  static const IddsBrand ${b.id} = IddsBrand(
    id: '${b.id}',
    name: '${b.name}',
    primary: ${scaleLiteral('IddsColorScale', b.primary, SCALE_STEPS, 4)},
    secondary: ${scaleLiteral('IddsColorScale', b.secondary, SCALE_STEPS, 4)},
    primaryMainLight: ${color(b.primaryMainLight)},
    primaryMainDark: ${color(b.primaryMainDark)},
    onPrimaryLight: ${color(b.onPrimaryLight)},
    onPrimaryDark: ${color(b.onPrimaryDark)},
  );
`);
  }
  out.push(`  /// Semua brand resmi, dengan [neutral] sebagai yang pertama.
  static const List<IddsBrand> values = <IddsBrand>[
${model.brands.map((b) => `    ${b.id},`).join('\n')}
  ];
}
`);
  return out.join('\n');
}

function emitColors(model, version) {
  const out = [header(version)];
  const colorFields = SEMANTIC_COLORS.map(([d]) => d);
  const scaleFields = SEMANTIC_SCALES.map(([d]) => d);
  const brandFields = [
    ['primary', 'IddsColorScale', 'Skala warna utama brand (25–900).'],
    ['primaryMain', 'Color', 'Warna utama brand untuk mode aktif (`--ina-primary-primary`).'],
    ['onPrimary', 'Color', 'Warna teks/ikon di atas [primaryMain].'],
    ['secondary', 'IddsColorScale', 'Skala warna sekunder brand (25–900).'],
  ];
  const all = [
    ...brandFields.map(([n, t, d]) => ({ n, t, d })),
    ...SEMANTIC_COLORS.map(([n, css, d]) => ({ n, t: 'Color', d: `${d} (\`--ina-${css}\`)` })),
    ...SEMANTIC_SCALES.map(([n, css, d]) => ({ n, t: 'IddsPalette', d: `${d} (\`--ina-${css}-*\`)` })),
  ];

  const semanticArgs = (sem, indent) => {
    const pad = ' '.repeat(indent);
    return [
      ...colorFields.map((f) => `${pad}${f}: ${color(sem.colors[f])},`),
      ...scaleFields.map((f) => `${pad}${f}: ${scaleLiteral('IddsPalette', sem.scales[f], PALETTE_STEPS, indent)},`),
    ].join('\n');
  };

  const lerpExpr = ({ n, t }) =>
    t === 'Color'
      ? `      ${n}: Color.lerp(${n}, other.${n}, t)!,`
      : `      ${n}: ${t}.lerp(${n}, other.${n}, t),`;

  out.push(`import 'dart:ui' show Brightness, Color;

import 'package:flutter/foundation.dart' show immutable;

import '../foundation/idds_brand.dart';
import '../foundation/idds_color_scale.dart';

/// Semua warna IDDS untuk satu brand dan satu mode (terang/gelap).
///
/// Dapatkan lewat \`IddsTheme.of(context).colors\`.
@immutable
class IddsColors {
  /// Membuat kumpulan warna secara manual. Biasanya cukup pakai
  /// [IddsColors.resolve].
  const IddsColors({
${all.map(({ n }) => `    required this.${n},`).join('\n')}
  });

  /// Menggabungkan warna [brand] dengan token semantik untuk [brightness].
  factory IddsColors.resolve(IddsBrand brand, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final IddsColors semantic = isDark ? _dark : _light;
    return semantic.copyWith(
      primary: brand.primary,
      primaryMain: isDark ? brand.primaryMainDark : brand.primaryMainLight,
      onPrimary: isDark ? brand.onPrimaryDark : brand.onPrimaryLight,
      secondary: brand.secondary,
    );
  }

  static const IddsColors _light = IddsColors(
    primary: IddsColorScale.empty,
    primaryMain: Color(0x00000000),
    onPrimary: Color(0x00000000),
    secondary: IddsColorScale.empty,
${semanticArgs(model.light, 4)}
  );

  static const IddsColors _dark = IddsColors(
    primary: IddsColorScale.empty,
    primaryMain: Color(0x00000000),
    onPrimary: Color(0x00000000),
    secondary: IddsColorScale.empty,
${semanticArgs(model.dark, 4)}
  );

${all.map(({ n, t, d }) => `  /// ${d}\n  final ${t} ${n};`).join('\n\n')}

  /// Salinan dengan sebagian nilai diganti.
  IddsColors copyWith({
${all.map(({ n, t }) => `    ${t}? ${n},`).join('\n')}
  }) {
    return IddsColors(
${all.map(({ n }) => `      ${n}: ${n} ?? this.${n},`).join('\n')}
    );
  }

  /// Interpolasi linear antara dua kumpulan warna (untuk animasi tema).
  IddsColors lerp(IddsColors other, double t) {
    if (identical(this, other)) return this;
    return IddsColors(
${all.map(lerpExpr).join('\n')}
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IddsColors &&
${all.map(({ n }) => `          other.${n} == ${n}`).join(' &&\n')};

  @override
  int get hashCode => Object.hashAll(<Object>[
${all.map(({ n }) => `        ${n},`).join('\n')}
      ]);
}
`);
  return out.join('\n');
}

function emitTypography(model, version) {
  const out = [header(version)];
  const weights = { 100: 'w100', 200: 'w200', 300: 'w300', 400: 'w400', 500: 'w500', 600: 'w600', 700: 'w700', 800: 'w800', 900: 'w900' };
  out.push(`import 'dart:ui' show FontWeight;

/// Ukuran font IDDS dalam logical pixel (\`--ina-font-*\`).
abstract final class IddsFontSize {
${model.fontSizes.map(([k, v]) => `  /// \`--ina-font-${k}\` (${toPx(v)}px).\n  static const double ${sizeName(k)} = ${dartDouble(toPx(v))};`).join('\n\n')}
}

/// Tinggi baris IDDS dalam logical pixel (\`--ina-line-height-*\`).
///
/// Untuk [TextStyle.height], bagi dengan ukuran font:
/// \`height: IddsLineHeight.sm / IddsFontSize.sm\`.
abstract final class IddsLineHeight {
${model.lineHeights.map(([k, v]) => `  /// \`--ina-line-height-${k}\` (${toPx(v)}px).\n  static const double ${sizeName(k)} = ${dartDouble(toPx(v))};`).join('\n\n')}
}

/// Ketebalan font IDDS (\`--ina-font-*\`).
abstract final class IddsFontWeight {
${model.fontWeights.map(([k, v]) => `  /// \`--ina-font-${k}\` (${v}).\n  static const FontWeight ${k} = FontWeight.${weights[v]};`).join('\n\n')}
}
`);
  return out.join('\n');
}

function emitDimensions(model, version) {
  const out = [header(version)];
  const spacing = model.spacing
    .map(([k, v]) => ({ k, px: toPx(v) }))
    .sort((a, b) => a.px - b.px);
  out.push(`import 'dart:ui' show Color, Offset;

import 'package:flutter/animation.dart' show Curve, Curves;
import 'package:flutter/painting.dart' show BoxShadow;

/// Jarak (spacing) IDDS dalam logical pixel.
///
/// Nama mengikuti nilai pixel agar tidak ambigu: [s16] = 16px
/// (\`--ina-spacing-4\` di CSS).
abstract final class IddsSpacing {
${spacing.map(({ k, px }) => `  /// \`--ina-spacing-${k}\`.\n  static const double s${px} = ${dartDouble(px)};`).join('\n\n')}
}

/// Radius sudut IDDS dalam logical pixel (\`--ina-radius-*\`).
abstract final class IddsRadius {
${model.radius.map(([k, v]) => `  /// \`--ina-radius-${k}\` (${toPx(v)}px).\n  static const double ${sizeName(k)} = ${dartDouble(toPx(v))};`).join('\n\n')}
}

/// Bayangan IDDS (\`--ina-shadow-*\`).
abstract final class IddsShadow {
${model.shadows
  .map(([k, v]) => {
    const list = parseShadow(v)
      .map(
        (s) =>
          `    BoxShadow(\n      color: Color(${s.color}),\n      offset: Offset(${dartDouble(s.x)}, ${dartDouble(s.y)}),\n      blurRadius: ${dartDouble(s.blur)},\n      spreadRadius: ${dartDouble(s.spread)},\n    ),`,
      )
      .join('\n');
    return `  /// \`--ina-shadow-${k}\`.\n  static const List<BoxShadow> ${k} = <BoxShadow>[\n${list}\n  ];`;
  })
  .join('\n\n')}
}

/// Durasi transisi IDDS (\`--ina-transition-*\`).
abstract final class IddsDuration {
${model.transitions
  .map(([k, v]) => {
    const ms = parseInt(v.match(/(\d+)ms/)[1], 10);
    return `  /// \`--ina-transition-${k}\` (${v}).\n  static const Duration ${k} = Duration(milliseconds: ${ms});`;
  })
  .join('\n\n')}
}

/// Kurva transisi IDDS. CSS \`ease-in-out\` setara dengan [Curves.easeInOut].
abstract final class IddsCurves {
  /// \`ease-in-out\`.
  static const Curve standard = Curves.easeInOut;
}

/// Breakpoint responsif IDDS dalam logical pixel (\`--ina-breakpoint-*\`).
abstract final class IddsBreakpoint {
${model.breakpoints.map(([k, v]) => `  /// \`--ina-breakpoint-${k}\`.\n  static const double ${k} = ${dartDouble(toPx(v))};`).join('\n\n')}
}
`);
  return out.join('\n');
}

// ---------------------------------------------------------------------------
// Figma (opsional)
// ---------------------------------------------------------------------------

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function flattenFigma(obj, prefix = '') {
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    if (k.startsWith('$')) continue;
    if (v && typeof v === 'object' && '$type' in v) {
      const val = v.$value;
      out[prefix + k] =
        v.$type === 'color'
          ? { hex: val.hex.toLowerCase() + (val.alpha < 1 ? Math.round(val.alpha * 255).toString(16).padStart(2, '0') : ''), alpha: val.alpha }
          : { number: val };
    } else if (v && typeof v === 'object') Object.assign(out, flattenFigma(v, `${prefix}${k}/`));
  }
  return out;
}

function figmaChartTokens() {
  const file = path.join(FIGMA_DIR, 'visualization', 'Visualization.tokens.json');
  if (!fs.existsSync(file)) return null;
  const flat = flattenFigma(readJson(file));
  const group = (name) =>
    Object.entries(flat)
      .filter(([k]) => k.startsWith(`Chart/${name}/`))
      .sort(([a], [b]) => parseInt(a.split('/').pop(), 10) - parseInt(b.split('/').pop(), 10))
      .map(([, v]) => v.hex);
  return {
    single: flat['Chart/Single Data/Primary'].hex,
    sequential: group('Set Data'),
    categorical: group('Categorical Data'),
  };
}

function emitChart(chart, version) {
  return `${header(version, '\n// Chart colors: Figma "Data Visualization" collection (tool/figma/visualization).')}
import 'dart:ui' show Color;

/// Warna grafik IDDS (koleksi Figma "Data Visualization").
///
/// Warna ini tidak mengikuti brand dan belum memiliki varian dark mode.
abstract final class IddsChartColors {
  /// Satu seri data.
  static const Color single = ${color(chart.single)};

  /// Data berurutan, dari paling terang ke paling gelap.
  static const List<Color> sequential = <Color>[
${chart.sequential.map((h) => `    ${color(h)},`).join('\n')}
  ];

  /// Data kategorikal, dipakai berurutan untuk tiap seri.
  static const List<Color> categorical = <Color>[
${chart.categorical.map((h) => `    ${color(h)},`).join('\n')}
  ];
}
`;
}

function normalizeHex(h) {
  let x = h.toLowerCase();
  if (x.length === 4) x = '#' + x.slice(1).split('').map((c) => c + c).join('');
  if (x.length === 9 && x.endsWith('ff')) x = x.slice(0, 7);
  return x;
}

function figmaReport(model, version) {
  if (!fs.existsSync(FIGMA_DIR)) return null;
  const rows = [];
  const missing = [];
  const add = (area, token, figma, css) => {
    if (figma === undefined) return missing.push(`${area}: ${token} (tidak ada di Figma)`);
    if (normalizeHex(figma) !== normalizeHex(css)) rows.push({ area, token, figma, css });
  };

  // Primitive
  const primFile = path.join(FIGMA_DIR, 'primitives', 'Primitives.tokens.json');
  if (fs.existsSync(primFile)) {
    const prim = flattenFigma(readJson(primFile));
    for (const p of PRIMITIVE_PALETTES) {
      const fName = p[0].toUpperCase() + p.slice(1);
      for (const [s, css] of Object.entries(model.primitives[p])) {
        const f = prim[`${fName}/${s}`];
        if (f) add('Primitives', `${fName}/${s}`, f.hex, css);
      }
    }
    for (const b of model.brands.filter((x) => x.css)) {
      const fName = { inagov: 'INAgov', inapas: 'INApas', inaku: 'INAku' }[b.id] || b.id.toUpperCase();
      for (const s of SCALE_STEPS) {
        const f = prim[`${fName}/Primary/${s}`] || prim[`${fName}/${s}`];
        if (f) add('Primitives (brand)', `${fName}/Primary/${s}`, f.hex, b.primary[s]);
      }
    }
  }

  // Mode brand
  const brandDir = path.join(FIGMA_DIR, 'brand');
  const figmaBrands = new Set();
  if (fs.existsSync(brandDir)) {
    for (const file of fs.readdirSync(brandDir).filter((f) => f.endsWith('.json'))) {
      const data = readJson(path.join(brandDir, file));
      const mode = data.$extensions?.['com.figma.modeName'] || file.split('.')[0];
      const b = model.brands.find((x) => x.id === mode.toLowerCase());
      figmaBrands.add(mode.toLowerCase());
      if (!b) {
        missing.push(`Brand ${mode} ada di Figma tetapi tidak ada di CSS`);
        continue;
      }
      const flat = flattenFigma(data);
      for (const s of SCALE_STEPS) {
        add(`Brand ${b.name}`, `Primary/${s}`, flat[`Primary/${s}`]?.hex, b.primary[s]);
        add(`Brand ${b.name}`, `Secondary/${s}`, flat[`Secondary/${s}`]?.hex, b.secondary[s]);
      }
      add(`Brand ${b.name}`, 'Primary/Primary (warna utama)', flat['Primary/Primary']?.hex, b.primaryMainLight);
    }
  }

  // Mode produk (semantik)
  const productMap = {
    'Base/White': 'baseWhite',
    'Background/Primary': 'backgroundPrimary',
    'Background/Secondary': 'backgroundSecondary',
    'Background/Tertiary': 'backgroundTertiary',
    'Background/Overlay': 'backgroundOverlay',
    'Content/Primary': 'contentPrimary',
    'Content/Secondary': 'contentSecondary',
    'Content/Tertiary': 'contentTertiary',
    'Content/Guide': 'contentGuide',
    'Content/Negative': 'contentNegative',
    'Content/Positive': 'contentPositive',
    'Stroke/Primary': 'strokePrimary',
    'Stroke/Secondary': 'strokeSecondary',
    'Stroke/Tertiary': 'strokeTertiary',
  };
  for (const mode of ['Light', 'Dark']) {
    const file = path.join(FIGMA_DIR, 'product', `${mode}.tokens.json`);
    if (!fs.existsSync(file)) continue;
    const flat = flattenFigma(readJson(file));
    const sem = mode === 'Light' ? model.light : model.dark;
    for (const [f, d] of Object.entries(productMap)) {
      // "Base/White" di Figma mengikuti mode, sama dengan --ina-white di CSS.
      const cssVal = f === 'Base/White' ? sem.colors.white : sem.colors[d];
      add(`Product ${mode}`, f, flat[f]?.hex, cssVal);
    }
    for (const [fig, scale] of [['Guide', 'guide'], ['Negative', 'negative'], ['Positive', 'positive'], ['Warning', 'warning']]) {
      for (const s of PALETTE_STEPS) add(`Product ${mode}`, `${fig}/${s}`, flat[`${fig}/${s}`]?.hex, sem.scales[scale][s]);
    }
  }

  const cssOnlyBrands = model.brands.filter((b) => b.css && !figmaBrands.has(b.id)).map((b) => b.name);
  const inherited = model.brands
    .filter((b) => b.inheritedSecondary.length)
    .map((b) => `- ${b.name}: secondary ${b.inheritedSecondary.join(', ')} tidak didefinisikan, memakai nilai \`:root\``);
  const extras = model.brands
    .filter((b) => b.extraVars.length)
    .map((b) => `- ${b.name}: ${b.extraVars.map((v) => `\`${v}\``).join(', ')}`);

  const table = rows.length
    ? ['| Area | Token | Figma | CSS (dipakai) |', '|---|---|---|---|', ...rows.map((r) => `| ${r.area} | ${r.token} | \`${r.figma}\` | \`${r.css}\` |`)].join('\n')
    : 'Tidak ada perbedaan.';

  const fixes = FIXES.map((f) => `| ${f.brand} | ${f.field} | \`${f.original}\` | \`${f.value}\` | ${f.reason} |`).join('\n');

  return `# Perbedaan token Figma vs @idds/styles

Dibuat otomatis oleh \`tool/generate_tokens.mjs\`. Sumber kebenaran untuk
idds_flutter adalah CSS \`@idds/styles\` ${version}; Figma hanya pembanding.

## Penyesuaian idds_flutter (sengaja berbeda dari CSS)

| Brand | Field | CSS | idds_flutter | Alasan |
|---|---|---|---|---|
${fixes}

## Nilai Figma yang berbeda dari CSS (${rows.length})

${table}

## Brand yang hanya ada di CSS

${cssOnlyBrands.length ? cssOnlyBrands.map((b) => `- ${b}`).join('\n') : '- (tidak ada)'}

## Warna secondary yang diwarisi dari \`:root\`

${inherited.length ? inherited.join('\n') : '- (tidak ada)'}

## Variabel brand khusus yang belum dipetakan ke Dart

${extras.length ? extras.join('\n') : '- (tidak ada)'}

## Catatan lain

${missing.length ? missing.map((m) => `- ${m}`).join('\n') : '- (tidak ada)'}
`;
}

// ---------------------------------------------------------------------------
// Utama
// ---------------------------------------------------------------------------

function main() {
  const cssFile = path.join(STYLES_DIR, 'dist', 'base.css');
  if (!fs.existsSync(cssFile)) {
    console.error('@idds/styles belum terpasang. Jalankan `npm install` di folder tool/ terlebih dahulu.');
    process.exit(1);
  }
  const version = readJson(path.join(STYLES_DIR, 'package.json')).version;
  const model = buildModel(collectScopes(parseCss(fs.readFileSync(cssFile, 'utf8'))));

  fs.mkdirSync(OUT_DIR, { recursive: true });
  const files = {
    'idds_primitives.g.dart': emitPrimitives(model, version),
    'idds_brand_tokens.g.dart': emitBrands(model, version),
    'idds_colors.g.dart': emitColors(model, version),
    'idds_typography_tokens.g.dart': emitTypography(model, version),
    'idds_dimension_tokens.g.dart': emitDimensions(model, version),
  };
  const chart = figmaChartTokens();
  if (chart) files['idds_chart_colors.g.dart'] = emitChart(chart, version);

  for (const [name, content] of Object.entries(files)) {
    fs.writeFileSync(path.join(OUT_DIR, name), content);
    console.log(`  wrote lib/src/tokens/${name}`);
  }
  fs.mkdirSync(path.dirname(REPORT_PATH), { recursive: true });
  fs.writeFileSync(path.join(path.dirname(REPORT_PATH), 'tokens.json'), JSON.stringify(model, null, 2) + '\n');
  console.log('  wrote tool/reports/tokens.json');

  const report = figmaReport(model, version);
  if (report) {
    fs.mkdirSync(path.dirname(REPORT_PATH), { recursive: true });
    fs.writeFileSync(REPORT_PATH, report);
    console.log('  wrote tool/reports/figma-diff.md');
  }
  console.log(`Selesai: token dari @idds/styles ${version}.`);
}

main();
