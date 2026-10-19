import 'package:flutter/services.dart'
    show AutofillHints, FilteringTextInputFormatter, LengthLimitingTextInputFormatter, SystemMouseCursors, TextInputFormatter, TextInputType, TextSelection;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Kolom kode sekali pakai (OTP) dengan satu kotak per karakter (One Time
/// Password IDDS).
///
/// Mendukung ketik, hapus (Backspace), tempel kode utuh, dan autofill kode
/// SMS di Android/iOS.
///
/// ```dart
/// IddsOtpInput(
///   length: 6,
///   title: 'Verifikasi nomor',
///   description: 'Masukkan 6 digit kode yang dikirim ke 0812****7890.',
///   value: _code,
///   onChanged: (v) => setState(() => _code = v),
///   onCompleted: _verify,
/// )
/// ```
class IddsOtpInput extends StatefulWidget {
  /// Membuat kolom OTP.
  const IddsOtpInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.length = 6,
    this.onCompleted,
    this.title,
    this.description,
    this.helperText,
    this.error = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.numeric = true,
    this.obscure = false,
    this.focusNode,
    this.semanticLabel = 'Kode verifikasi',
  }) : assert(length >= 3 && length <= 8);

  /// Kode saat ini.
  final String value;

  /// Dipanggil dengan kode baru.
  final ValueChanged<String>? onChanged;

  /// Jumlah karakter (3–8).
  final int length;

  /// Dipanggil saat semua kotak terisi.
  final ValueChanged<String>? onCompleted;

  /// Judul di atas kotak.
  final String? title;

  /// Keterangan di bawah judul.
  final String? description;

  /// Teks di bawah kotak (merah bila [error]).
  final String? helperText;

  /// Status error.
  final bool error;

  /// Apakah kolom aktif.
  final bool enabled;

  /// Hanya-baca.
  final bool readOnly;

  /// Langsung fokus.
  final bool autofocus;

  /// Hanya angka (bawaan). Bila `false`, huruf dan angka diterima.
  final bool numeric;

  /// Sembunyikan karakter dengan titik.
  final bool obscure;

  /// Focus node opsional.
  final FocusNode? focusNode;

  /// Label pembaca layar.
  final String semanticLabel;

  @override
  State<IddsOtpInput> createState() => _IddsOtpInputState();
}

class _IddsOtpInputState extends State<IddsOtpInput> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  FocusNode? _ownFocus;

  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode(debugLabel: 'IddsOtpInput'));

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(IddsOtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_rebuild);
      _focus.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_rebuild);
    _controller.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _changed(String value) {
    // Kursor selalu di akhir: kotak diisi berurutan.
    if (_controller.selection.baseOffset != value.length) {
      _controller.selection = TextSelection.collapsed(offset: value.length);
    }
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool small = iddsScreenWidth(context) <= 640;
    final double box = small ? 40 : 44;
    final bool interactive = widget.enabled && !widget.readOnly;
    final String text = _controller.text;
    final bool focused = _focus.hasFocus && interactive;
    final int active = text.length.clamp(0, widget.length - 1);

    final TextStyle digitStyle = theme.textStyle(
      fontSize: small ? 20 : 24,
      lineHeight: small ? 28 : 32,
      fontWeight: IddsFontWeight.medium,
      color: widget.enabled ? c.contentPrimary : c.contentTertiary,
    );

    // EditableText tak terlihat yang menerima ketikan, tempel, dan autofill;
    // kotak-kotak hanya menampilkan isinya.
    final Widget hiddenInput = Opacity(
      opacity: 0,
      child: EditableText(
        controller: _controller,
        focusNode: _focus,
        autofocus: widget.autofocus,
        readOnly: !interactive,
        style: digitStyle,
        cursorColor: const Color(0x00000000),
        backgroundCursorColor: const Color(0x00000000),
        showCursor: false,
        enableInteractiveSelection: false,
        keyboardType: widget.numeric ? TextInputType.number : TextInputType.text,
        autofillHints: const <String>[AutofillHints.oneTimeCode],
        autocorrect: false,
        enableSuggestions: false,
        inputFormatters: <TextInputFormatter>[
          if (widget.numeric)
            FilteringTextInputFormatter.digitsOnly
          else
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          LengthLimitingTextInputFormatter(widget.length),
        ],
        onChanged: _changed,
      ),
    );

    Widget cell(int i) {
      final bool isActive = focused && i == active;
      final bool filled = i < text.length;
      final Color border = widget.error
          ? c.negative.shade500
          : isActive
              ? c.contentPrimary
              : c.strokePrimary;
      final Color background = !widget.enabled || widget.readOnly ? c.backgroundTertiary : c.backgroundPrimary;
      final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
      return IddsInsetRing(
        visible: isActive,
        borderRadius: radius,
        inset: 1,
        rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, widget.error ? c.negative.shade500 : c.contentPrimary)],
        child: AnimatedContainer(
          duration: IddsDuration.fast,
          width: box,
          height: box,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: background, borderRadius: radius, border: Border.all(color: border)),
          child: filled
              ? Text(widget.obscure ? '•' : text[i], style: digitStyle)
              : (isActive
                  // Kursor berkedip sederhana di kotak aktif.
                  ? Container(width: 1.5, height: small ? 20 : 24, color: c.contentPrimary)
                  : null),
        ),
      );
    }

    final Widget boxes = Opacity(
      opacity: widget.enabled ? 1 : 0.6,
      child: Wrap(
        spacing: IddsSpacing.s12,
        runSpacing: IddsSpacing.s12,
        children: <Widget>[for (int i = 0; i < widget.length; i++) cell(i)],
      ),
    );

    // Kolom isian untuk pembaca layar disediakan oleh EditableText di bawah.
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: IddsSpacing.s16),
              child: Text(
                widget.title!,
                style: theme.textStyle(
                  fontSize: IddsFontSize.xl,
                  lineHeight: IddsLineHeight.lg,
                  fontWeight: IddsFontWeight.semibold,
                  color: c.contentPrimary,
                ),
              ),
            ),
          if (widget.description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: IddsSpacing.s16),
              child: Text(
                widget.description!,
                style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentSecondary),
              ),
            ),
          MouseRegion(
            cursor: interactive ? SystemMouseCursors.text : SystemMouseCursors.basic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: interactive ? _focus.requestFocus : null,
              child: Stack(
                children: <Widget>[
                  ExcludeSemantics(child: boxes),
                  Positioned.fill(child: IgnorePointer(child: hiddenInput)),
                ],
              ),
            ),
          ),
          if (widget.helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: IddsSpacing.s16),
              child: Text(
                widget.helperText!,
                style: theme.textStyle(
                  fontSize: IddsFontSize.sm,
                  lineHeight: IddsLineHeight.sm,
                  color: widget.error ? c.negative.shade500 : c.contentPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
