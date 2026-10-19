import 'package:flutter/material.dart' show InputDecoration, TextField, VisualDensity;
import 'package:flutter/services.dart' show LogicalKeyboardKey, TextInputFormatter, TextInputType;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_material_shim.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Isian ringkas untuk mengedit langsung di sel tabel (Field Input Table
/// IDDS): garis bawah, tombol simpan (✓) dan batal (✕).
///
/// Enter menyimpan, Esc membatalkan. Dipakai otomatis oleh [IddsTable] untuk
/// kolom yang punya `editor`, tetapi bisa juga dipakai sendiri.
class IddsTableFieldInput extends StatefulWidget {
  /// Membuat isian sel.
  const IddsTableFieldInput({
    super.key,
    required this.controller,
    required this.onCommit,
    required this.onCancel,
    this.placeholder,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.autofocus = true,
    this.commitLabel = 'Simpan',
    this.cancelLabel = 'Batal',
  });

  /// Pengendali teks.
  final TextEditingController controller;

  /// Dipanggil saat Enter atau tombol ✓ ditekan.
  final VoidCallback onCommit;

  /// Dipanggil saat Esc atau tombol ✕ ditekan.
  final VoidCallback onCancel;

  /// Teks petunjuk saat kosong.
  final String? placeholder;

  /// Pesan galat di bawah isian; garis bawah menjadi merah.
  final String? errorText;

  /// Jenis papan ketik.
  final TextInputType? keyboardType;

  /// Pembatas masukan.
  final List<TextInputFormatter>? inputFormatters;

  /// Langsung fokus saat muncul.
  final bool autofocus;

  /// Label pembaca layar tombol simpan.
  final String commitLabel;

  /// Label pembaca layar tombol batal.
  final String cancelLabel;

  @override
  State<IddsTableFieldInput> createState() => _IddsTableFieldInputState();
}

class _IddsTableFieldInputState extends State<IddsTableFieldInput> {
  final FocusNode _focus = FocusNode();
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool invalid = widget.errorText != null;
    final Color underline = invalid
        ? c.negative.shade500
        : _focus.hasFocus
            ? c.primary.shade500
            : _hovered
                ? c.strokeSecondary
                : c.strokePrimary;
    final TextStyle style = theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentPrimary);

    final Widget field = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: IddsDuration.base,
        padding: const EdgeInsets.symmetric(vertical: IddsSpacing.s4),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: underline, width: 2))),
        child: iddsMaterialShim(
          context,
          TextField(
            controller: widget.controller,
            focusNode: _focus,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            style: style,
            cursorColor: c.contentPrimary,
            onSubmitted: (_) => widget.onCommit(),
            decoration: InputDecoration.collapsed(
              hintText: widget.placeholder,
              hintStyle: style.copyWith(color: c.contentTertiary),
            ).copyWith(visualDensity: VisualDensity.standard),
          ),
        ),
      ),
    );

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): widget.onCancel,
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: IddsSpacing.s2,
        children: <Widget>[
          Row(
            spacing: IddsSpacing.s8,
            children: <Widget>[
              Expanded(child: field),
              _ActionButton(
                icon: IddsIcons.check,
                strokeWidth: 3,
                color: c.positive.shade500,
                hoverColor: c.positive.shade600,
                label: widget.commitLabel,
                onTap: widget.onCommit,
              ),
              _ActionButton(
                icon: IddsIcons.x,
                strokeWidth: 2,
                color: c.negative.shade500,
                hoverColor: c.negative.shade600,
                label: widget.cancelLabel,
                onTap: widget.onCancel,
              ),
            ],
          ),
          if (invalid)
            Text(
              widget.errorText!,
              style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.negative.shade600),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.strokeWidth,
    required this.color,
    required this.hoverColor,
    required this.label,
    required this.onTap,
  });

  final IddsIconData icon;
  final double strokeWidth;
  final Color color;
  final Color hoverColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(IddsRadius.base),
          rings: <(double, Color)>[(2.0, color)],
          child: AnimatedScale(
            scale: state.pressed ? 0.95 : 1,
            duration: IddsDuration.fast,
            child: AnimatedContainer(
              duration: IddsDuration.base,
              padding: const EdgeInsets.all(IddsSpacing.s4),
              decoration: BoxDecoration(
                // CSS: neutral-100/200 (terang di dark mode) → latar tersier.
                color: state.pressed
                    ? c.strokePrimary
                    : state.hovered
                        ? c.backgroundTertiary
                        : null,
                borderRadius: BorderRadius.circular(IddsRadius.base),
              ),
              child: IddsIcon(icon, size: 20, strokeWidth: strokeWidth, color: state.hovered ? hoverColor : color),
            ),
          ),
        ),
      ),
    );
  }
}
