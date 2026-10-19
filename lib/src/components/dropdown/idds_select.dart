import 'dart:async';

import 'package:flutter/material.dart' show InputDecoration, TextField, VisualDensity;
import 'package:flutter/services.dart' show KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey, SystemMouseCursors;
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
import 'idds_dropdown_trigger.dart';

/// Penanda pilihan di setiap opsi [IddsSelect] / [IddsMultiSelect].
enum IddsSelectIndicator {
  /// Tanpa penanda; opsi terpilih hanya diberi latar.
  none,

  /// Kotak centang.
  checkbox,

  /// Lingkaran radio.
  radio,
}

/// Satu opsi di [IddsSelect] / [IddsMultiSelect].
@immutable
class IddsSelectOption<T> {
  /// Membuat opsi.
  const IddsSelectOption({required this.value, required this.label, this.enabled = true, this.leading});

  /// Nilai opsi.
  final T value;

  /// Teks opsi; juga dipakai untuk pencarian.
  final String label;

  /// Apakah opsi bisa dipilih.
  final bool enabled;

  /// Widget di kiri teks, misalnya ikon atau avatar.
  final Widget? leading;
}

/// Dropdown untuk memilih satu nilai.
///
/// ```dart
/// IddsSelect<String>(
///   label: const Text('Provinsi'),
///   value: _province,
///   onChanged: (v) => setState(() => _province = v),
///   searchable: true,
///   options: const [
///     IddsSelectOption(value: 'jabar', label: 'Jawa Barat'),
///     IddsSelectOption(value: 'jateng', label: 'Jawa Tengah'),
///   ],
/// )
/// ```
class IddsSelect<T> extends StatelessWidget {
  /// Membuat select satu pilihan.
  const IddsSelect({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Pilih...',
    this.size = IddsDropdownSize.md,
    this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.error = false,
    this.indicator = IddsSelectIndicator.none,
    this.mandatorySelected = true,
    this.searchable = false,
    this.searchPlaceholder = 'Cari...',
    this.onSearch,
    this.emptyText = 'Data tidak ditemukan',
    this.loading = false,
    this.loadingText = 'Memuat...',
    this.hasMore = false,
    this.onLoadMore,
    this.loadMoreText = 'Muat lebih banyak',
    this.prefix,
    this.width,
    this.panelWidth,
    this.panelMaxHeight = 600,
    this.focusNode,
  });

  /// Opsi yang tersedia.
  final List<IddsSelectOption<T>> options;

  /// Nilai terpilih.
  final T? value;

  /// Dipanggil dengan nilai baru (`null` bila pilihan dihapus). `null`
  /// membuat select nonaktif.
  final ValueChanged<T?>? onChanged;

  /// Teks saat belum ada pilihan.
  final String placeholder;

  /// Ukuran.
  final IddsDropdownSize size;

  /// Label di atas kolom.
  final Widget? label;

  /// Tampilkan tanda wajib (*) setelah [label].
  final bool required;

  /// Teks bantuan di bawah kolom.
  final String? helperText;

  /// Pesan error. Bila diisi, kolom ditampilkan dalam status error.
  final String? errorText;

  /// Status error tanpa pesan.
  final bool error;

  /// Penanda pilihan di setiap opsi.
  final IddsSelectIndicator indicator;

  /// Bila `false`, menekan opsi yang sudah terpilih akan menghapus pilihan.
  final bool mandatorySelected;

  /// Tampilkan kolom pencarian di atas daftar opsi.
  final bool searchable;

  /// Placeholder kolom pencarian.
  final String searchPlaceholder;

  /// Pencarian di server. Dipanggil 300ms setelah pengguna berhenti
  /// mengetik; [options] tidak lagi disaring di sisi klien.
  final ValueChanged<String>? onSearch;

  /// Teks saat tidak ada opsi.
  final String emptyText;

  /// Tampilkan baris "Memuat...".
  final bool loading;

  /// Teks baris memuat.
  final String loadingText;

  /// Masih ada opsi berikutnya untuk dimuat.
  final bool hasMore;

  /// Dipanggil saat pengguna menggulir ke akhir daftar atau menekan
  /// "Muat lebih banyak".
  final VoidCallback? onLoadMore;

  /// Teks tombol muat lebih banyak.
  final String loadMoreText;

  /// Widget di kiri teks pemicu.
  final Widget? prefix;

  /// Lebar kolom. Bila `null`, mengikuti lebar yang tersedia.
  final double? width;

  /// Lebar panel. Bila `null`, minimal selebar kolom.
  final double? panelWidth;

  /// Tinggi maksimal panel.
  final double panelMaxHeight;

  /// Focus node pemicu.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<T?>? onChanged = this.onChanged;
    return IddsSelectField<T>(
      options: options,
      selected: <T>[if (value != null) value as T],
      multiple: false,
      onToggle: onChanged == null
          ? null
          : (T v) {
              if (v == value) {
                if (!mandatorySelected) onChanged(null);
              } else {
                onChanged(v);
              }
            },
      displayText: (List<String> labels) => labels.isEmpty ? null : labels.first,
      placeholder: placeholder,
      size: size,
      label: label,
      required: required,
      helperText: helperText,
      errorText: errorText,
      error: error,
      indicator: indicator,
      searchable: searchable,
      searchPlaceholder: searchPlaceholder,
      onSearch: onSearch,
      emptyText: emptyText,
      loading: loading,
      loadingText: loadingText,
      hasMore: hasMore,
      onLoadMore: onLoadMore,
      loadMoreText: loadMoreText,
      prefix: prefix,
      width: width,
      panelWidth: panelWidth,
      panelMaxHeight: panelMaxHeight,
      focusNode: focusNode,
      preview: false,
      moreLabel: '',
    );
  }
}

/// Dropdown untuk memilih banyak nilai. Panel tetap terbuka setelah opsi
/// dipilih.
///
/// Teks pemicu berisi label terpilih yang dipisah koma (sampai 3 pilihan),
/// lalu "n data terpilih" (bisa diubah lewat [selectionText]).
class IddsMultiSelect<T> extends StatelessWidget {
  /// Membuat select banyak pilihan.
  const IddsMultiSelect({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    this.placeholder = 'Pilih...',
    this.size = IddsDropdownSize.md,
    this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.error = false,
    this.indicator = IddsSelectIndicator.checkbox,
    this.searchable = false,
    this.searchPlaceholder = 'Cari...',
    this.onSearch,
    this.emptyText = 'Data tidak ditemukan',
    this.loading = false,
    this.loadingText = 'Memuat...',
    this.hasMore = false,
    this.onLoadMore,
    this.loadMoreText = 'Muat lebih banyak',
    this.showPreview = false,
    this.moreLabel = 'lainnya',
    this.selectionText,
    this.prefix,
    this.width,
    this.panelWidth,
    this.panelMaxHeight = 600,
    this.focusNode,
  });

  /// Opsi yang tersedia.
  final List<IddsSelectOption<T>> options;

  /// Nilai terpilih.
  final Set<T> values;

  /// Dipanggil dengan himpunan nilai baru. `null` membuat select nonaktif.
  final ValueChanged<Set<T>>? onChanged;

  /// Teks saat belum ada pilihan.
  final String placeholder;

  /// Ukuran.
  final IddsDropdownSize size;

  /// Label di atas kolom.
  final Widget? label;

  /// Tampilkan tanda wajib (*) setelah [label].
  final bool required;

  /// Teks bantuan di bawah kolom.
  final String? helperText;

  /// Pesan error. Bila diisi, kolom ditampilkan dalam status error.
  final String? errorText;

  /// Status error tanpa pesan.
  final bool error;

  /// Penanda pilihan di setiap opsi.
  final IddsSelectIndicator indicator;

  /// Tampilkan kolom pencarian di atas daftar opsi.
  final bool searchable;

  /// Placeholder kolom pencarian.
  final String searchPlaceholder;

  /// Pencarian di server. Lihat [IddsSelect.onSearch].
  final ValueChanged<String>? onSearch;

  /// Teks saat tidak ada opsi.
  final String emptyText;

  /// Tampilkan baris "Memuat...".
  final bool loading;

  /// Teks baris memuat.
  final String loadingText;

  /// Masih ada opsi berikutnya untuk dimuat.
  final bool hasMore;

  /// Lihat [IddsSelect.onLoadMore].
  final VoidCallback? onLoadMore;

  /// Teks tombol muat lebih banyak.
  final String loadMoreText;

  /// Tampilkan pilihan sebagai chip yang bisa dihapus di atas panel
  /// (3 pertama, lalu "+n lainnya").
  final bool showPreview;

  /// Teks "lainnya" pada pratinjau.
  final String moreLabel;

  /// Teks pemicu bila lebih dari 3 pilihan. Bawaan: "n data terpilih".
  final String Function(int count)? selectionText;

  /// Widget di kiri teks pemicu.
  final Widget? prefix;

  /// Lebar kolom. Bila `null`, mengikuti lebar yang tersedia.
  final double? width;

  /// Lebar panel. Bila `null`, minimal selebar kolom.
  final double? panelWidth;

  /// Tinggi maksimal panel.
  final double panelMaxHeight;

  /// Focus node pemicu.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<Set<T>>? onChanged = this.onChanged;
    return IddsSelectField<T>(
      options: options,
      selected: values.toList(),
      multiple: true,
      onToggle: onChanged == null
          ? null
          : (T v) {
              final Set<T> next = Set<T>.of(values);
              if (!next.remove(v)) next.add(v);
              onChanged(next);
            },
      displayText: (List<String> labels) {
        if (labels.isEmpty) return null;
        if (labels.length <= 3) return labels.join(', ');
        return selectionText?.call(labels.length) ?? '${labels.length} data terpilih';
      },
      placeholder: placeholder,
      size: size,
      label: label,
      required: required,
      helperText: helperText,
      errorText: errorText,
      error: error,
      indicator: indicator,
      searchable: searchable,
      searchPlaceholder: searchPlaceholder,
      onSearch: onSearch,
      emptyText: emptyText,
      loading: loading,
      loadingText: loadingText,
      hasMore: hasMore,
      onLoadMore: onLoadMore,
      loadMoreText: loadMoreText,
      prefix: prefix,
      width: width,
      panelWidth: panelWidth,
      panelMaxHeight: panelMaxHeight,
      focusNode: focusNode,
      preview: showPreview,
      moreLabel: moreLabel,
    );
  }
}

/// Implementasi bersama [IddsSelect] dan [IddsMultiSelect]. Internal.
class IddsSelectField<T> extends StatefulWidget {
  /// Membuat kolom select.
  const IddsSelectField({
    super.key,
    required this.options,
    required this.selected,
    required this.multiple,
    required this.onToggle,
    required this.displayText,
    required this.placeholder,
    required this.size,
    required this.label,
    required this.required,
    required this.helperText,
    required this.errorText,
    required this.error,
    required this.indicator,
    required this.searchable,
    required this.searchPlaceholder,
    required this.onSearch,
    required this.emptyText,
    required this.loading,
    required this.loadingText,
    required this.hasMore,
    required this.onLoadMore,
    required this.loadMoreText,
    required this.prefix,
    required this.width,
    required this.panelWidth,
    required this.panelMaxHeight,
    required this.focusNode,
    required this.preview,
    required this.moreLabel,
  });

  /// Opsi.
  final List<IddsSelectOption<T>> options;

  /// Nilai terpilih, berurutan.
  final List<T> selected;

  /// Banyak pilihan.
  final bool multiple;

  /// Dipanggil saat opsi ditekan.
  final ValueChanged<T>? onToggle;

  /// Teks pemicu dari label terpilih; `null` menampilkan placeholder.
  final String? Function(List<String> labels) displayText;

  /// Lihat [IddsSelect.placeholder].
  final String placeholder;

  /// Lihat [IddsSelect.size].
  final IddsDropdownSize size;

  /// Lihat [IddsSelect.label].
  final Widget? label;

  /// Lihat [IddsSelect.required].
  final bool required;

  /// Lihat [IddsSelect.helperText].
  final String? helperText;

  /// Lihat [IddsSelect.errorText].
  final String? errorText;

  /// Lihat [IddsSelect.error].
  final bool error;

  /// Lihat [IddsSelect.indicator].
  final IddsSelectIndicator indicator;

  /// Lihat [IddsSelect.searchable].
  final bool searchable;

  /// Lihat [IddsSelect.searchPlaceholder].
  final String searchPlaceholder;

  /// Lihat [IddsSelect.onSearch].
  final ValueChanged<String>? onSearch;

  /// Lihat [IddsSelect.emptyText].
  final String emptyText;

  /// Lihat [IddsSelect.loading].
  final bool loading;

  /// Lihat [IddsSelect.loadingText].
  final String loadingText;

  /// Lihat [IddsSelect.hasMore].
  final bool hasMore;

  /// Lihat [IddsSelect.onLoadMore].
  final VoidCallback? onLoadMore;

  /// Lihat [IddsSelect.loadMoreText].
  final String loadMoreText;

  /// Lihat [IddsSelect.prefix].
  final Widget? prefix;

  /// Lihat [IddsSelect.width].
  final double? width;

  /// Lihat [IddsSelect.panelWidth].
  final double? panelWidth;

  /// Lihat [IddsSelect.panelMaxHeight].
  final double panelMaxHeight;

  /// Lihat [IddsSelect.focusNode].
  final FocusNode? focusNode;

  /// Lihat [IddsMultiSelect.showPreview].
  final bool preview;

  /// Lihat [IddsMultiSelect.moreLabel].
  final String moreLabel;

  @override
  State<IddsSelectField<T>> createState() => _IddsSelectFieldState<T>();
}

class _IddsSelectFieldState<T> extends State<IddsSelectField<T>> {
  bool _open = false;
  String _query = '';
  int _highlight = -1;
  bool _keyboardNav = false;
  Timer? _debounce;
  FocusNode? _ownTriggerFocus;
  final FocusNode _panelFocus = FocusNode(debugLabel: 'IddsSelect panel');
  final FocusNode _searchFocus = FocusNode(debugLabel: 'IddsSelect search');
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final Map<T, String> _labels = <T, String>{};
  List<GlobalKey> _optionKeys = <GlobalKey>[];

  FocusNode get _triggerFocus => widget.focusNode ?? (_ownTriggerFocus ??= FocusNode(debugLabel: 'IddsSelect'));

  bool get _enabled => widget.onToggle != null;

  @override
  void didUpdateWidget(IddsSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && _open) _open = false;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ownTriggerFocus?.dispose();
    _panelFocus.dispose();
    _searchFocus.dispose();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<IddsSelectOption<T>> get _filtered {
    final String q = _query.trim().toLowerCase();
    if (widget.onSearch != null || q.isEmpty) return widget.options;
    return <IddsSelectOption<T>>[
      for (final IddsSelectOption<T> o in widget.options)
        if (o.label.toLowerCase().contains(q)) o,
    ];
  }

  void _toggleOpen() => _open ? _close() : _openPanel();

  void _openPanel() {
    if (!_enabled) return;
    final List<IddsSelectOption<T>> options = _filtered;
    int highlight = options.indexWhere((IddsSelectOption<T> o) => widget.selected.contains(o.value));
    if (highlight < 0) highlight = options.indexWhere((IddsSelectOption<T> o) => o.enabled);
    setState(() {
      _open = true;
      _highlight = highlight;
      _keyboardNav = false;
    });
  }

  void _close() {
    if (!_open) return;
    final bool refocus = _panelFocus.hasFocus;
    _debounce?.cancel();
    if (_query.isNotEmpty) widget.onSearch?.call('');
    setState(() {
      _open = false;
      _query = '';
    });
    _search.clear();
    if (refocus) _triggerFocus.requestFocus();
  }

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _highlight = _filtered.indexWhere((IddsSelectOption<T> o) => o.enabled);
    });
    if (widget.onSearch != null) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () => widget.onSearch?.call(value));
    }
  }

  void _choose(IddsSelectOption<T> option) {
    if (!option.enabled || !_enabled) return;
    widget.onToggle!(option.value);
    if (!widget.multiple) _close();
  }

  void _move(int delta) {
    final List<IddsSelectOption<T>> options = _filtered;
    if (options.isEmpty) return;
    int i = _highlight;
    for (int n = 0; n < options.length; n++) {
      i = (i + delta) % options.length;
      if (i < 0) i += options.length;
      if (options[i].enabled) break;
    }
    _setHighlight(i, keyboard: true);
  }

  void _setHighlight(int index, {required bool keyboard}) {
    setState(() {
      _highlight = index;
      _keyboardNav = keyboard;
    });
    if (keyboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final BuildContext? ctx = index >= 0 && index < _optionKeys.length ? _optionKeys[index].currentContext : null;
        if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.5, duration: IddsDuration.fast);
      });
    }
  }

  KeyEventResult _onPanelKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      _close();
      return KeyEventResult.ignored;
    }
    // Saat kolom pencarian aktif, Enter ditangani onSubmitted dan Spasi
    // dipakai untuk mengetik.
    if (!_searchFocus.hasFocus &&
        (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || key == LogicalKeyboardKey.space)) {
      _chooseHighlighted();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _chooseHighlighted() {
    final List<IddsSelectOption<T>> options = _filtered;
    if (_highlight >= 0 && _highlight < options.length) _choose(options[_highlight]);
  }

  bool _onScroll(ScrollNotification n) {
    if (widget.hasMore && !widget.loading && widget.onLoadMore != null && n.metrics.extentAfter < 40) {
      widget.onLoadMore!();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final IddsDropdownMetrics m = IddsDropdownMetrics.of(context, widget.size);
    for (final IddsSelectOption<T> o in widget.options) {
      _labels[o.value] = o.label;
    }
    final List<String> labels = <String>[
      for (final T v in widget.selected) _labels[v] ?? '$v',
    ];
    final String? text = widget.displayText(labels);
    final bool hasError = widget.error || widget.errorText != null;

    final Widget trigger = Semantics(
      button: true,
      enabled: _enabled,
      value: text ?? '',
      hint: text == null ? widget.placeholder : null,
      onTap: _enabled ? _toggleOpen : null,
      excludeSemantics: true,
      child: IddsInteractive(
        focusNode: _triggerFocus,
        onTap: _enabled ? _toggleOpen : null,
        builder: (BuildContext context, IddsInteractionState state) => IddsDropdownTriggerBox(
          state: state,
          open: _open,
          metrics: m,
          error: hasError,
          prefix: widget.prefix,
          child: text == null ? Text(widget.placeholder, style: TextStyle(color: c.contentTertiary)) : Text(text),
        ),
      ),
    );

    final Widget popover = IddsPopover(
      open: _open,
      onDismiss: _close,
      width: widget.panelWidth,
      maxHeight: widget.panelMaxHeight,
      panelBuilder: (BuildContext context) => _buildPanel(context, m),
      child: trigger,
    );

    final String? message = widget.errorText ?? widget.helperText;
    final Widget field = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.label != null) IddsFieldLabel(label: widget.label!, required: widget.required, small: m.small),
        popover,
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: IddsSpacing.s4),
            child: Text(
              message,
              style: theme.textStyle(
                fontSize: IddsFontSize.xs,
                lineHeight: IddsLineHeight.xs,
                color: widget.errorText != null ? c.negative.shade500 : c.contentSecondary,
              ),
            ),
          ),
      ],
    );

    if (widget.width != null) return SizedBox(width: widget.width, child: field);
    // Di dalam Row tanpa batas lebar, pakai lebar 240px.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          constraints.hasBoundedWidth ? field : SizedBox(width: 240, child: field),
    );
  }

  Widget _buildPanel(BuildContext context, IddsDropdownMetrics m) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final List<IddsSelectOption<T>> options = _filtered;
    if (_optionKeys.length != options.length) {
      _optionKeys = List<GlobalKey>.generate(options.length, (_) => GlobalKey());
    }
    final TextStyle textStyle = theme.textStyle(fontSize: m.fontSize, lineHeight: m.lineHeight, color: c.contentPrimary);
    final BorderSide divider = BorderSide(color: c.strokePrimary);

    Widget statusRow(Widget child, {VoidCallback? onTap}) {
      final Widget row = Container(
        padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12, vertical: IddsSpacing.s8),
        decoration: BoxDecoration(border: Border(top: divider)),
        alignment: Alignment.center,
        child: child,
      );
      if (onTap == null) return row;
      return IddsInteractive(
        onTap: onTap,
        canRequestFocus: false,
        builder: (BuildContext context, IddsInteractionState state) => row,
      );
    }

    final List<T> selected = widget.selected;
    return _RequestFocusOnMount(
      node: widget.searchable ? _searchFocus : _panelFocus,
      child: Focus(
        focusNode: _panelFocus,
        onKeyEvent: _onPanelKey,
        child: IddsPopoverSurface(
          child: DefaultTextStyle(
            style: textStyle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (widget.searchable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12, vertical: IddsSpacing.s8),
                    decoration: BoxDecoration(border: Border(bottom: divider)),
                    child: Row(
                      spacing: IddsSpacing.s8,
                      children: <Widget>[
                        IddsIcon(IddsIcons.search, size: 16, color: c.contentSecondary),
                        Expanded(
                          child: iddsMaterialShim(
                            context,
                            TextField(
                              controller: _search,
                              focusNode: _searchFocus,
                              style: textStyle,
                              cursorColor: c.contentPrimary,
                              onChanged: _onQueryChanged,
                              onSubmitted: (_) => _chooseHighlighted(),
                              // Jangan lepas fokus setelah Enter (banyak pilihan).
                              onEditingComplete: () {},
                              // Menekan opsi tidak boleh melepas fokus pencarian;
                              // tekan di luar panel sudah menutup panel.
                              onTapOutside: (_) {},
                              decoration: InputDecoration.collapsed(
                                hintText: widget.searchPlaceholder,
                                hintStyle: textStyle.copyWith(color: c.contentTertiary),
                              ).copyWith(visualDensity: VisualDensity.standard),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.preview && selected.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(IddsSpacing.s12),
                    decoration: BoxDecoration(border: Border(bottom: divider)),
                    child: Wrap(
                      spacing: IddsSpacing.s4,
                      runSpacing: IddsSpacing.s4,
                      children: <Widget>[
                        for (final T v in selected.take(3))
                          _PreviewChip(
                            label: _labels[v] ?? '$v',
                            onRemove: _enabled ? () => widget.onToggle!(v) : null,
                          ),
                        if (selected.length > 3) _PreviewChip(label: '+${selected.length - 3} ${widget.moreLabel}'),
                      ],
                    ),
                  ),
                Flexible(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.all(IddsSpacing.s4),
                      child: options.isEmpty && !widget.loading
                          ? Padding(
                              padding: const EdgeInsets.all(IddsSpacing.s12 - IddsSpacing.s4),
                              child: Text(
                                widget.emptyText,
                                textAlign: TextAlign.center,
                                style: textStyle.copyWith(color: c.contentSecondary, fontStyle: FontStyle.italic),
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                for (int i = 0; i < options.length; i++)
                                  _OptionRow(
                                    key: _optionKeys[i],
                                    label: options[i].label,
                                    leading: options[i].leading,
                                    enabled: _enabled && options[i].enabled,
                                    selected: selected.contains(options[i].value),
                                    highlighted: i == _highlight,
                                    focusRing: i == _highlight && _keyboardNav,
                                    indicator: widget.indicator,
                                    minHeight: m.optionMinHeight,
                                    onHover: () {
                                      if (_highlight != i || _keyboardNav) _setHighlight(i, keyboard: false);
                                    },
                                    onTap: () => _choose(options[i]),
                                  ),
                              ],
                            ),
                    ),
                  ),
                ),
                if (widget.loading)
                  statusRow(Text(widget.loadingText, style: textStyle.copyWith(color: c.contentSecondary)))
                else if (widget.hasMore && widget.onLoadMore != null)
                  statusRow(
                    Text(widget.loadMoreText, style: theme.textStyle(
                      fontSize: m.fontSize,
                      lineHeight: m.lineHeight,
                      fontWeight: IddsFontWeight.medium,
                      color: c.contentPrimary,
                    )),
                    onTap: widget.onLoadMore,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Meminta fokus untuk [node] sekali setelah dipasang.
class _RequestFocusOnMount extends StatefulWidget {
  const _RequestFocusOnMount({required this.node, required this.child});

  final FocusNode node;
  final Widget child;

  @override
  State<_RequestFocusOnMount> createState() => _RequestFocusOnMountState();
}

class _RequestFocusOnMountState extends State<_RequestFocusOnMount> {
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

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    super.key,
    required this.label,
    required this.leading,
    required this.enabled,
    required this.selected,
    required this.highlighted,
    required this.focusRing,
    required this.indicator,
    required this.minHeight,
    required this.onHover,
    required this.onTap,
  });

  final String label;
  final Widget? leading;
  final bool enabled;
  final bool selected;
  final bool highlighted;
  final bool focusRing;
  final IddsSelectIndicator indicator;
  final double minHeight;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final BorderRadius radius = BorderRadius.circular(IddsRadius.base);
    final Color? background = enabled && highlighted
        ? c.backgroundTertiary
        : selected
            ? c.backgroundSecondary
            : null;
    final Color foreground = enabled ? c.contentPrimary : c.contentTertiary;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: enabled ? (_) => onHover() : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: IddsInsetRing(
            visible: focusRing,
            borderRadius: radius,
            rings: <(double, Color)>[(2.0, c.contentTertiary)],
            child: Container(
              constraints: BoxConstraints(minHeight: minHeight),
              padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12, vertical: 10),
              decoration: BoxDecoration(color: background, borderRadius: radius),
              child: IconTheme(
                data: IconThemeData(size: 16, color: foreground),
                child: Row(
                  spacing: IddsSpacing.s12,
                  children: <Widget>[
                    if (indicator != IddsSelectIndicator.none)
                      _Indicator(type: indicator, selected: selected, enabled: enabled),
                    if (leading != null) leading!,
                    Expanded(
                      child: Text(label, style: TextStyle(color: foreground)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.type, required this.selected, required this.enabled});

  final IddsSelectIndicator type;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final bool radio = type == IddsSelectIndicator.radio;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: AnimatedContainer(
        duration: IddsDuration.fast,
        width: 16,
        height: 16,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected && !radio ? c.contentPrimary : c.backgroundPrimary,
          shape: radio ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: radio ? null : BorderRadius.circular(IddsRadius.base),
          border: Border.all(color: selected ? c.contentPrimary : c.strokeSecondary),
        ),
        child: !selected
            ? null
            : radio
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: c.contentPrimary, shape: BoxShape.circle),
                  )
                : IddsIcon(IddsIcons.check, size: 12, strokeWidth: 2.5, color: c.backgroundPrimary),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s8, vertical: IddsSpacing.s4),
      decoration: BoxDecoration(color: c.backgroundSecondary, borderRadius: BorderRadius.circular(IddsRadius.md)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: IddsSpacing.s4,
        children: <Widget>[
          Text(
            label,
            style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentPrimary),
          ),
          if (onRemove != null)
            Semantics(
              button: true,
              label: 'Hapus $label',
              onTap: onRemove,
              excludeSemantics: true,
              child: IddsInteractive(
                onTap: onRemove,
                canRequestFocus: false,
                builder: (BuildContext context, IddsInteractionState state) => IddsIcon(
                  IddsIcons.x,
                  size: 12,
                  color: state.hovered ? c.contentPrimary : c.contentSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
