import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/vs.dart';
import 'package:re_highlight/styles/vs2015.dart';

/// Judul, contoh hidup, dan dokumentasi pemakaian satu bagian galeri.
class GallerySection extends StatelessWidget {
  const GallerySection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.usage,
    this.code,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  /// Penjelasan singkat cara memakai komponen.
  final String? usage;

  /// Contoh kode yang bisa disalin.
  final String? code;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: IddsSpacing.s40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textStyle(
              fontSize: IddsFontSize.lg,
              lineHeight: IddsLineHeight.lg,
              fontWeight: IddsFontWeight.semibold,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: IddsSpacing.s4),
            GalleryCaption(subtitle!),
          ],
          const SizedBox(height: IddsSpacing.s16),
          ...children,
          if (usage != null || code != null) ...<Widget>[
            const SizedBox(height: IddsSpacing.s24),
            Text(
              'Cara pakai',
              style: theme.textStyle(
                fontSize: IddsFontSize.base,
                lineHeight: IddsLineHeight.base,
                fontWeight: IddsFontWeight.semibold,
                color: theme.colors.contentPrimary,
              ),
            ),
            if (usage != null) ...<Widget>[
              const SizedBox(height: IddsSpacing.s4),
              Text(
                usage!,
                style: theme.textStyle(
                  fontSize: IddsFontSize.sm,
                  lineHeight: IddsLineHeight.sm,
                  color: theme.colors.contentSecondary,
                ),
              ),
            ],
            if (code != null) ...<Widget>[
              const SizedBox(height: IddsSpacing.s12),
              GalleryCodeBlock(code: code!),
            ],
          ],
        ],
      ),
    );
  }
}

/// Teks kecil berwarna sekunder.
class GalleryCaption extends StatelessWidget {
  const GalleryCaption(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return Text(
      text,
      style: theme.textStyle(
        fontSize: IddsFontSize.xs,
        lineHeight: IddsLineHeight.xs,
        color: theme.colors.contentSecondary,
      ),
    );
  }
}

/// Pewarna sintaks Dart (package re_highlight, port highlight.js) dengan
/// tema VS Code Light (vs) dan Dark+ (vs2015).
final Highlight _highlight = Highlight()..registerLanguage('dart', langDart);

/// Tema tanpa warna latar per huruf; latar diatur oleh panel editor.
Map<String, TextStyle> _withoutBackground(Map<String, TextStyle> theme) => <String, TextStyle>{
      for (final MapEntry<String, TextStyle> e in theme.entries)
        e.key: TextStyle(
          color: e.value.color,
          fontWeight: e.value.fontWeight,
          fontStyle: e.value.fontStyle,
          decoration: e.value.decoration,
        ),
    };

final Map<String, TextStyle> _lightTheme = _withoutBackground(vsTheme);
final Map<String, TextStyle> _darkTheme = _withoutBackground(vs2015Theme);

/// Warna bergaya editor VS Code (Light+ / Dark+).
class _EditorColors {
  const _EditorColors({
    required this.background,
    required this.header,
    required this.gutter,
    required this.lineNumber,
    required this.text,
  });

  static const _EditorColors light = _EditorColors(
    background: Color(0xFFFFFFFF),
    header: Color(0xFFF3F3F3),
    gutter: Color(0xFFFFFFFF),
    lineNumber: Color(0xFF237893),
    text: Color(0xFF000000),
  );

  static const _EditorColors dark = _EditorColors(
    background: Color(0xFF1E1E1E),
    header: Color(0xFF252526),
    gutter: Color(0xFF1E1E1E),
    lineNumber: Color(0xFF858585),
    text: Color(0xFFD4D4D4),
  );

  final Color background;
  final Color header;
  final Color gutter;
  final Color lineNumber;
  final Color text;
}

/// Blok kode Dart bergaya editor VS Code: nomor baris, pewarnaan sintaks,
/// tombol salin, dan bisa disembunyikan.
class GalleryCodeBlock extends StatefulWidget {
  const GalleryCodeBlock({super.key, required this.code, this.initiallyExpanded = true, this.fileName = 'contoh.dart'});

  final String code;
  final bool initiallyExpanded;

  /// Nama yang tampil di tab editor.
  final String fileName;

  @override
  State<GalleryCodeBlock> createState() => _GalleryCodeBlockState();
}

class _GalleryCodeBlockState extends State<GalleryCodeBlock> {
  late bool _expanded = widget.initiallyExpanded;
  bool _copied = false;
  Timer? _reset;

  // Hasil pewarnaan terakhir, agar tidak dihitung ulang di setiap build.
  String? _cachedCode;
  bool? _cachedDark;
  TextSpan? _cachedSpan;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  String get _code => widget.code.trim();

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _code));
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  TextSpan _highlighted(bool dark, TextStyle base) {
    if (_cachedSpan == null || _cachedCode != _code || _cachedDark != dark) {
      final TextSpanRenderer renderer = TextSpanRenderer(base, dark ? _darkTheme : _lightTheme);
      _highlight.highlight(code: _code, language: 'dart').render(renderer);
      _cachedCode = _code;
      _cachedDark = dark;
      _cachedSpan = renderer.span ?? TextSpan(text: _code, style: base);
    }
    return _cachedSpan!;
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final bool dark = theme.isDark;
    final _EditorColors e = dark ? _EditorColors.dark : _EditorColors.light;
    final IddsColors c = theme.colors;
    final BorderSide line = BorderSide(color: c.strokePrimary);
    const List<String> mono = <String>['Menlo', 'Consolas', 'Roboto Mono', 'Courier New', 'monospace'];
    // Ukuran dan tinggi baris sama untuk nomor baris dan kode agar sejajar.
    final TextStyle base = TextStyle(
      fontFamily: 'Menlo',
      fontFamilyFallback: mono,
      fontSize: 13,
      height: 1.6,
      color: e.text,
    );
    final int lines = '\n'.allMatches(_code).length + 1;
    // Layar sempit: tombol lipat hanya ikon agar kepala editor tidak meluber.
    final bool narrow = MediaQuery.sizeOf(context).width < 600;
    final TextStyle headerStyle = theme.textStyle(
      fontSize: IddsFontSize.xs,
      lineHeight: IddsLineHeight.xs,
      color: dark ? const Color(0xFFCCCCCC) : const Color(0xFF616161),
    );

    final Widget header = Container(
      height: 40,
      padding: const EdgeInsets.only(right: IddsSpacing.s8),
      decoration: BoxDecoration(
        color: e.header,
        border: _expanded ? Border(bottom: line) : null,
      ),
      child: Row(
        spacing: IddsSpacing.s8,
        children: <Widget>[
          // Tab berkas seperti di VS Code. Expanded mengisi sisa ruang
          // sehingga tombol selalu rata kanan.
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12),
                decoration: BoxDecoration(
                  color: _expanded ? e.background : null,
                  border: Border(top: BorderSide(color: _expanded ? c.primaryMain : Colors.transparent, width: 2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: IddsSpacing.s6,
                  children: <Widget>[
                    const Icon(TablerIcons.brand_flutter, size: 16, color: Color(0xFF42A5F5)),
                    Flexible(
                      child: Text(widget.fileName, style: headerStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IddsButton(
            hierarchy: IddsButtonHierarchy.tertiary,
            size: IddsButtonSize.sm,
            semanticLabel: _expanded ? 'Sembunyikan kode' : 'Tampilkan kode',
            onPressed: () => setState(() => _expanded = !_expanded),
            suffixIcon: narrow ? null : Icon(_expanded ? TablerIcons.chevron_up : TablerIcons.chevron_down),
            child: narrow
                ? Icon(_expanded ? TablerIcons.chevron_up : TablerIcons.chevron_down)
                : Text(_expanded ? 'Sembunyikan' : 'Tampilkan kode'),
          ),
          IddsButton(
            hierarchy: IddsButtonHierarchy.secondary,
            size: IddsButtonSize.sm,
            semanticLabel: _copied ? 'Kode tersalin' : 'Salin kode',
            onPressed: _copy,
            prefixIcon: Icon(_copied ? TablerIcons.check : TablerIcons.copy),
            child: Text(_copied ? 'Tersalin' : 'Salin'),
          ),
        ],
      ),
    );

    final StrutStyle strut = StrutStyle(
      fontFamily: base.fontFamily,
      fontFamilyFallback: base.fontFamilyFallback,
      fontSize: base.fontSize,
      height: base.height,
      forceStrutHeight: true,
    );
    final Widget body = Container(
      color: e.background,
      padding: const EdgeInsets.symmetric(vertical: IddsSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Nomor baris (tidak ikut terseleksi/tersalin).
          ExcludeSemantics(
            child: Container(
              color: e.gutter,
              padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s16),
              child: Text(
                List<String>.generate(lines, (int i) => '${i + 1}').join('\n'),
                textAlign: TextAlign.right,
                strutStyle: strut,
                style: base.copyWith(color: e.lineNumber),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: IddsSpacing.s16),
              // Tanpa pemenggalan baris agar sejajar dengan nomornya.
              child: SelectableText.rich(_highlighted(dark, base), strutStyle: strut),
            ),
          ),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: e.background, borderRadius: BorderRadius.circular(IddsRadius.lg)),
      // Garis tepi di atas isi; bila ikut di decoration, latar header
      // menutupi garis di sudut atas yang membulat.
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(IddsRadius.lg),
        border: Border.fromBorderSide(line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[header, if (_expanded) body],
      ),
    );
  }
}

void showGallerySnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
}
