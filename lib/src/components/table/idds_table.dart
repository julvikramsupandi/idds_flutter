import 'dart:math' as math;

import 'package:flutter/services.dart' show MouseCursor, SystemMouseCursors, TextInputFormatter, TextInputType;
import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../button/idds_button.dart';
import '../checkbox/idds_checkbox.dart';
import '../loading/idds_loading.dart';
import '../pagination/idds_pagination.dart';
import '../text_field/idds_text_field.dart';
import 'idds_table_field_input.dart';

/// Satu kolom [IddsTable].
@immutable
class IddsTableColumn<T> {
  /// Membuat kolom.
  const IddsTableColumn({
    required this.header,
    required this.cell,
    this.sortKey,
    this.width,
    this.alignment = AlignmentDirectional.centerStart,
    this.editor,
  });

  /// Judul kolom.
  final String header;

  /// Membangun isi sel untuk satu baris, misalnya `(row) => Text(row.nama)`.
  final Widget Function(BuildContext context, T row) cell;

  /// Bila diisi, kolom bisa diurutkan; nilai ini dikirim di
  /// [IddsTableSort.key].
  final String? sortKey;

  /// Lebar tetap. Bila `null`, kolom selebar isinya dan berbagi sisa ruang.
  final double? width;

  /// Perataan isi sel dan judul.
  final AlignmentGeometry alignment;

  /// Bila diisi, sel kolom ini bisa diedit langsung: ketuk sel (atau Enter
  /// saat sel terfokus) untuk membuka isian.
  final IddsTableCellEditor<T>? editor;
}

/// Pengaturan edit langsung untuk [IddsTableColumn.editor].
///
/// ```dart
/// IddsTableColumn<Pegawai>(
///   header: 'Nama',
///   cell: (c, p) => Text(p.nama),
///   editor: IddsTableCellEditor(
///     value: (p) => p.nama,
///     validator: (v) => v.trim().isEmpty ? 'Nama wajib diisi' : null,
///     onSubmitted: (p, v) => setState(() => p.nama = v),
///   ),
/// )
/// ```
@immutable
class IddsTableCellEditor<T> {
  /// Membuat pengaturan edit.
  const IddsTableCellEditor({
    required this.value,
    required this.onSubmitted,
    this.enabled,
    this.validator,
    this.placeholder,
    this.keyboardType,
    this.inputFormatters,
    this.builder,
  });

  /// Nilai awal isian untuk baris.
  final String Function(T row) value;

  /// Dipanggil dengan nilai baru setelah lolos [validator]. Aplikasi yang
  /// memperbarui datanya sendiri.
  final void Function(T row, String value) onSubmitted;

  /// Apakah sel baris ini bisa diedit. Bawaan: selalu.
  final bool Function(T row)? enabled;

  /// Mengembalikan pesan galat, atau `null` bila nilai sah.
  final String? Function(String value)? validator;

  /// Teks petunjuk.
  final String? placeholder;

  /// Jenis papan ketik.
  final TextInputType? keyboardType;

  /// Pembatas masukan.
  final List<TextInputFormatter>? inputFormatters;

  /// Isian kustom (mis. dropdown) sebagai ganti [IddsTableFieldInput].
  /// Panggil `close` setelah menyimpan atau membatalkan.
  final Widget Function(BuildContext context, T row, VoidCallback close)? builder;
}

/// Urutan tabel saat ini.
@immutable
class IddsTableSort {
  /// Membuat urutan.
  const IddsTableSort(this.key, {this.ascending = true});

  /// [IddsTableColumn.sortKey] kolom yang diurutkan.
  final String key;

  /// Naik (A–Z, kecil–besar) atau turun.
  final bool ascending;

  @override
  bool operator ==(Object other) => other is IddsTableSort && other.key == key && other.ascending == ascending;

  @override
  int get hashCode => Object.hash(key, ascending);
}

/// Tabel data IDDS dengan urutan kolom, pilihan baris, pencarian, dan
/// pagination.
///
/// Tabel ini tidak mengambil, mengurutkan, atau memotong data sendiri:
/// aplikasi memberikan [rows] untuk halaman saat ini dan menanggapi
/// [onSortChanged], [onSearch], dan [onPageChanged] (misalnya dengan
/// memanggil API). Dengan begitu tabel bisa dipakai untuk data lokal maupun
/// data server.
///
/// ```dart
/// IddsTable<Employee>(
///   rows: _currentPageRows,
///   columns: [
///     IddsTableColumn(header: 'Nama', sortKey: 'name', cell: (c, p) => Text(p.name)),
///     IddsTableColumn(header: 'Unit', cell: (c, p) => Text(p.unit)),
///   ],
///   sort: _sort,
///   onSortChanged: (s) => setState(() => _sort = s),
///   page: _page,
///   totalPages: _totalPages,
///   onPageChanged: (p) => setState(() => _page = p),
/// )
/// ```
class IddsTable<T> extends StatefulWidget {
  /// Membuat tabel.
  const IddsTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowKey,
    this.sort,
    this.onSortChanged,
    this.selectedKeys,
    this.onSelectionChanged,
    this.onRowTap,
    this.striped = false,
    this.loading = false,
    this.emptyState,
    this.emptyText = 'Data tidak ditemukan',
    this.showSearch = false,
    this.searchPlaceholder = 'Input pencarian',
    this.searchButtonLabel = 'Cari',
    this.onSearch,
    this.page,
    this.totalPages,
    this.onPageChanged,
    this.pageSize,
    this.pageSizeOptions = const <int>[10, 20, 50],
    this.onPageSizeChanged,
    this.stickyLastColumn = false,
  });

  /// Kolom-kolom.
  final List<IddsTableColumn<T>> columns;

  /// Baris yang ditampilkan.
  final List<T> rows;

  /// Kunci unik tiap baris untuk pilihan. Bawaan: baris itu sendiri.
  final Object Function(T row)? rowKey;

  /// Urutan saat ini.
  final IddsTableSort? sort;

  /// Dipanggil saat judul kolom yang bisa diurutkan ditekan. Menekan kolom
  /// yang sedang naik mengubahnya menjadi turun, selain itu naik.
  final ValueChanged<IddsTableSort>? onSortChanged;

  /// Kunci baris terpilih. Bila diisi bersama [onSelectionChanged], kolom
  /// kotak centang ditampilkan.
  final Set<Object>? selectedKeys;

  /// Dipanggil dengan kunci baris terpilih yang baru.
  final ValueChanged<Set<Object>>? onSelectionChanged;

  /// Bila diisi, baris bisa ditekan.
  final ValueChanged<T>? onRowTap;

  /// Baris belang (selang-seling).
  final bool striped;

  /// Tampilkan bilah memuat dan redupkan baris.
  final bool loading;

  /// Tampilan saat [rows] kosong. Bawaan: [emptyText].
  final Widget? emptyState;

  /// Teks saat [rows] kosong.
  final String emptyText;

  /// Tampilkan kolom pencarian di atas tabel.
  final bool showSearch;

  /// Placeholder pencarian.
  final String searchPlaceholder;

  /// Teks tombol cari.
  final String searchButtonLabel;

  /// Dipanggil saat tombol cari atau Enter ditekan.
  final ValueChanged<String>? onSearch;

  /// Halaman aktif (mulai dari 1). Pagination tampil bila [page],
  /// [totalPages], dan [onPageChanged] diisi.
  final int? page;

  /// Jumlah halaman.
  final int? totalPages;

  /// Dipanggil dengan halaman baru.
  final ValueChanged<int>? onPageChanged;

  /// Jumlah baris per halaman.
  final int? pageSize;

  /// Pilihan jumlah baris per halaman.
  final List<int> pageSizeOptions;

  /// Dipanggil dengan jumlah baris baru.
  final ValueChanged<int>? onPageSizeChanged;

  /// Kolom terakhir (biasanya Aksi) tetap terlihat di kanan saat tabel
  /// digeser mendatar.
  final bool stickyLastColumn;

  @override
  State<IddsTable<T>> createState() => _IddsTableState<T>();
}

class _IddsTableState<T> extends State<IddsTable<T>> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _hScroll = ScrollController();

  /// Jarak geser sel kolom terakhir agar menempel di kanan.
  final ValueNotifier<double> _stickyShift = ValueNotifier<double>(0);
  int? _hoveredRow;
  int? _pressedRow;
  int? _hoveredHeader;

  /// Sel yang sedang diedit: (kunci baris, indeks kolom).
  (Object, int)? _editing;
  final TextEditingController _draft = TextEditingController();
  String? _editError;

  @override
  void initState() {
    super.initState();
    _hScroll.addListener(_updateShift);
  }

  @override
  void dispose() {
    _search.dispose();
    _hScroll.dispose();
    _stickyShift.dispose();
    _draft.dispose();
    super.dispose();
  }

  void _updateShift() {
    if (!_hScroll.hasClients) return;
    final ScrollPosition p = _hScroll.position;
    if (!p.hasContentDimensions) return;
    _stickyShift.value = math.max(0, p.maxScrollExtent - p.pixels);
  }

  void _startEdit(T row, int column) {
    final IddsTableCellEditor<T> editor = widget.columns[column].editor!;
    setState(() {
      _editing = (_key(row), column);
      _editError = null;
      _draft.text = editor.value(row);
      _draft.selection = TextSelection(baseOffset: 0, extentOffset: _draft.text.length);
    });
  }

  void _closeEdit() {
    if (_editing == null) return;
    setState(() {
      _editing = null;
      _editError = null;
    });
  }

  void _commitEdit(T row, int column) {
    final IddsTableCellEditor<T> editor = widget.columns[column].editor!;
    final String value = _draft.text;
    final String? error = editor.validator?.call(value);
    if (error != null) {
      setState(() => _editError = error);
      return;
    }
    editor.onSubmitted(row, value);
    _closeEdit();
  }

  Object _key(T row) => widget.rowKey?.call(row) ?? row as Object;

  bool get _selectable => widget.selectedKeys != null && widget.onSelectionChanged != null;

  bool get _sticky => widget.stickyLastColumn && widget.columns.isNotEmpty;

  void _toggleRow(T row) {
    final Set<Object> next = <Object>{...widget.selectedKeys!};
    final Object key = _key(row);
    if (!next.remove(key)) next.add(key);
    widget.onSelectionChanged!(next);
  }

  void _toggleAll(bool allSelected) {
    final Set<Object> next = <Object>{...widget.selectedKeys!};
    for (final T row in widget.rows) {
      allSelected ? next.remove(_key(row)) : next.add(_key(row));
    }
    widget.onSelectionChanged!(next);
  }

  void _sortBy(String key) {
    final IddsTableSort? current = widget.sort;
    final bool ascending = !(current != null && current.key == key && current.ascending);
    widget.onSortChanged?.call(IddsTableSort(key, ascending: ascending));
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double screen = iddsScreenWidth(context);
    // CSS: padding 8px dan font 12px; 12px/16px dan font 14px di ≥ 1280px.
    final bool wide = screen >= IddsBreakpoint.xl;
    final EdgeInsets cellPadding = wide
        ? const EdgeInsets.symmetric(horizontal: IddsSpacing.s16, vertical: IddsSpacing.s12)
        : const EdgeInsets.all(IddsSpacing.s8);
    final double fontSize = wide ? IddsFontSize.sm : IddsFontSize.xs;
    final double lineHeight = wide ? IddsLineHeight.sm : IddsLineHeight.xs;
    final BorderSide line = BorderSide(color: c.strokePrimary);

    if (_sticky) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateShift();
      });
    }

    final List<T> rows = widget.rows;
    final Set<Object> selected = widget.selectedKeys ?? const <Object>{};
    final int selectedOnPage = rows.where((T r) => selected.contains(_key(r))).length;
    final bool allSelected = rows.isNotEmpty && selectedOnPage == rows.length;

    // Sel kolom terakhir yang menempel: digeser ke kiri sejauh sisa geseran
    // tabel, dengan latar sendiri agar menutupi sel di bawahnya.
    Widget stickyCell(Widget child, Color background, {bool header = false}) {
      return TableCell(
        // Setinggi baris (ikut menentukan tinggi baris) agar latarnya
        // menutupi sel lain sepenuhnya.
        verticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
        child: ValueListenableBuilder<double>(
          valueListenable: _stickyShift,
          builder: (BuildContext context, double shift, Widget? child) => Transform.translate(
            offset: Offset(-shift, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                border: Border(
                  left: shift > 0 ? line : BorderSide.none,
                  top: header ? line : BorderSide.none,
                  bottom: line,
                ),
                boxShadow: shift > 0
                    ? const <BoxShadow>[BoxShadow(color: Color(0x140A0D12), blurRadius: 8, offset: Offset(-4, 0))]
                    : null,
              ),
              child: child,
            ),
          ),
          child: Align(alignment: AlignmentDirectional.centerStart, widthFactor: 1, child: child),
        ),
      );
    }

    Widget headerCell(int index, IddsTableColumn<T> col) {
      final bool sortable = col.sortKey != null && widget.onSortChanged != null;
      final bool sorted = sortable && widget.sort?.key == col.sortKey;
      final bool descending = sorted && !(widget.sort!.ascending);
      final bool hovered = sortable && _hoveredHeader == index;
      // CSS: judul yang bisa diurutkan berlatar primary-500 saat disorot.
      final Color foreground = hovered ? c.backgroundPrimary : c.contentSecondary;
      final Widget content = Container(
        color: hovered ? c.primary.shade500 : null,
        padding: cellPadding,
        alignment: col.alignment,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: IddsSpacing.s4,
          children: <Widget>[
            Flexible(
              child: Text(
                col.header,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: theme.textStyle(fontSize: fontSize, lineHeight: lineHeight, color: foreground),
              ),
            ),
            if (sortable)
              IddsIcon(
                descending ? IddsIcons.arrowDown : IddsIcons.arrowUp,
                size: 16,
                strokeWidth: sorted ? 3 : 2,
                color: hovered ? foreground : (sorted ? c.primary.shade600 : c.contentSecondary),
              ),
          ],
        ),
      );
      if (!sortable) return content;
      return Semantics(
        button: true,
        label: 'Urutkan ${col.header}',
        value: sorted ? (descending ? 'turun' : 'naik') : null,
        onTap: () => _sortBy(col.sortKey!),
        excludeSemantics: true,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hoveredHeader = index),
          onExit: (_) => setState(() => _hoveredHeader = null),
          child: IddsInteractive(
            onTap: () => _sortBy(col.sortKey!),
            builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
              visible: state.focused,
              borderRadius: BorderRadius.zero,
              rings: <(double, Color)>[(2.0, c.primary.shade500)],
              child: content,
            ),
          ),
        ),
      );
    }

    final TableRow headerRow = TableRow(
      decoration: BoxDecoration(
        color: widget.striped ? c.backgroundSecondary : c.backgroundPrimary,
        border: Border(top: line, bottom: line),
      ),
      children: <Widget>[
        if (_selectable)
          Padding(
            padding: cellPadding,
            child: IddsCheckbox(
              value: allSelected,
              indeterminate: selectedOnPage > 0 && !allSelected,
              onChanged: rows.isEmpty ? null : (_) => _toggleAll(allSelected),
            ),
          ),
        for (int i = 0; i < widget.columns.length; i++)
          _sticky && i == widget.columns.length - 1
              ? stickyCell(headerCell(i, widget.columns[i]), widget.striped ? c.backgroundSecondary : c.backgroundPrimary, header: true)
              : headerCell(i, widget.columns[i]),
      ],
    );

    final bool clickable = widget.onRowTap != null;
    final TextStyle cellStyle = theme.textStyle(
      fontSize: fontSize,
      lineHeight: lineHeight,
      fontWeight: IddsFontWeight.medium,
      color: c.contentPrimary,
    );

    TableRow dataRow(int index, T row) {
      final bool hovered = _hoveredRow == index;
      final bool pressed = _pressedRow == index;
      Color? background = widget.striped && index.isOdd ? c.backgroundSecondary : null;
      if (pressed && clickable) {
        background = c.backgroundTertiary;
      } else if (hovered) {
        background = widget.striped ? c.backgroundTertiary : c.backgroundSecondary;
      }

      Widget wrap(Widget child) {
        // Setiap sel meneruskan sorot dan ketukan ke baris.
        return MouseRegion(
          cursor: clickable ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: (_) => setState(() => _hoveredRow = index),
          onExit: (_) {
            if (_hoveredRow == index) setState(() => _hoveredRow = null);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: clickable ? () => widget.onRowTap!(row) : null,
            onTapDown: clickable ? (_) => setState(() => _pressedRow = index) : null,
            onTapUp: clickable ? (_) => setState(() => _pressedRow = null) : null,
            onTapCancel: clickable ? () => setState(() => _pressedRow = null) : null,
            child: child,
          ),
        );
      }

      Widget dataCell(T row, int ci) {
        final IddsTableColumn<T> col = widget.columns[ci];
        final IddsTableCellEditor<T>? editor = col.editor;
        final bool editable = editor != null && (editor.enabled?.call(row) ?? true);
        final (Object, int)? current = _editing;
        if (editable && current != null && current.$1 == _key(row) && current.$2 == ci) {
          final IddsTableCellEditor<T> ed = editor;
          // CSS: primary-50; di dark mode latar sekunder agar tidak silau.
          return Container(
            color: theme.isDark ? c.backgroundSecondary : c.primary.shade50,
            padding: EdgeInsets.symmetric(horizontal: cellPadding.left, vertical: IddsSpacing.s4),
            alignment: col.alignment,
            child: SizedBox(
              width: math.max(col.width ?? 0, 240),
              child: ed.builder != null
                  ? ed.builder!(context, row, _closeEdit)
                  : IddsTableFieldInput(
                      controller: _draft,
                      placeholder: ed.placeholder,
                      errorText: _editError,
                      keyboardType: ed.keyboardType,
                      inputFormatters: ed.inputFormatters,
                      onCommit: () => _commitEdit(row, ci),
                      onCancel: _closeEdit,
                    ),
            ),
          );
        }
        final Widget content = DefaultTextStyle(style: cellStyle, softWrap: false, child: col.cell(context, row));
        if (!editable) {
          return wrap(Container(padding: cellPadding, alignment: col.alignment, child: content));
        }
        return wrap(Semantics(
          button: true,
          hint: 'Ketuk untuk mengedit ${col.header}',
          child: IddsInteractive(
            onTap: () => _startEdit(row, ci),
            builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
              visible: state.focused,
              borderRadius: BorderRadius.zero,
              rings: <(double, Color)>[(2.0, c.primary.shade500)],
              child: Container(
                padding: cellPadding,
                alignment: col.alignment,
                // Garis putus-putus tidak ada di Flutter; garis bawah tipis
                // saat disorot menandai sel bisa diedit.
                foregroundDecoration: state.hovered
                    ? BoxDecoration(border: Border(bottom: BorderSide(color: c.strokeSecondary)))
                    : null,
                child: content,
              ),
            ),
          ),
        ));
      }

      return TableRow(
        decoration: BoxDecoration(color: background, border: Border(bottom: line)),
        children: <Widget>[
          if (_selectable)
            wrap(Padding(
              padding: cellPadding,
              child: IddsCheckbox(value: selected.contains(_key(row)), onChanged: (_) => _toggleRow(row)),
            )),
          for (int ci = 0; ci < widget.columns.length; ci++)
            _sticky && ci == widget.columns.length - 1
                ? stickyCell(dataCell(row, ci), background ?? c.backgroundPrimary)
                : dataCell(row, ci),
        ],
      );
    }

    final Map<int, TableColumnWidth> widths = <int, TableColumnWidth>{
      if (_selectable) 0: const IntrinsicColumnWidth(),
      for (int i = 0; i < widget.columns.length; i++)
        i + (_selectable ? 1 : 0): widget.columns[i].width != null
            ? FixedColumnWidth(widget.columns[i].width!)
            : _sticky && i == widget.columns.length - 1
                // CSS: kolom menempel minimal 120px.
                ? const MaxColumnWidth(IntrinsicColumnWidth(flex: 1), FixedColumnWidth(120))
                : const IntrinsicColumnWidth(flex: 1),
    };

    final Widget table = Table(
      columnWidths: widths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        headerRow,
        for (int i = 0; i < rows.length; i++) dataRow(i, rows[i]),
      ],
    );

    Widget body = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          _updateShift();
          return false;
        },
        child: SingleChildScrollView(
        controller: _hScroll,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          // Selebar wadah bila muat; bila tidak, tabel bisa digeser.
          constraints: BoxConstraints(minWidth: constraints.hasBoundedWidth ? constraints.maxWidth : 0),
          child: IntrinsicWidth(child: table),
        ),
      ),
      ),
    );
    if (widget.loading) body = Opacity(opacity: 0.6, child: IgnorePointer(child: body));

    final Widget empty = Container(
      padding: const EdgeInsets.all(IddsSpacing.s16),
      decoration: BoxDecoration(border: Border(bottom: line)),
      alignment: Alignment.center,
      child: widget.emptyState ??
          Text(
            widget.emptyText,
            style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: c.contentSecondary),
          ),
    );

    final bool showPagination = widget.page != null && widget.totalPages != null && widget.onPageChanged != null;
    final bool small = screen < IddsBreakpoint.sm;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (widget.showSearch)
            Padding(
              padding: const EdgeInsets.only(bottom: IddsSpacing.s16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Row(
                    spacing: IddsSpacing.s8,
                    children: <Widget>[
                      Expanded(
                        child: IddsTextField(
                          controller: _search,
                          size: IddsTextFieldSize.sm,
                          enabled: !widget.loading,
                          placeholder: widget.searchPlaceholder,
                          prefixIcon: const IddsIcon(IddsIcons.search),
                          onSubmitted: widget.onSearch,
                        ),
                      ),
                      IddsButton(
                        size: IddsButtonSize.sm,
                        onPressed: widget.loading || widget.onSearch == null ? null : () => widget.onSearch!(_search.text),
                        child: Text(widget.searchButtonLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Ruang bilah memuat selalu ada agar tabel tidak melompat.
          SizedBox(height: 4, child: widget.loading ? const IddsProgressBar() : null),
          body,
          if (rows.isEmpty && !widget.loading) empty,
          if (showPagination)
            Padding(
              padding: EdgeInsets.all(small ? IddsSpacing.s8 : IddsSpacing.s16),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IddsPagination(
                  currentPage: widget.page!,
                  totalPages: widget.totalPages!,
                  onPageChanged: widget.loading ? null : widget.onPageChanged,
                  pageSize: widget.pageSize,
                  pageSizeOptions: widget.pageSizeOptions,
                  onPageSizeChanged: widget.loading ? null : widget.onPageSizeChanged,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
