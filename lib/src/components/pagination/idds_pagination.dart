import 'dart:math' as math;

import 'package:flutter/material.dart' show InputDecoration, TextField, VisualDensity;
import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputFormatter, TextInputType;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_material_shim.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../dropdown/idds_dropdown_trigger.dart';
import '../dropdown/idds_select.dart';

/// Navigasi halaman untuk data yang dibagi per halaman.
///
/// Menampilkan "Halaman [n] dari N" (layar ≥ 580px) dan tombol pertama,
/// sebelumnya, tiga nomor halaman di sekitar halaman aktif, berikutnya, dan
/// terakhir.
///
/// ```dart
/// IddsPagination(
///   currentPage: _page,
///   totalPages: 12,
///   onPageChanged: (p) => setState(() => _page = p),
/// )
/// ```
///
/// Isi [onPageSizeChanged] untuk menampilkan pilihan jumlah baris per
/// halaman.
class IddsPagination extends StatelessWidget {
  /// Membuat pagination.
  const IddsPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.showPageInput = true,
    this.pageLabel = 'Halaman',
    this.ofLabel = 'dari',
    this.pageSize,
    this.pageSizeOptions = const <int>[10, 20, 50, 100],
    this.onPageSizeChanged,
    this.pageSizeLabel = 'Baris per halaman',
  });

  /// Halaman aktif, mulai dari 1.
  final int currentPage;

  /// Jumlah halaman. Bila 0 atau kurang, tidak ada yang ditampilkan.
  final int totalPages;

  /// Dipanggil dengan nomor halaman baru. `null` membuat pagination nonaktif.
  final ValueChanged<int>? onPageChanged;

  /// Tampilkan "Halaman [n] dari N" dengan kolom isian halaman.
  final bool showPageInput;

  /// Teks "Halaman".
  final String pageLabel;

  /// Teks "dari".
  final String ofLabel;

  /// Jumlah baris per halaman saat ini. Bawaan: opsi pertama
  /// [pageSizeOptions].
  final int? pageSize;

  /// Pilihan jumlah baris per halaman.
  final List<int> pageSizeOptions;

  /// Dipanggil dengan jumlah baris baru. Bila `null`, pilihan jumlah baris
  /// tidak ditampilkan.
  final ValueChanged<int>? onPageSizeChanged;

  /// Teks di depan pilihan jumlah baris.
  final String pageSizeLabel;

  /// Nomor halaman yang ditampilkan, sama seperti versi web.
  static List<int> visiblePages(int current, int total) {
    final int start;
    final int end;
    if (current <= 1) {
      start = 1;
      end = math.min(3, total);
    } else if (current >= total) {
      start = math.max(1, total - 2);
      end = total;
    } else {
      start = current - 1;
      end = current + 1;
    }
    return <int>[for (int p = start; p <= end; p++) p];
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 0) return const SizedBox.shrink();
    final IddsThemeData theme = IddsTheme.of(context);
    final double screen = iddsScreenWidth(context);
    final double width = theme.compactOnSmallScreens ? screen : double.infinity;
    final bool xl = width >= IddsBreakpoint.xl;
    final bool lg = width >= IddsBreakpoint.lg;
    final _Metrics m = _Metrics(
      button: xl ? 32 : (lg ? 28 : 24),
      radius: xl ? IddsRadius.lg : IddsRadius.md,
      icon: lg ? 14 : 16,
      fontSize: xl ? IddsFontSize.sm : IddsFontSize.xs,
      lineHeight: xl ? IddsLineHeight.sm : IddsLineHeight.xs,
      fontWeight: xl ? IddsFontWeight.medium : IddsFontWeight.normal,
    );
    final bool enabled = onPageChanged != null;
    final int page = currentPage.clamp(1, totalPages);

    void go(int p) {
      if (enabled && p != page && p >= 1 && p <= totalPages) onPageChanged!(p);
    }

    final Widget nav = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: IddsSpacing.s4,
      children: <Widget>[
        _NavButton(icon: IddsIcons.chevronsLeft, label: 'Halaman pertama', m: m, onTap: enabled && page > 1 ? () => go(1) : null),
        _NavButton(icon: IddsIcons.chevronLeft, label: 'Halaman sebelumnya', m: m, onTap: enabled && page > 1 ? () => go(page - 1) : null),
        for (final int p in visiblePages(page, totalPages))
          _PageButton(page: p, active: p == page, m: m, onTap: enabled ? () => go(p) : null),
        _NavButton(icon: IddsIcons.chevronRight, label: 'Halaman berikutnya', m: m, onTap: enabled && page < totalPages ? () => go(page + 1) : null),
        _NavButton(icon: IddsIcons.chevronsRight, label: 'Halaman terakhir', m: m, onTap: enabled && page < totalPages ? () => go(totalPages) : null),
      ],
    );

    final bool showInfo = showPageInput && screen >= 580;
    final ValueChanged<int>? onSize = onPageSizeChanged;
    final Widget? sizeSelect = onSize == null || pageSizeOptions.isEmpty
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            spacing: IddsSpacing.s8,
            children: <Widget>[
              Text(pageSizeLabel),
              IddsSelect<int>(
                size: IddsDropdownSize.sm,
                width: 80,
                value: pageSize ?? pageSizeOptions.first,
                onChanged: enabled
                    ? (int? v) {
                        if (v != null) onSize(v);
                      }
                    : null,
                options: <IddsSelectOption<int>>[
                  for (final int n in pageSizeOptions) IddsSelectOption<int>(value: n, label: '$n'),
                ],
              ),
            ],
          );
    return Semantics(
      container: true,
      label: 'Pagination',
      explicitChildNodes: true,
      child: DefaultTextStyle(
        style: theme.textStyle(fontSize: m.fontSize, lineHeight: m.lineHeight, fontWeight: m.fontWeight),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: lg ? IddsSpacing.s16 : IddsSpacing.s8,
          runSpacing: IddsSpacing.s8,
          children: <Widget>[
            if (sizeSelect != null) sizeSelect,
            if (showInfo)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(pageLabel),
                  _PageInput(page: page, total: totalPages, m: m, onSubmit: enabled ? go : null),
                  Text('$ofLabel $totalPages'),
                ],
              ),
            nav,
          ],
        ),
      ),
    );
  }
}

class _Metrics {
  const _Metrics({
    required this.button,
    required this.radius,
    required this.icon,
    required this.fontSize,
    required this.lineHeight,
    required this.fontWeight,
  });

  final double button;
  final double radius;
  final double icon;
  final double fontSize;
  final double lineHeight;
  final FontWeight fontWeight;
}

/// Gaya fokus pagination (CSS: latar neutral-100, garis 2px primary-600).
BoxDecoration _focusDecoration(IddsColors c, double radius) => BoxDecoration(
      // CSS: neutral-100, yang terlalu terang di dark mode.
      color: c.backgroundTertiary,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: c.primary.shade600, width: 2),
    );

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, required this.m, required this.onTap});

  final IddsIconData icon;
  final String label;
  final _Metrics m;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) {
          return Opacity(
            opacity: state.enabled ? 1 : 0.5,
            child: AnimatedContainer(
              duration: IddsDuration.base,
              width: m.button,
              height: m.button,
              alignment: Alignment.center,
              decoration: state.focused
                  ? _focusDecoration(c, m.radius)
                  : BoxDecoration(
                      color: state.pressed
                          ? c.backgroundTertiary
                          : state.hovered
                              ? c.backgroundSecondary
                              : c.backgroundPrimary,
                      borderRadius: BorderRadius.circular(m.radius),
                    ),
              child: IddsIcon(
                icon,
                size: m.icon,
                color: state.enabled ? c.contentPrimary : c.contentTertiary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({required this.page, required this.active, required this.m, required this.onTap});

  final int page;
  final bool active;
  final _Metrics m;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      button: true,
      selected: active,
      label: 'Halaman $page',
      enabled: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) {
          final bool hover = state.hovered && !active;
          return Opacity(
            opacity: state.enabled ? 1 : 0.5,
            child: AnimatedContainer(
              duration: IddsDuration.base,
              constraints: BoxConstraints(minWidth: m.button),
              height: m.button,
              padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s2),
              alignment: Alignment.center,
              decoration: state.focused
                  ? _focusDecoration(c, m.radius)
                  : BoxDecoration(
                      color: state.pressed && !active
                          ? c.strokePrimary
                          : hover
                              ? c.backgroundTertiary
                              : c.backgroundPrimary,
                      borderRadius: BorderRadius.circular(m.radius),
                      border: Border.all(
                        color: active
                            ? c.strokeTertiary
                            : hover
                                ? c.strokePrimary
                                : const Color(0x00000000),
                      ),
                    ),
              child: Text('$page'),
            ),
          );
        },
      ),
    );
  }
}

class _PageInput extends StatefulWidget {
  const _PageInput({required this.page, required this.total, required this.m, required this.onSubmit});

  final int page;
  final int total;
  final _Metrics m;
  final ValueChanged<int>? onSubmit;

  @override
  State<_PageInput> createState() => _PageInputState();
}

class _PageInputState extends State<_PageInput> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.page}');
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!mounted) return;
      if (!_focus.hasFocus) _submit();
      setState(() {});
    });
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(_PageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) _controller.text = '${widget.page}';
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final int parsed = int.tryParse(_controller.text) ?? 1;
    final int page = parsed.clamp(1, widget.total);
    _controller.text = '$page';
    if (page != widget.page) widget.onSubmit?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool enabled = widget.onSubmit != null;
    final TextStyle style = DefaultTextStyle.of(context).style;
    // CSS: lebar = jumlah karakter + 12px, minimal 28px.
    final double width = math.max(28, _controller.text.length * style.fontSize! * 0.62 + 12);
    final BorderRadius radius = BorderRadius.circular(IddsRadius.md);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s6),
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: IddsInsetRing(
          visible: _focus.hasFocus,
          borderRadius: radius,
          inset: 1,
          rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.contentPrimary)],
          child: Container(
            width: width,
            padding: const EdgeInsets.all(IddsSpacing.s4 - 1),
            decoration: BoxDecoration(
              color: c.backgroundPrimary,
              borderRadius: radius,
              border: Border.all(color: _focus.hasFocus ? c.strokeTertiary : c.strokePrimary),
            ),
            child: iddsMaterialShim(
              context,
              TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                style: style.copyWith(color: c.contentPrimary),
                cursorColor: c.contentPrimary,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration.collapsed(hintText: null).copyWith(
                  visualDensity: VisualDensity.standard,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
