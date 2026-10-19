import 'package:flutter/material.dart' show InputDecoration, TextField, VisualDensity;
import 'package:flutter/services.dart'
    show AutofillHints, KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey, SystemMouseCursors, TextEditingValue, TextInputFormatter, TextInputType, TextSelection;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_material_shim.dart';
import '../../foundation/idds_popover.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../text_field/idds_text_field.dart';

part 'idds_countries.g.dart';

/// Satu negara untuk [IddsPhoneInput].
@immutable
class IddsCountry {
  /// Membuat data negara.
  const IddsCountry({required this.code, required this.name, required this.dialCode});

  /// Kode ISO 3166-1 alpha-2, misalnya `ID`.
  final String code;

  /// Nama negara.
  final String name;

  /// Kode telepon, misalnya `+62`.
  final String dialCode;

  /// Bendera emoji dari [code] (tampil sebagai huruf bila platform tidak
  /// punya font emoji bendera).
  String get flag => String.fromCharCodes(code.toUpperCase().codeUnits.map((int u) => 0x1F1E6 + u - 65));

  /// Semua negara (239), Indonesia di urutan pertama.
  static const List<IddsCountry> all = _iddsCountries;

  @override
  bool operator ==(Object other) => other is IddsCountry && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// Kolom nomor telepon dengan pilihan kode negara (Phone Input IDDS).
///
/// Nilai yang dikirim ke [onChanged] berformat `+62812...`: kode negara
/// diikuti angka tanpa nol di depan. Di kolom, angka ditampilkan berkelompok
/// `812-3456-7890`.
class IddsPhoneInput extends StatefulWidget {
  /// Membuat kolom telepon.
  const IddsPhoneInput({
    super.key,
    this.value,
    this.onChanged,
    this.label,
    this.required = false,
    this.placeholder = '812-3456-7890',
    this.helperText,
    this.status = IddsTextFieldStatus.neutral,
    this.statusMessage,
    this.size = IddsTextFieldSize.md,
    this.enabled = true,
    this.readOnly = false,
    this.defaultCountry = 'ID',
    this.countries = IddsCountry.all,
    this.searchPlaceholder = 'Cari negara',
    this.emptyText = 'Negara tidak ditemukan',
  });

  /// Nomor lengkap, misalnya `+6281234567890`.
  final String? value;

  /// Dipanggil dengan nomor lengkap baru.
  final ValueChanged<String>? onChanged;

  /// Label di atas kolom.
  final Widget? label;

  /// Tampilkan tanda wajib (*).
  final bool required;

  /// Placeholder nomor.
  final String placeholder;

  /// Teks bantuan.
  final String? helperText;

  /// Status.
  final IddsTextFieldStatus status;

  /// Pesan status.
  final String? statusMessage;

  /// Ukuran.
  final IddsTextFieldSize size;

  /// Apakah kolom aktif.
  final bool enabled;

  /// Hanya-baca.
  final bool readOnly;

  /// Kode negara awal (ISO), misalnya `ID`.
  final String defaultCountry;

  /// Negara yang bisa dipilih.
  final List<IddsCountry> countries;

  /// Placeholder pencarian negara.
  final String searchPlaceholder;

  /// Teks saat pencarian negara tidak menemukan hasil.
  final String emptyText;

  @override
  State<IddsPhoneInput> createState() => _IddsPhoneInputState();
}

class _IddsPhoneInputState extends State<IddsPhoneInput> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final FocusNode _focus = FocusNode();
  final FocusNode _searchFocus = FocusNode();
  late IddsCountry _country;
  bool _open = false;
  String _query = '';
  String? _lastEmitted;

  @override
  void initState() {
    super.initState();
    _country = widget.countries.firstWhere(
      (IddsCountry c) => c.code == widget.defaultCountry,
      orElse: () => widget.countries.first,
    );
    _syncFromValue();
  }

  @override
  void didUpdateWidget(IddsPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _lastEmitted) _syncFromValue();
  }

  @override
  void dispose() {
    _controller.dispose();
    _search.dispose();
    _focus.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Memisahkan kode negara dari [IddsPhoneInput.value].
  void _syncFromValue() {
    final String value = widget.value ?? '';
    if (value.isEmpty) {
      _controller.text = '';
      return;
    }
    // Cocokkan kode negara terpanjang lebih dulu (+1684 sebelum +1).
    final List<IddsCountry> byLength = <IddsCountry>[...widget.countries]
      ..sort((IddsCountry a, IddsCountry b) => b.dialCode.length.compareTo(a.dialCode.length));
    String digits = value;
    if (!value.startsWith(_country.dialCode)) {
      for (final IddsCountry c in byLength) {
        if (value.startsWith(c.dialCode)) {
          _country = c;
          break;
        }
      }
    }
    if (digits.startsWith(_country.dialCode)) digits = digits.substring(_country.dialCode.length);
    _controller.text = iddsFormatPhoneDigits(digits.replaceAll(RegExp(r'\D'), ''));
  }

  void _emit() {
    String digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    final String full = digits.isEmpty ? '' : '${_country.dialCode}$digits';
    _lastEmitted = full;
    widget.onChanged?.call(full);
  }

  bool get _interactive => widget.enabled && !widget.readOnly;

  void _toggle() {
    if (!_interactive) return;
    setState(() {
      _open = !_open;
      _query = '';
      _search.clear();
    });
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
  }

  void _select(IddsCountry country) {
    setState(() {
      _country = country;
      _open = false;
    });
    if (_controller.text.isNotEmpty) _emit();
    _focus.requestFocus();
  }

  List<IddsCountry> get _filtered {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.countries;
    return <IddsCountry>[
      for (final IddsCountry c in widget.countries)
        if (c.name.toLowerCase().contains(q) || c.dialCode.contains(q) || c.code.toLowerCase().contains(q)) c,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool small = iddsIsCompact(context, IddsBreakpoint.sm);
    final TextStyle textStyle = theme.textStyle(
      fontSize: small ? IddsFontSize.xs : IddsFontSize.sm,
      lineHeight: small ? IddsLineHeight.xs : IddsLineHeight.sm,
      color: _interactive ? c.contentPrimary : c.contentTertiary,
    );

    final Widget countryButton = Semantics(
      button: true,
      label: 'Kode negara ${_country.name} ${_country.dialCode}',
      onTap: _interactive ? _toggle : null,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: _interactive ? _toggle : null,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(IddsRadius.sm),
          rings: <(double, Color)>[(2.0, c.contentPrimary)],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: IddsSpacing.s8,
            children: <Widget>[
              Text(_country.flag, style: textStyle.copyWith(fontSize: 16)),
              Text(
                _country.dialCode,
                style: theme.textStyle(
                  fontSize: small ? IddsFontSize.xs : IddsFontSize.sm,
                  lineHeight: small ? IddsLineHeight.xs : IddsLineHeight.sm,
                  fontWeight: IddsFontWeight.medium,
                  color: _interactive ? c.contentPrimary : c.contentTertiary,
                ),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: IddsDuration.base,
                child: IddsIcon(IddsIcons.chevronDown, size: 16, color: c.contentSecondary),
              ),
              Container(width: 1, height: 20, color: c.strokePrimary),
            ],
          ),
        ),
      ),
    );

    final Widget field = IddsTextField(
      controller: _controller,
      focusNode: _focus,
      label: widget.label,
      required: widget.required,
      placeholder: widget.placeholder,
      helperText: widget.helperText,
      status: widget.status,
      statusMessage: widget.statusMessage,
      size: widget.size,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      keyboardType: TextInputType.phone,
      autofillHints: const <String>[AutofillHints.telephoneNumberNational],
      inputFormatters: const <TextInputFormatter>[_PhoneFormatter()],
      prefixIcon: countryButton,
      onChanged: (_) => _emit(),
    );

    return IddsPopover(
      open: _open,
      onDismiss: _close,
      maxHeight: 320,
      // Lebar tetap: daftar negara memakai ListView (tidak bisa diukur
      // lebarnya otomatis).
      width: 320,
      matchAnchorWidth: false,
      panelBuilder: (BuildContext context) => _buildPanel(context, textStyle),
      child: field,
    );
  }

  Widget _buildPanel(BuildContext context, TextStyle textStyle) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final List<IddsCountry> countries = _filtered;
    final TextStyle small = theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentPrimary);

    KeyEventResult onKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
      if (event.logicalKey == LogicalKeyboardKey.enter && countries.isNotEmpty) {
        _select(countries.first);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return _AutofocusOnMount(
      node: _searchFocus,
      child: IddsPopoverSurface(
        child: Padding(
          padding: const EdgeInsets.all(IddsSpacing.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s8 - 1, vertical: IddsSpacing.s4 - 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(IddsRadius.md),
                  border: Border.all(color: _searchFocus.hasFocus ? c.contentPrimary : c.strokePrimary),
                ),
                child: Focus(
                  onKeyEvent: onKey,
                  child: iddsMaterialShim(
                    context,
                    TextField(
                      controller: _search,
                      focusNode: _searchFocus,
                      style: small,
                      cursorColor: c.contentPrimary,
                      onChanged: (String v) => setState(() => _query = v),
                      onTapOutside: (_) {},
                      decoration: InputDecoration.collapsed(
                        hintText: widget.searchPlaceholder,
                        hintStyle: small.copyWith(color: c.contentTertiary),
                      ).copyWith(visualDensity: VisualDensity.standard),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: IddsSpacing.s8),
              Flexible(
                child: countries.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(IddsSpacing.s12),
                        child: Text(widget.emptyText, textAlign: TextAlign.center, style: small.copyWith(color: c.contentSecondary)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: countries.length,
                        itemExtent: 36,
                        itemBuilder: (BuildContext context, int i) {
                          final IddsCountry country = countries[i];
                          final bool selected = country == _country;
                          return Semantics(
                            button: true,
                            selected: selected,
                            label: '${country.name} ${country.dialCode}',
                            onTap: () => _select(country),
                            excludeSemantics: true,
                            child: _HoverRow(
                              selected: selected,
                              onTap: () => _select(country),
                              child: Row(
                                spacing: IddsSpacing.s8,
                                children: <Widget>[
                                  Text(country.flag, style: textStyle.copyWith(fontSize: 16, color: c.contentPrimary)),
                                  Expanded(
                                    child: Text(
                                      country.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyle.copyWith(color: c.contentPrimary),
                                    ),
                                  ),
                                  Text(country.dialCode, style: textStyle.copyWith(color: c.contentSecondary)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mengelompokkan angka telepon seperti versi web: `812`, `812-3456`,
/// `812-3456-7890`.
String iddsFormatPhoneDigits(String digits) {
  if (digits.length > 7) return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
  if (digits.length > 3) return '${digits.substring(0, 3)}-${digits.substring(3)}';
  return digits;
}

class _PhoneFormatter extends TextInputFormatter {
  const _PhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final String text = iddsFormatPhoneDigits(digits.length > 15 ? digits.substring(0, 15) : digits);
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.selected, required this.onTap, required this.child});

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12),
          decoration: BoxDecoration(
            color: widget.selected || _hovered ? c.backgroundSecondary : null,
            borderRadius: BorderRadius.circular(IddsRadius.base),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _AutofocusOnMount extends StatefulWidget {
  const _AutofocusOnMount({required this.node, required this.child});

  final FocusNode node;
  final Widget child;

  @override
  State<_AutofocusOnMount> createState() => _AutofocusOnMountState();
}

class _AutofocusOnMountState extends State<_AutofocusOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.node.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
