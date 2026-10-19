import 'dart:async';

import 'package:flutter/services.dart' show AutofillHints, TextInputAction, TextInputFormatter;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../loading/idds_loading.dart';
import 'idds_text_field.dart';

/// Kolom teks beberapa baris (Text Area IDDS). Tingginya tumbuh dari
/// [minLines] sampai [maxLines], lalu isinya digulir.
///
/// ```dart
/// IddsTextArea(
///   label: const Text('Alamat'),
///   maxLength: 200,
///   showCharCount: true,
///   onChanged: (v) => _address = v,
/// )
/// ```
class IddsTextArea extends StatelessWidget {
  /// Membuat text area.
  const IddsTextArea({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.required = false,
    this.placeholder,
    this.helperText,
    this.status = IddsTextFieldStatus.neutral,
    this.statusMessage,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.showCharCount = false,
    this.showClearButton = false,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
  });

  /// Lihat [IddsTextField.controller].
  final TextEditingController? controller;

  /// Lihat [IddsTextField.initialValue].
  final String? initialValue;

  /// Lihat [IddsTextField.onChanged].
  final ValueChanged<String>? onChanged;

  /// Lihat [IddsTextField.label].
  final Widget? label;

  /// Lihat [IddsTextField.required].
  final bool required;

  /// Lihat [IddsTextField.placeholder].
  final String? placeholder;

  /// Lihat [IddsTextField.helperText].
  final String? helperText;

  /// Lihat [IddsTextField.status].
  final IddsTextFieldStatus status;

  /// Lihat [IddsTextField.statusMessage].
  final String? statusMessage;

  /// Jumlah baris minimal.
  final int minLines;

  /// Jumlah baris maksimal sebelum digulir; `null` = tanpa batas.
  final int? maxLines;

  /// Lihat [IddsTextField.maxLength].
  final int? maxLength;

  /// Lihat [IddsTextField.showCharCount].
  final bool showCharCount;

  /// Lihat [IddsTextField.showClearButton].
  final bool showClearButton;

  /// Lihat [IddsTextField.enabled].
  final bool enabled;

  /// Lihat [IddsTextField.readOnly].
  final bool readOnly;

  /// Lihat [IddsTextField.inputFormatters].
  final List<TextInputFormatter>? inputFormatters;

  /// Lihat [IddsTextField.focusNode].
  final FocusNode? focusNode;

  /// Lihat [IddsTextField.autofocus].
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return IddsTextField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      label: label,
      required: required,
      placeholder: placeholder,
      helperText: helperText,
      status: status,
      statusMessage: statusMessage,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      showCharCount: showCharCount,
      showClearButton: showClearButton,
      enabled: enabled,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: TextInputAction.newline,
    );
  }
}

/// Kolom kata sandi dengan tombol tampilkan/sembunyikan (Password Input
/// IDDS).
class IddsPasswordField extends StatefulWidget {
  /// Membuat kolom kata sandi.
  const IddsPasswordField({
    super.key,
    this.controller,
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
    this.maxLength,
    this.showCharCount = false,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.autofillHints = const <String>[AutofillHints.password],
    this.showLabel = 'Tampilkan kata sandi',
    this.hideLabel = 'Sembunyikan kata sandi',
  });

  /// Lihat [IddsTextField.controller].
  final TextEditingController? controller;

  /// Lihat [IddsTextField.onChanged].
  final ValueChanged<String>? onChanged;

  /// Lihat [IddsTextField.onSubmitted].
  final ValueChanged<String>? onSubmitted;

  /// Lihat [IddsTextField.label].
  final Widget? label;

  /// Lihat [IddsTextField.required].
  final bool required;

  /// Lihat [IddsTextField.placeholder].
  final String? placeholder;

  /// Lihat [IddsTextField.helperText].
  final String? helperText;

  /// Lihat [IddsTextField.status].
  final IddsTextFieldStatus status;

  /// Lihat [IddsTextField.statusMessage].
  final String? statusMessage;

  /// Lihat [IddsTextField.size].
  final IddsTextFieldSize size;

  /// Lihat [IddsTextField.prefixIcon].
  final Widget? prefixIcon;

  /// Lihat [IddsTextField.maxLength].
  final int? maxLength;

  /// Lihat [IddsTextField.showCharCount].
  final bool showCharCount;

  /// Lihat [IddsTextField.enabled].
  final bool enabled;

  /// Lihat [IddsTextField.focusNode].
  final FocusNode? focusNode;

  /// Lihat [IddsTextField.autofocus].
  final bool autofocus;

  /// Petunjuk autofill. Bawaan: kata sandi. Untuk kata sandi baru pakai
  /// `[AutofillHints.newPassword]`.
  final Iterable<String>? autofillHints;

  /// Label pembaca layar tombol tampilkan.
  final String showLabel;

  /// Label pembaca layar tombol sembunyikan.
  final String hideLabel;

  @override
  State<IddsPasswordField> createState() => _IddsPasswordFieldState();
}

class _IddsPasswordFieldState extends State<IddsPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final String label = _visible ? widget.hideLabel : widget.showLabel;
    final VoidCallback? toggle = widget.enabled ? () => setState(() => _visible = !_visible) : null;
    return IddsTextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      label: widget.label,
      required: widget.required,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      status: widget.status,
      statusMessage: widget.statusMessage,
      size: widget.size,
      prefixIcon: widget.prefixIcon,
      maxLength: widget.maxLength,
      showCharCount: widget.showCharCount,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      autofillHints: widget.autofillHints,
      obscureText: !_visible,
      showClearButton: false,
      suffixIcon: Semantics(
        button: true,
        label: label,
        onTap: toggle,
        excludeSemantics: true,
        child: IddsInteractive(
          onTap: toggle,
          builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
            visible: state.focused,
            borderRadius: BorderRadius.circular(IddsRadius.sm),
            rings: <(double, Color)>[(2.0, c.contentPrimary)],
            child: IddsIcon(
              _visible ? IddsIcons.eyeOff : IddsIcons.eye,
              size: 20,
              color: state.hovered ? c.contentPrimary : c.contentSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kolom pencarian dengan ikon kaca pembesar dan jeda ketik (Input Search
/// IDDS).
///
/// [onSearch] dipanggil [debounce] setelah pengguna berhenti mengetik, dan
/// langsung saat Enter ditekan atau isi dihapus.
class IddsSearchField extends StatefulWidget {
  /// Membuat kolom pencarian.
  const IddsSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSearch,
    this.debounce = const Duration(milliseconds: 300),
    this.label,
    this.required = false,
    this.placeholder = 'Cari...',
    this.size = IddsTextFieldSize.md,
    this.loading = false,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
  });

  /// Lihat [IddsTextField.controller].
  final TextEditingController? controller;

  /// Dipanggil setiap isi berubah (tanpa jeda).
  final ValueChanged<String>? onChanged;

  /// Dipanggil setelah jeda ketik, Enter, atau saat isi dihapus.
  final ValueChanged<String>? onSearch;

  /// Lama jeda sebelum [onSearch]. [Duration.zero] = langsung.
  final Duration debounce;

  /// Label di atas kolom.
  final Widget? label;

  /// Tampilkan tanda wajib (*).
  final bool required;

  /// Placeholder.
  final String placeholder;

  /// Ukuran.
  final IddsTextFieldSize size;

  /// Tampilkan spinner kecil, misalnya saat hasil sedang dimuat.
  final bool loading;

  /// Lihat [IddsTextField.enabled].
  final bool enabled;

  /// Lihat [IddsTextField.focusNode].
  final FocusNode? focusNode;

  /// Lihat [IddsTextField.autofocus].
  final bool autofocus;

  @override
  State<IddsSearchField> createState() => _IddsSearchFieldState();
}

class _IddsSearchFieldState extends State<IddsSearchField> {
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _changed(String value) {
    widget.onChanged?.call(value);
    _timer?.cancel();
    if (widget.onSearch == null) return;
    if (value.isEmpty || widget.debounce == Duration.zero) {
      widget.onSearch!(value);
    } else {
      _timer = Timer(widget.debounce, () => widget.onSearch!(value));
    }
  }

  void _submit(String value) {
    _timer?.cancel();
    widget.onSearch?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return IddsTextField(
      controller: widget.controller,
      onChanged: _changed,
      onSubmitted: _submit,
      label: widget.label,
      required: widget.required,
      placeholder: widget.placeholder,
      size: widget.size,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      prefixIcon: IddsIcon(IddsIcons.search, size: 20, color: c.contentSecondary),
      suffixIcon: widget.loading ? const IddsSpinner(size: 16, strokeWidth: 2, semanticLabel: 'Mencari') : null,
    );
  }
}
