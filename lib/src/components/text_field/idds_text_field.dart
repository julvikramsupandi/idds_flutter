// Kolom teks memakai TextField Material di dalamnya, karena TextField sudah
// menangani seleksi, toolbar salin/tempel, IME, dan autofill di semua
// platform. Ancestor Material yang dibutuhkan disediakan otomatis, jadi
// IddsTextField tetap bisa dipakai di WidgetsApp atau CupertinoApp.
import 'package:flutter/material.dart'
    show
        InputDecoration,
        TextField,
        TextSelectionTheme,
        TextSelectionThemeData,
        VisualDensity;
import 'package:flutter/services.dart'
    show LengthLimitingTextInputFormatter, SystemMouseCursors, TextInputAction, TextInputFormatter, TextInputType;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_material_shim.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Status visual [IddsTextField].
enum IddsTextFieldStatus {
  /// Normal.
  neutral,

  /// Error (merah).
  error,

  /// Peringatan (kuning).
  warning,

  /// Berhasil (hijau).
  success,
}

/// Ukuran [IddsTextField]. Tinggi di layar ≥ 768px, 640–767px, dan < 640px:
///
/// | Ukuran | Tinggi |
/// |---|---|
/// | [sm] | 40 / 36 / 32 |
/// | [md] | 44 / 40 / 36 |
/// | [lg] | 48 / 44 / 40 |
enum IddsTextFieldSize {
  /// Kecil.
  sm(40),

  /// Sedang (bawaan).
  md(44),

  /// Besar.
  lg(48);

  const IddsTextFieldSize(this.height);

  /// Tinggi di layar lebar (≥ 768px).
  final double height;
}

/// Kolom input teks IDDS dengan label, teks bantuan, status, ikon, tombol
/// hapus, dan penghitung karakter.
///
/// ```dart
/// IddsTextField(
///   label: const Text('Nama lengkap'),
///   required: true,
///   placeholder: 'Masukkan nama',
///   onChanged: (v) => _name = v,
/// )
/// ```
class IddsTextField extends StatefulWidget {
  /// Membuat kolom teks.
  const IddsTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.label,
    this.required = false,
    this.placeholder,
    this.helperText,
    this.status = IddsTextFieldStatus.neutral,
    this.statusMessage,
    this.size = IddsTextFieldSize.md,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.showCharCount = false,
    this.showClearButton = true,
    this.onClear,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.autofocus = false,
    this.clearLabel = 'Hapus input',
    this.minLines = 1,
    this.maxLines = 1,
  })  : assert(controller == null || initialValue == null, 'Pakai controller atau initialValue, bukan keduanya'),
        assert(maxLines == null || maxLines >= minLines);

  /// Controller teks. Bila `null`, controller internal dibuat.
  final TextEditingController? controller;

  /// Nilai awal bila tidak memakai [controller].
  final String? initialValue;

  /// Dipanggil setiap teks berubah (termasuk saat dihapus lewat tombol hapus).
  final ValueChanged<String>? onChanged;

  /// Dipanggil saat pengguna menekan tombol kirim di keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Label di atas kolom, biasanya [Text].
  final Widget? label;

  /// Tampilkan tanda wajib (*) setelah [label].
  final bool required;

  /// Teks contoh saat kolom kosong.
  final String? placeholder;

  /// Teks bantuan di bawah kolom.
  final String? helperText;

  /// Status visual.
  final IddsTextFieldStatus status;

  /// Pesan status. Menggantikan [helperText] bila diisi.
  final String? statusMessage;

  /// Ukuran.
  final IddsTextFieldSize size;

  /// Ikon di kiri teks.
  final Widget? prefixIcon;

  /// Ikon di kanan teks (setelah tombol hapus).
  final Widget? suffixIcon;

  /// Jumlah karakter maksimal.
  final int? maxLength;

  /// Tampilkan penghitung `n/maxLength`. Butuh [maxLength].
  final bool showCharCount;

  /// Tampilkan tombol hapus saat kolom berisi.
  final bool showClearButton;

  /// Dipanggil setelah tombol hapus ditekan.
  final VoidCallback? onClear;

  /// Apakah kolom bisa diisi.
  final bool enabled;

  /// Hanya baca.
  final bool readOnly;

  /// Sembunyikan teks (kata sandi).
  final bool obscureText;

  /// Jenis keyboard.
  final TextInputType? keyboardType;

  /// Tombol aksi keyboard.
  final TextInputAction? textInputAction;

  /// Formatter tambahan.
  final List<TextInputFormatter>? inputFormatters;

  /// Petunjuk autofill.
  final Iterable<String>? autofillHints;

  /// Focus node opsional.
  final FocusNode? focusNode;

  /// Langsung mendapat fokus.
  final bool autofocus;

  /// Label tombol hapus untuk pembaca layar.
  final String clearLabel;

  /// Jumlah baris minimal. Lebih dari 1 menjadikan kolom ini text area.
  final int minLines;

  /// Jumlah baris maksimal sebelum isi digulir. `null` = tumbuh tanpa batas.
  /// Selain 1, kolom menjadi text area (lihat juga [IddsTextArea]).
  final int? maxLines;

  bool get _multiline => minLines > 1 || maxLines != 1;

  @override
  State<IddsTextField> createState() => _IddsTextFieldState();
}

class _IddsTextFieldState extends State<IddsTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  bool _hovered = false;

  TextEditingController get _controller => widget.controller ?? _ownController!;
  FocusNode get _focusNode => widget.focusNode ?? _ownFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _ownController = TextEditingController(text: widget.initialValue);
    if (widget.focusNode == null) _ownFocusNode = FocusNode();
    _controller.addListener(_rebuild);
    _focusNode.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(IddsTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_rebuild);
      if (widget.controller == null) {
        _ownController ??= TextEditingController(text: oldWidget.controller?.text);
      } else {
        _ownController?.dispose();
        _ownController = null;
      }
      _controller.addListener(_rebuild);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocusNode)?.removeListener(_rebuild);
      if (widget.focusNode == null) {
        _ownFocusNode ??= FocusNode();
      } else {
        _ownFocusNode?.dispose();
        _ownFocusNode = null;
      }
      _focusNode.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _focusNode.removeListener(_rebuild);
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double width = iddsScreenWidth(context);
    final bool compactable = theme.compactOnSmallScreens;
    final bool small = compactable && width < IddsBreakpoint.sm;
    final bool medium = compactable && width < IddsBreakpoint.md;
    final double height = widget.size.height - (small ? 8 : medium ? 4 : 0);
    final double fontSize = small ? IddsFontSize.xs : IddsFontSize.sm;
    final double lineHeight = small ? IddsLineHeight.xs : IddsLineHeight.sm;

    final bool enabled = widget.enabled;
    final bool focused = _focusNode.hasFocus;
    final _StatusColors sc = _StatusColors.of(widget.status, c);
    final Color border = !enabled ? c.strokePrimary : (focused ? sc.focusBorder : sc.border);
    final Color background = !enabled
        ? c.backgroundTertiary
        : _hovered
            ? c.backgroundSecondary
            : c.backgroundPrimary;
    final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
    final String text = _controller.text;
    final bool showClear = widget.showClearButton && enabled && !widget.readOnly && text.isNotEmpty;

    // CSS text area: line-height 1.5.
    final TextStyle inputStyle = theme.textStyle(
      fontSize: fontSize,
      lineHeight: widget._multiline ? fontSize * 1.5 : lineHeight,
    );
    final Widget field = TextSelectionTheme(
      data: TextSelectionThemeData(
        cursorColor: c.contentPrimary,
        selectionColor: c.guide.shade200,
        selectionHandleColor: c.contentPrimary,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: enabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        minLines: widget._multiline ? widget.minLines : null,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType ?? (widget._multiline ? TextInputType.multiline : null),
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        inputFormatters: <TextInputFormatter>[
          ...?widget.inputFormatters,
          if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        style: inputStyle.copyWith(color: enabled ? c.contentPrimary : c.contentPrimary.withValues(alpha: 0.6)),
        cursorColor: c.contentPrimary,
        cursorHeight: widget._multiline ? null : lineHeight,
        textAlignVertical: widget._multiline ? TextAlignVertical.top : TextAlignVertical.center,
        decoration: InputDecoration.collapsed(
          hintText: widget.placeholder,
          hintStyle: inputStyle.copyWith(color: c.contentTertiary),
        ).copyWith(
          // Di web/desktop ThemeData memakai VisualDensity.compact (-8px).
          // Pada dekorasi collapsed, koreksi itu menggeser baseline 4px ke
          // bawah saat textAlignVertical = center. Tinggi kolom sudah diatur
          // IDDS, jadi density dikunci ke standar.
          visualDensity: VisualDensity.standard,
        ),
      ),
    );

    final Widget box = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: enabled ? SystemMouseCursors.text : SystemMouseCursors.forbidden,
      // Area input teks hanya setinggi satu baris; klik di sisa kotak (padding,
      // atas/bawah, ikon) juga harus memfokuskan input. Klik tepat di teks
      // tetap ditangani TextField (penempatan kursor, seleksi).
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: enabled && !_focusNode.hasFocus ? _focusNode.requestFocus : null,
        child: IddsInsetRing(
        visible: enabled && focused,
        borderRadius: radius,
        inset: 1,
        // CSS: inset 0 0 0 2px background-primary, inset 0 0 0 3px <warna status>.
        rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, sc.ring)],
        child: AnimatedContainer(
          duration: IddsDuration.base,
          curve: IddsCurves.standard,
          // Text area: tinggi mengikuti jumlah baris, padding 8px/12px.
          height: widget._multiline ? null : height,
          padding: widget._multiline
              ? const EdgeInsets.symmetric(horizontal: IddsSpacing.s12 - 1, vertical: IddsSpacing.s8 - 1)
              : const EdgeInsets.symmetric(horizontal: IddsSpacing.s12 - 1),
          decoration: BoxDecoration(
            color: background,
            borderRadius: radius,
            border: Border.all(color: border),
          ),
          child: IconTheme(
            data: IconThemeData(size: 20, color: c.contentSecondary),
            child: Row(
              spacing: IddsSpacing.s8,
              crossAxisAlignment: widget._multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.prefixIcon != null) widget.prefixIcon!,
                Expanded(child: field),
                if (showClear) _ClearButton(onPressed: _clear, label: widget.clearLabel),
                if (widget.suffixIcon != null) widget.suffixIcon!,
              ],
            ),
          ),
        ),
      ),
      ),
    );

    final String? message = widget.statusMessage ?? widget.helperText;
    final bool showCount = widget.showCharCount && widget.maxLength != null;
    final TextStyle smallStyle = theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs);
    final Widget? bottom = message == null && !showCount
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: IddsSpacing.s4),
            child: Flex(
              direction: small ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: small ? IddsSpacing.s4 : IddsSpacing.s24,
              children: <Widget>[
                if (message != null)
                  small
                      ? Text(message, style: smallStyle.copyWith(color: sc.message))
                      : Expanded(child: Text(message, style: smallStyle.copyWith(color: sc.message))),
                if (message == null && !small) const Spacer(),
                if (showCount)
                  Text(
                    '${text.length}/${widget.maxLength}',
                    style: smallStyle.copyWith(color: c.contentSecondary),
                  ),
              ],
            ),
          );

    final Widget result = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          DefaultTextStyle(
            style: theme.textStyle(
              fontSize: small ? IddsFontSize.xs : IddsFontSize.sm,
              lineHeight: small ? IddsLineHeight.xs : IddsLineHeight.sm,
              fontWeight: IddsFontWeight.medium,
            ),
            child: Row(
              children: <Widget>[
                Flexible(child: widget.label!),
                if (widget.required) ...<Widget>[
                  const SizedBox(width: IddsSpacing.s4),
                  Text('*', style: TextStyle(color: c.negative.shade500)),
                ],
              ],
            ),
          ),
          const SizedBox(height: IddsSpacing.s8),
        ],
        box,
        if (bottom != null) bottom,
      ],
    );

    // TextField butuh ancestor Material dan MaterialLocalizations.
    return iddsMaterialShim(context, result);
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onPressed,
        builder: (BuildContext context, IddsInteractionState state) => Container(
          padding: const EdgeInsets.all(2),
          decoration: state.focused
              ? BoxDecoration(
                  color: c.backgroundSecondary,
                  border: Border.all(color: c.strokeSecondary, width: 2),
                  borderRadius: BorderRadius.circular(IddsRadius.sm),
                )
              : null,
          child: IddsIcon(
            IddsIcons.x,
            size: 16,
            color: state.focused ? c.contentPrimary : c.contentSecondary,
          ),
        ),
      ),
    );
  }
}

class _StatusColors {
  const _StatusColors(this.border, this.focusBorder, this.ring, this.message);

  factory _StatusColors.of(IddsTextFieldStatus status, IddsColors c) {
    return switch (status) {
      IddsTextFieldStatus.neutral =>
        _StatusColors(c.strokePrimary, c.strokeTertiary, c.contentPrimary, c.contentSecondary),
      IddsTextFieldStatus.error =>
        _StatusColors(c.negative.shade500, c.negative.shade600, c.negative.shade500, c.negative.shade500),
      // Pesan memakai warning-600: CSS memakai warning-500 (kontras ±1,8:1
      // di atas putih).
      IddsTextFieldStatus.warning =>
        _StatusColors(c.warning.shade500, c.warning.shade600, c.warning.shade500, c.warning.shade600),
      IddsTextFieldStatus.success =>
        _StatusColors(c.positive.shade600, c.positive.shade600, c.positive.shade500, c.positive.shade600),
    };
  }

  final Color border;
  final Color focusBorder;
  final Color ring;
  final Color message;
}
