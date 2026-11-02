import 'dart:math' as math;

import 'package:flutter/services.dart'
    show AutofillHints, Clipboard, ClipboardData, FilteringTextInputFormatter, LengthLimitingTextInputFormatter, SystemMouseCursors, TextInputFormatter, TextInputType, TextSelection;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_popover.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Kolom kode sekali pakai (OTP) dengan satu kotak per karakter (One Time
/// Password IDDS).
///
/// Mendukung ketik, hapus (Backspace), tempel kode utuh (Ctrl/Cmd+V, saran
/// papan klip keyboard, atau **tekan lama → [pasteLabel]** di layar sentuh),
/// dan autofill kode SMS di Android/iOS.
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
    this.pasteLabel = 'Tempel',
  }) : assert(length >= 3 && length <= 8);

  /// Mengambil kode dari teks bebas (isi papan klip, mis. "Kode Anda 123 456,
  /// berlaku 5 menit"). Urutan: deretan tepat [length] karakter yang berdiri
  /// sendiri, lalu deretan yang sama setelah spasi/tanda hubung di antara
  /// angka dibuang, lalu
  /// karakter yang diizinkan dari awal teks. Hasil kosong bila tidak ada.
  static String codeFromText(String text, {int length = 6, bool numeric = true}) {
    final String unit = numeric ? r'\d' : '[A-Za-z0-9]';
    final RegExp exact = RegExp('(?<![A-Za-z0-9])$unit{$length}(?![A-Za-z0-9])');
    final RegExpMatch? direct = exact.firstMatch(text);
    if (direct != null) return direct.group(0)!;
    // "123 456" / "123-456": pemisah di antara angka saja yang dibuang.
    final RegExpMatch? joined = exact.firstMatch(text.replaceAll(RegExp(r'(?<=\d)[\s-]+(?=\d)'), ''));
    if (joined != null) return joined.group(0)!;
    final String allowed = text.replaceAll(RegExp(numeric ? r'\D' : '[^A-Za-z0-9]'), '');
    return allowed.length > length ? allowed.substring(0, length) : allowed;
  }

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

  /// Label menu tempel yang muncul saat kotak ditekan lama.
  final String pasteLabel;

  @override
  State<IddsOtpInput> createState() => _IddsOtpInputState();
}

class _IddsOtpInputState extends State<IddsOtpInput> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  FocusNode? _ownFocus;

  /// Menu "Tempel" (tekan lama). Kolom tersembunyi tidak punya menu konteks
  /// sendiri karena ditutup kotak-kotak dan tidak menerima sentuhan.
  bool _pasteMenu = false;

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

  /// Isi kotak dari papan klip; teks tanpa kode diabaikan.
  Future<void> _paste() async {
    setState(() => _pasteMenu = false);
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String code = IddsOtpInput.codeFromText(data?.text ?? '', length: widget.length, numeric: widget.numeric);
    if (!mounted || code.isEmpty) return;
    _controller.value = TextEditingValue(text: code, selection: TextSelection.collapsed(offset: code.length));
    _focus.requestFocus();
    _changed(code);
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

    Widget cell(int i, double size) {
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
          width: size,
          height: size,
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
      // Selalu satu baris: kotak menyusut mengikuti lebar induk. Dulu `Wrap`
      // dengan kotak 40 + jarak 12 (300px untuk 6 kotak) membuat kotak
      // terakhir turun ke baris kedua di kartu HP 320px.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double gap = small ? IddsSpacing.s8 : IddsSpacing.s12;
          final double fit = constraints.hasBoundedWidth
              ? (constraints.maxWidth - gap * (widget.length - 1)) / widget.length
              : box;
          final double size = math.max(0, math.min(box, fit));
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < widget.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: gap),
                cell(i, size),
              ],
            ],
          );
        },
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
            child: IddsPopover(
              open: _pasteMenu,
              onDismiss: () => setState(() => _pasteMenu = false),
              placement: IddsPopoverPlacement.topStart,
              matchAnchorWidth: false,
              panelBuilder: (BuildContext context) => IddsPopoverSurface(
                padding: EdgeInsets.zero,
                child: Semantics(
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _paste,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48, minWidth: 96),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s16),
                        // widthFactor/heightFactor 1: menu setinggi isinya.
                        // Tanpa heightFactor, Center memakai seluruh tinggi
                        // yang tersedia (panel memanjang ke atas layar).
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Text(
                            widget.pasteLabel,
                            style: theme.textStyle(
                              fontSize: IddsFontSize.sm,
                              lineHeight: IddsLineHeight.sm,
                              fontWeight: IddsFontWeight.medium,
                              color: c.contentPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: interactive ? _focus.requestFocus : null,
                onLongPress: interactive ? () => setState(() => _pasteMenu = true) : null,
                child: Stack(
                  children: <Widget>[
                    ExcludeSemantics(child: boxes),
                    Positioned.fill(child: IgnorePointer(child: hiddenInput)),
                  ],
                ),
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
