import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class _Application {
  _Application(this.id, this.name, this.service, this.date, this.status);

  final int id;
  String name; // bisa diedit dari tabel
  final String service;
  final DateTime date;
  final String status;
}

final List<_Application> _all = <_Application>[
  for (int i = 0; i < 47; i++)
    _Application(
      i + 1,
      const <String>['Andi Pratama', 'Budi Santoso', 'Citra Lestari', 'Dewi Anggraini', 'Eko Saputra', 'Fitri Handayani'][i % 6],
      const <String>['KTP Elektronik', 'Kartu Keluarga', 'Akta Kelahiran', 'Beasiswa'][i % 4],
      DateTime(2026, 1 + i % 9, 1 + (i * 7) % 28),
      const <String>['Diproses', 'Selesai', 'Ditolak'][i % 3],
    ),
];

class TableSection extends StatefulWidget {
  const TableSection({super.key});

  @override
  State<TableSection> createState() => _TableSectionState();
}

class _TableSectionState extends State<TableSection> {
  IddsTableSort? _sort = const IddsTableSort('date', ascending: false);
  String _query = '';
  int _page = 1;
  int _pageSize = 10;
  Set<Object> _selected = <Object>{};
  bool _striped = false;
  bool _loading = false;

  /// Simulasi pengambilan data dari server.
  Future<void> _reload(VoidCallback change) async {
    setState(() {
      change();
      _loading = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _loading = false);
  }

  List<_Application> get _filtered {
    final String q = _query.toLowerCase();
    final List<_Application> list = _all
        .where((_Application p) => q.isEmpty || p.name.toLowerCase().contains(q) || p.service.toLowerCase().contains(q))
        .toList();
    final IddsTableSort? sort = _sort;
    if (sort != null) {
      int compare(_Application a, _Application b) => switch (sort.key) {
            'name' => a.name.compareTo(b.name),
            'date' => a.date.compareTo(b.date),
            _ => a.id.compareTo(b.id),
          };
      list.sort((a, b) => sort.ascending ? compare(a, b) : compare(b, a));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final List<_Application> filtered = _filtered;
    final int totalPages = (filtered.length / _pageSize).ceil().clamp(1, 9999);
    final int page = _page.clamp(1, totalPages);
    final List<_Application> rows = filtered.skip((page - 1) * _pageSize).take(_pageSize).toList();

    return GallerySection(
      title: 'Table',
      subtitle: 'Data diurutkan, dicari, dan dipotong per halaman oleh aplikasi; tabel hanya menampilkan. '
          'Di layar sempit tabel bisa digeser ke samping; kolom Aksi tetap menempel di kanan. '
          'Ketuk nama untuk mengeditnya langsung.',
      usage: 'Tabel tidak mengambil, mengurutkan, atau memotong data sendiri: berikan rows untuk halaman saat ini dan tanggapi onSortChanged, onSearch, dan onPageChanged (misalnya dengan memanggil API). Kolom dengan editor bisa diedit langsung di sel.',
      code: _tableCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            IddsToggle(value: _striped, onChanged: (bool v) => setState(() => _striped = v), semanticLabel: 'Belang'),
            const Text('Belang'),
            if (_selected.isNotEmpty) GalleryCaption('${_selected.length} baris dipilih'),
          ],
        ),
        const SizedBox(height: IddsSpacing.s12),
        IddsTable<_Application>(
          rows: rows,
          rowKey: (_Application p) => p.id,
          stickyLastColumn: true,
          striped: _striped,
          loading: _loading,
          showSearch: true,
          searchPlaceholder: 'Cari nama atau layanan',
          onSearch: (String q) => _reload(() {
            _query = q;
            _page = 1;
          }),
          sort: _sort,
          onSortChanged: (IddsTableSort s) => _reload(() => _sort = s),
          selectedKeys: _selected,
          onSelectionChanged: (Set<Object> s) => setState(() => _selected = s),
          onRowTap: (_Application p) => showGallerySnack(context, 'Membuka permohonan #${p.id}'),
          page: page,
          totalPages: totalPages,
          onPageChanged: (int p) => _reload(() => _page = p),
          pageSize: _pageSize,
          onPageSizeChanged: (int s) => _reload(() {
            _pageSize = s;
            _page = 1;
          }),
          columns: <IddsTableColumn<_Application>>[
            IddsTableColumn<_Application>(
              header: 'No',
              width: 56,
              cell: (BuildContext c, _Application p) => Text('${p.id}'),
            ),
            IddsTableColumn<_Application>(
              header: 'Nama',
              sortKey: 'name',
              cell: (BuildContext c, _Application p) => Text(p.name),
              // Ketuk nama untuk mengedit langsung (kecuali yang sudah selesai).
              editor: IddsTableCellEditor<_Application>(
                value: (_Application p) => p.name,
                enabled: (_Application p) => p.status != 'Selesai',
                validator: (String v) => v.trim().length < 3 ? 'Minimal 3 huruf' : null,
                onSubmitted: (_Application p, String v) => setState(() => p.name = v.trim()),
              ),
            ),
            IddsTableColumn<_Application>(header: 'Layanan', cell: (BuildContext c, _Application p) => Text(p.service)),
            IddsTableColumn<_Application>(
              header: 'Tanggal',
              sortKey: 'date',
              cell: (BuildContext c, _Application p) => Text(iddsFormatDate(p.date, 'd MMM yyyy')),
            ),
            IddsTableColumn<_Application>(
              header: 'Status',
              cell: (BuildContext c, _Application p) => IddsBadge(
                variant: switch (p.status) {
                  'Selesai' => IddsBadgeVariant.success,
                  'Ditolak' => IddsBadgeVariant.error,
                  _ => IddsBadgeVariant.warning,
                },
                child: Text(p.status),
              ),
            ),
            IddsTableColumn<_Application>(
              header: 'Aksi',
              cell: (BuildContext c, _Application p) => IddsButton(
                size: IddsButtonSize.sm,
                hierarchy: IddsButtonHierarchy.secondary,
                onPressed: () => showGallerySnack(context, 'Mengunduh berkas #${p.id}'),
                child: const Text('Unduh'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const String _tableCode = r'''
IddsTable<Employee>(
  rows: currentPageRows,
  rowKey: (Employee p) => p.id,
  stickyLastColumn: true, // kolom Aksi tetap terlihat saat digeser
  showSearch: true,
  onSearch: (String q) => loadData(search: q),
  sort: _sort,
  onSortChanged: (IddsTableSort s) => loadData(sort: s),
  selectedKeys: _selected,
  onSelectionChanged: (Set<Object> v) => setState(() => _selected = v),
  page: _page,
  totalPages: _totalPages,
  onPageChanged: (int p) => loadData(page: p),
  columns: [
    IddsTableColumn(
      header: 'Nama',
      sortKey: 'name',
      cell: (BuildContext context, Employee p) => Text(p.name),
      editor: IddsTableCellEditor(
        value: (Employee p) => p.name,
        validator: (String v) => v.trim().isEmpty ? 'Nama wajib diisi' : null,
        onSubmitted: (Employee p, String v) => saveName(p, v),
      ),
    ),
    IddsTableColumn(header: 'Unit', cell: (BuildContext context, Employee p) => Text(p.unit)),
    IddsTableColumn(
      header: 'Aksi',
      cell: (BuildContext context, Employee p) => IddsButton(
        size: IddsButtonSize.sm,
        hierarchy: IddsButtonHierarchy.secondary,
        onPressed: () => open(p),
        child: const Text('Detail'),
      ),
    ),
  ],
)
''';
