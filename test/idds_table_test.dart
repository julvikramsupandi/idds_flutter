import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'test_app.dart';

class _Row {
  const _Row(this.id, this.name, this.unit);
  final int id;
  final String name;
  final String unit;
}

const List<_Row> _data = <_Row>[
  _Row(1, 'Andi', 'Diskominfotik'),
  _Row(2, 'Budi', 'Bapenda'),
  _Row(3, 'Citra', 'Bappeda'),
];

List<IddsTableColumn<_Row>> _columns = <IddsTableColumn<_Row>>[
  IddsTableColumn<_Row>(header: 'Nama', sortKey: 'name', cell: (BuildContext c, _Row r) => Text(r.name)),
  IddsTableColumn<_Row>(header: 'Unit', cell: (BuildContext c, _Row r) => Text(r.unit)),
];

void main() {
  testWidgets('menampilkan judul dan baris, ketukan baris', (WidgetTester tester) async {
    _Row? tapped;
    await tester.pumpWidget(testApp(SizedBox(
      width: 600,
      child: IddsTable<_Row>(columns: _columns, rows: _data, onRowTap: (_Row r) => tapped = r),
    )));
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Bapenda'), findsOneWidget);
    await tester.tap(find.text('Bapenda'));
    expect(tapped?.id, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('urutan: naik lalu turun', (WidgetTester tester) async {
    IddsTableSort? sort;
    Widget build() => testApp(SizedBox(
          width: 600,
          child: IddsTable<_Row>(columns: _columns, rows: _data, sort: sort, onSortChanged: (IddsTableSort s) => sort = s),
        ));
    await tester.pumpWidget(build());
    await tester.tap(find.text('Nama'));
    expect(sort, const IddsTableSort('name'));
    await tester.pumpWidget(build());
    await tester.tap(find.text('Nama'));
    expect(sort, const IddsTableSort('name', ascending: false));
    // Kolom tanpa sortKey tidak bisa diurutkan.
    await tester.tap(find.text('Unit'));
    expect(sort?.key, 'name');
  });

  testWidgets('pilih baris dan pilih semua', (WidgetTester tester) async {
    Set<Object> selected = <Object>{};
    Widget build() => testApp(SizedBox(
          width: 600,
          child: IddsTable<_Row>(
            columns: _columns,
            rows: _data,
            rowKey: (_Row r) => r.id,
            selectedKeys: selected,
            onSelectionChanged: (Set<Object> s) => selected = s,
          ),
        ));
    await tester.pumpWidget(build());
    expect(find.byType(IddsCheckbox), findsNWidgets(4));
    await tester.tap(find.byType(IddsCheckbox).at(2));
    expect(selected, <Object>{2});
    await tester.pumpWidget(build());
    await tester.tap(find.byType(IddsCheckbox).first);
    expect(selected, <Object>{1, 2, 3});
    await tester.pumpWidget(build());
    await tester.tap(find.byType(IddsCheckbox).first);
    expect(selected, isEmpty);
  });

  testWidgets('kosong, pencarian, dan pagination', (WidgetTester tester) async {
    String? query;
    int? page;
    await tester.pumpWidget(testApp(SizedBox(
      width: 700,
      child: IddsTable<_Row>(
        columns: _columns,
        rows: const <_Row>[],
        showSearch: true,
        onSearch: (String q) => query = q,
        page: 1,
        totalPages: 3,
        onPageChanged: (int p) => page = p,
      ),
    )));
    expect(find.text('Data tidak ditemukan'), findsOneWidget);
    await tester.enterText(find.byType(EditableText).first, 'andi');
    await tester.tap(find.text('Cari'));
    expect(query, 'andi');
    await tester.tap(find.text('2'));
    expect(page, 2);
  });

  testWidgets('tabel lebar bisa digeser tanpa overflow', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(SizedBox(
      width: 300,
      child: IddsTable<_Row>(
        columns: <IddsTableColumn<_Row>>[
          for (int i = 0; i < 6; i++)
            IddsTableColumn<_Row>(header: 'Kolom panjang $i', cell: (BuildContext c, _Row r) => Text('${r.name} $i')),
        ],
        rows: _data,
      ),
    )));
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('edit sel: ketuk, validasi, Enter menyimpan', (WidgetTester tester) async {
    final Map<int, String> names = <int, String>{1: 'Andi', 2: 'Budi', 3: 'Citra'};
    _Row? tapped;
    Widget build() => testApp(SizedBox(
          width: 600,
          child: IddsTable<_Row>(
            rows: _data,
            onRowTap: (_Row r) => tapped = r,
            columns: <IddsTableColumn<_Row>>[
              IddsTableColumn<_Row>(
                header: 'Nama',
                cell: (BuildContext c, _Row r) => Text(names[r.id]!),
                editor: IddsTableCellEditor<_Row>(
                  value: (_Row r) => names[r.id]!,
                  enabled: (_Row r) => r.id != 3,
                  validator: (String v) => v.trim().isEmpty ? 'Nama wajib diisi' : null,
                  onSubmitted: (_Row r, String v) => names[r.id] = v,
                ),
              ),
              IddsTableColumn<_Row>(header: 'Unit', cell: (BuildContext c, _Row r) => Text(r.unit)),
            ],
          ),
        ));
    await tester.pumpWidget(build());
    await tester.tap(find.text('Budi'));
    await tester.pump();
    // Mengetuk sel yang bisa diedit tidak memicu ketukan baris.
    expect(tapped, isNull);
    expect(find.byType(IddsTableFieldInput), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(find.text('Nama wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Bambang');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpWidget(build());
    expect(names[2], 'Bambang');
    expect(find.byType(IddsTableFieldInput), findsNothing);
    expect(find.text('Bambang'), findsOneWidget);

    // Baris yang dinonaktifkan tidak bisa diedit; ketukan menjadi ketukan baris.
    await tester.tap(find.text('Citra'));
    await tester.pump();
    expect(find.byType(IddsTableFieldInput), findsNothing);
    expect(tapped?.id, 3);
  });

  testWidgets('edit sel: Esc dan tombol batal tidak menyimpan', (WidgetTester tester) async {
    String name = 'Andi';
    await tester.pumpWidget(testApp(SizedBox(
      width: 600,
      child: IddsTable<_Row>(
        rows: const <_Row>[_Row(1, 'Andi', 'X')],
        columns: <IddsTableColumn<_Row>>[
          IddsTableColumn<_Row>(
            header: 'Nama',
            cell: (BuildContext c, _Row r) => Text(name),
            editor: IddsTableCellEditor<_Row>(value: (_Row r) => name, onSubmitted: (_Row r, String v) => name = v),
          ),
        ],
      ),
    )));
    await tester.tap(find.text('Andi'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Ani');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.byType(IddsTableFieldInput), findsNothing);
    expect(name, 'Andi');

    await tester.tap(find.text('Andi'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'Ani');
    await tester.tap(find.byWidgetPredicate((Widget w) => w is IddsIcon && w.icon == IddsIcons.x));
    await tester.pump();
    expect(find.byType(IddsTableFieldInput), findsNothing);
    expect(name, 'Andi');
  });

  testWidgets('kolom terakhir menempel saat tabel digeser', (WidgetTester tester) async {
    await tester.pumpWidget(testApp(SizedBox(
      width: 300,
      child: IddsTable<_Row>(
        rows: _data,
        stickyLastColumn: true,
        columns: <IddsTableColumn<_Row>>[
          IddsTableColumn<_Row>(header: 'Nama', width: 200, cell: (BuildContext c, _Row r) => Text(r.name)),
          IddsTableColumn<_Row>(header: 'Unit', width: 200, cell: (BuildContext c, _Row r) => Text(r.unit)),
          IddsTableColumn<_Row>(header: 'Aksi', cell: (BuildContext c, _Row r) => const Text('Ubah')),
        ],
      ),
    )));
    await tester.pumpAndSettle();
    final Rect table = tester.getRect(find.byType(IddsTable<_Row>));
    // Lebar total > 300, tetapi judul "Aksi" tetap di dalam layar.
    final Rect actionHeader = tester.getRect(find.text('Aksi'));
    expect(actionHeader.right, lessThanOrEqualTo(table.right));
    expect(tester.takeException(), isNull);

    // Setelah digeser penuh ke kanan, posisinya tetap.
    await tester.drag(find.text('Bapenda'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Aksi')).right, lessThanOrEqualTo(table.right));
    expect(find.text('Ubah'), findsNWidgets(3));
  });
}
