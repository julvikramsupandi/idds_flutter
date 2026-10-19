import 'dart:math' as math;

import 'package:flutter/services.dart' show FilteringTextInputFormatter, TextInputAction, TextInputFormatter, TextInputType;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_color_utils.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_primitives.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../text_field/idds_text_field.dart';

/// Ukuran [IddsChip].
enum IddsChipSize {
  /// Tinggi 24px, font 12px.
  small,

  /// Tinggi 32px, font 14px (bawaan).
  medium,
}

/// Gaya [IddsChip].
enum IddsChipVariant {
  /// Bergaris tepi (bawaan).
  outline,

  /// Berlatar warna brand muda.
  filled,
}

/// Satu chip yang bisa dipilih.
///
/// Untuk daftar pilihan, pakai [IddsChipGroup].
class IddsChip extends StatelessWidget {
  /// Membuat chip.
  const IddsChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.size = IddsChipSize.medium,
    this.variant = IddsChipVariant.outline,
    this.focusNode,
  });

  /// Isi chip, biasanya [Text].
  final Widget label;

  /// Terpilih.
  final bool selected;

  /// Dipanggil saat ditekan. `null` membuat chip nonaktif.
  final VoidCallback? onPressed;

  /// Ukuran.
  final IddsChipSize size;

  /// Gaya.
  final IddsChipVariant variant;

  /// Focus node opsional.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool small = size == IddsChipSize.small;
    final bool enabled = onPressed != null;
    // Latar primary-25/50/300 tidak berubah di dark mode, jadi teks di
    // atasnya memakai warna tetap (CSS: content-primary, putih di dark mode).
    final Color onLight = IddsPrimitives.neutral.shade800;

    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: enabled,
      onTap: onPressed,
      child: IddsInteractive(
        onTap: onPressed,
        focusNode: focusNode,
        builder: (BuildContext context, IddsInteractionState state) {
          final Color background;
          final Color foreground;
          Color border;
          if (!enabled) {
            background = c.backgroundTertiary;
            foreground = c.contentTertiary;
            border = variant == IddsChipVariant.filled ? c.backgroundTertiary : c.strokePrimary;
          } else if (variant == IddsChipVariant.filled) {
            if (selected) {
              background = c.primary.shade300;
              // CSS: teks putih; tidak terbaca di atas primary-300 brand terang
              // (mis. Neutral #D4D4D4). Dipilih putih/hitam berdasarkan kontras.
              foreground = IddsColorUtils.bestContrast(background, <Color>[c.baseWhite, onLight]);
              border = c.primary.shade300;
            } else {
              background = state.hovered || state.focused ? c.primary.shade50 : c.primary.shade25;
              foreground = onLight;
              border = c.primary.shade25;
            }
          } else {
            if (selected) {
              background = c.primary.shade25;
              foreground = c.primary.shade600;
              border = c.primary.shade600;
            } else {
              // CSS: neutral-25 (putih tetap). Dipakai background-primary agar
              // mengikuti dark mode.
              background = state.hovered || state.focused ? c.primary.shade25 : c.backgroundPrimary;
              foreground = state.hovered || state.focused ? onLight : c.contentPrimary;
              border = c.strokePrimary;
            }
          }
          double borderWidth = 1;
          if (state.focused && !selected) {
            border = c.primary.shade600;
            borderWidth = 2;
          }

          return AnimatedScale(
            duration: IddsDuration.fast,
            scale: state.pressed ? 0.98 : 1.0,
            child: AnimatedContainer(
              duration: IddsDuration.fast,
              curve: IddsCurves.standard,
              height: small ? 24 : 32,
              padding: EdgeInsets.symmetric(horizontal: (small ? 10 : 12) - borderWidth),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(IddsRadius.full),
                border: Border.all(color: border, width: borderWidth),
              ),
              // widthFactor: 1 agar chip selebar isinya (bukan memenuhi baris).
              child: Center(
                widthFactor: 1,
                child: DefaultTextStyle(
                style: theme.textStyle(
                  fontSize: small ? IddsFontSize.xs : IddsFontSize.sm,
                  lineHeight: small ? IddsLineHeight.xs : IddsLineHeight.sm,
                  fontWeight: IddsFontWeight.medium,
                  color: foreground,
                ),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: IconTheme(
                  data: IconThemeData(size: small ? 14 : 16, color: foreground),
                  child: label,
                ),
              ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Satu pilihan di [IddsChipGroup].
@immutable
class IddsChipOption<T> {
  /// Membuat pilihan.
  const IddsChipOption({required this.value, required this.label, this.enabled = true});

  /// Nilai pilihan.
  final T value;

  /// Teks pilihan.
  final String label;

  /// Apakah bisa dipilih.
  final bool enabled;
}

/// Pengaturan chip "Kustomisasi" di [IddsChipGroup]: chip tambahan yang
/// membuka kolom isian agar pengguna bisa memasukkan nilai sendiri.
///
/// Nilai kustom adalah nilai di [IddsChipGroup.selected] yang tidak ada di
/// [IddsChipGroup.options].
///
/// ```dart
/// customization: IddsChipCustomization<int>.integer(suffix: 'hari'),
/// ```
@immutable
class IddsChipCustomization<T> {
  /// Membuat pengaturan kustomisasi.
  const IddsChipCustomization({
    required this.parse,
    required this.format,
    this.label = 'Kustomisasi',
    this.placeholder = 'Masukkan data yang Anda inginkan',
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.showValueInLabel = true,
  });

  /// Isian teks bebas.
  static IddsChipCustomization<String> text({
    String label = 'Kustomisasi',
    String placeholder = 'Masukkan data yang Anda inginkan',
    bool showValueInLabel = true,
  }) {
    return IddsChipCustomization<String>(
      parse: (String text) => text,
      format: (String value) => value,
      label: label,
      placeholder: placeholder,
      showValueInLabel: showValueInLabel,
    );
  }

  /// Isian bilangan bulat positif, misalnya jumlah hari. [suffix] tampil di
  /// kanan kolom isian dan di label chip.
  static IddsChipCustomization<int> integer({
    String? suffix,
    String label = 'Kustomisasi',
    String placeholder = 'Masukkan angka',
    bool showValueInLabel = true,
  }) {
    return IddsChipCustomization<int>(
      parse: int.tryParse,
      format: (int value) => '$value',
      label: label,
      placeholder: placeholder,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      suffix: suffix,
      showValueInLabel: showValueInLabel,
    );
  }

  /// Mengubah isian menjadi nilai. Kembalikan `null` bila isian tidak valid;
  /// isian tersebut diabaikan.
  final T? Function(String text) parse;

  /// Mengubah nilai menjadi teks untuk kolom isian dan label chip.
  final String Function(T value) format;

  /// Teks chip.
  final String label;

  /// Placeholder kolom isian.
  final String placeholder;

  /// Jenis keyboard.
  final TextInputType? keyboardType;

  /// Pembatas isian.
  final List<TextInputFormatter>? inputFormatters;

  /// Satuan di kanan kolom isian, misalnya "hari".
  final String? suffix;

  /// Tampilkan nilai kustom di label chip ("Kustomisasi: 45 hari"). Versi
  /// web hanya menampilkan "Kustomisasi".
  final bool showValueInLabel;
}

/// Sekumpulan chip untuk memilih satu atau beberapa nilai.
///
/// ```dart
/// IddsChipGroup<String>(
///   options: const [
///     IddsChipOption(value: '7', label: '7 hari'),
///     IddsChipOption(value: '30', label: '30 hari'),
///   ],
///   selected: _range,
///   onChanged: (v) => setState(() => _range = v),
/// )
/// ```
///
/// Mode satu pilihan: menekan chip yang sudah terpilih akan membatalkannya,
/// sama seperti versi web.
///
/// Isi [customization] untuk menambahkan chip "Kustomisasi". Menekannya
/// membuka kolom isian di bawah chip; nilai disimpan saat Enter ditekan atau
/// kolom kehilangan fokus. Kolom kosong menghapus nilai kustom.
class IddsChipGroup<T> extends StatefulWidget {
  /// Membuat grup chip.
  const IddsChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.multiple = false,
    this.size = IddsChipSize.medium,
    this.variant = IddsChipVariant.outline,
    this.customization,
  });

  /// Pilihan yang tersedia.
  final List<IddsChipOption<T>> options;

  /// Nilai yang sedang terpilih.
  final Set<T> selected;

  /// Dipanggil dengan himpunan pilihan baru. `null` membuat grup nonaktif.
  final ValueChanged<Set<T>>? onChanged;

  /// Boleh memilih lebih dari satu.
  final bool multiple;

  /// Ukuran.
  final IddsChipSize size;

  /// Gaya.
  final IddsChipVariant variant;

  /// Chip "Kustomisasi" untuk nilai di luar [options].
  final IddsChipCustomization<T>? customization;

  @override
  State<IddsChipGroup<T>> createState() => _IddsChipGroupState<T>();
}

class _IddsChipGroupState<T> extends State<IddsChipGroup<T>> {
  bool _editing = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode(debugLabel: 'IddsChipGroup kustomisasi');

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) _commit();
    });
  }

  @override
  void didUpdateWidget(IddsChipGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_editing && (widget.customization == null || widget.onChanged == null)) _editing = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Nilai kustom terakhir (nilai terpilih yang tidak ada di opsi).
  T? get _custom {
    T? last;
    bool found = false;
    for (final T v in widget.selected) {
      if (!widget.options.any((IddsChipOption<T> o) => o.value == v)) {
        last = v;
        found = true;
      }
    }
    return found ? last : null;
  }

  bool get _hasCustom => widget.selected.any((T v) => !widget.options.any((IddsChipOption<T> o) => o.value == v));

  void _toggle(T value) {
    final Set<T> selected = widget.selected;
    final Set<T> next;
    if (selected.contains(value)) {
      next = <T>{...selected}..remove(value);
    } else {
      next = widget.multiple ? <T>{...selected, value} : <T>{value};
    }
    widget.onChanged!(next);
  }

  void _startEditing() {
    final IddsChipCustomization<T> custom = widget.customization!;
    final T? value = _custom;
    _controller.text = _hasCustom && value != null ? custom.format(value) : '';
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _editing) _focus.requestFocus();
    });
  }

  void _commit() {
    if (!_editing) return;
    setState(() => _editing = false);
    final ValueChanged<Set<T>>? onChanged = widget.onChanged;
    final IddsChipCustomization<T>? custom = widget.customization;
    if (onChanged == null || custom == null) return;

    final String text = _controller.text.trim();
    final T? parsed = text.isEmpty ? null : custom.parse(text);
    // Isian tidak valid: biarkan pilihan apa adanya.
    if (text.isNotEmpty && parsed == null) return;

    if (widget.multiple) {
      final Set<T> next = <T>{...widget.selected};
      if (_hasCustom) next.remove(_custom);
      if (parsed != null) next.add(parsed as T);
      onChanged(next);
    } else {
      onChanged(parsed == null ? <T>{} : <T>{parsed as T});
    }
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final bool compact = iddsIsCompact(context, IddsBreakpoint.sm);
    final IddsChipCustomization<T>? custom = widget.customization;
    final bool enabled = widget.onChanged != null;
    final bool hasCustom = custom != null && _hasCustom;

    String customLabel = custom?.label ?? '';
    final T? customValue = hasCustom ? _custom : null;
    if (custom != null && hasCustom && custom.showValueInLabel && customValue != null) {
      final String suffix = custom.suffix == null ? '' : ' ${custom.suffix}';
      customLabel = '${custom.label}: ${custom.format(customValue)}$suffix';
    }

    final Widget chips = Wrap(
      spacing: compact ? IddsSpacing.s4 : IddsSpacing.s8,
      runSpacing: compact ? IddsSpacing.s4 : IddsSpacing.s8,
      children: <Widget>[
        for (final IddsChipOption<T> option in widget.options)
          IddsChip(
            label: Text(option.label),
            selected: widget.selected.contains(option.value),
            onPressed: enabled && option.enabled ? () => _toggle(option.value) : null,
            size: widget.size,
            variant: widget.variant,
          ),
        if (custom != null)
          IddsChip(
            label: Text(customLabel),
            selected: hasCustom,
            onPressed: enabled ? _startEditing : null,
            size: widget.size,
            variant: widget.variant,
          ),
      ],
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: !_editing || custom == null
          ? chips
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                chips,
                const SizedBox(height: IddsSpacing.s8),
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // CSS: lebar 100% di layar < 640px, 50% hingga 767px,
                    // 25% di atasnya; ditambah lebar minimal 200px agar tetap
                    // bisa diisi di wadah sempit.
                    final double screen = iddsScreenWidth(context);
                    final double max = constraints.hasBoundedWidth ? constraints.maxWidth : 400;
                    final double fraction = screen < IddsBreakpoint.sm
                        ? 1
                        : screen < IddsBreakpoint.md
                            ? 0.5
                            : 0.25;
                    final double width = (max * fraction).clamp(math.min(200, max), max);
                    return SizedBox(
                      width: width,
                      child: IddsTextField(
                        controller: _controller,
                        focusNode: _focus,
                        size: IddsTextFieldSize.sm,
                        placeholder: custom.placeholder,
                        keyboardType: custom.keyboardType,
                        inputFormatters: custom.inputFormatters,
                        textInputAction: TextInputAction.done,
                        suffixIcon: custom.suffix == null
                            ? null
                            : Text(
                                custom.suffix!,
                                style: theme.textStyle(
                                  fontSize: IddsFontSize.sm,
                                  lineHeight: IddsLineHeight.sm,
                                  color: theme.colors.contentSecondary,
                                ),
                              ),
                        onSubmitted: (_) => _commit(),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
