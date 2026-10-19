import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Baris atau kolom [IddsChoiceGrid].
@immutable
class IddsChoiceGridItem {
  /// Membuat baris/kolom.
  const IddsChoiceGridItem({required this.id, required this.label});

  /// Pengenal unik.
  final String id;

  /// Teks.
  final String label;
}

/// Kisi pilihan ganda: satu pilihan (kolom) untuk setiap baris, seperti
/// pertanyaan skala pada survei (Multiple Choice Grid IDDS).
///
/// ```dart
/// IddsChoiceGrid(
///   columns: const [
///     IddsChoiceGridItem(id: '1', label: 'Kurang'),
///     IddsChoiceGridItem(id: '2', label: 'Cukup'),
///     IddsChoiceGridItem(id: '3', label: 'Baik'),
///   ],
///   rows: const [
///     IddsChoiceGridItem(id: 'kecepatan', label: 'Kecepatan layanan'),
///     IddsChoiceGridItem(id: 'keramahan', label: 'Keramahan petugas'),
///   ],
///   selected: _answers, // Map<rowId, columnId>
///   onChanged: (v) => setState(() => _answers = v),
/// )
/// ```
class IddsChoiceGrid extends StatelessWidget {
  /// Membuat kisi pilihan.
  const IddsChoiceGrid({
    super.key,
    required this.rows,
    required this.columns,
    required this.selected,
    required this.onChanged,
  });

  /// Pertanyaan (baris).
  final List<IddsChoiceGridItem> rows;

  /// Pilihan jawaban (kolom).
  final List<IddsChoiceGridItem> columns;

  /// Jawaban terpilih: id baris → id kolom.
  final Map<String, String> selected;

  /// Dipanggil dengan jawaban baru. `null` membuat kisi nonaktif.
  final ValueChanged<Map<String, String>>? onChanged;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double screen = iddsScreenWidth(context);
    // CSS: kolom label 200px / sel 120px; lebih kecil di layar sempit.
    final double labelWidth = screen < IddsBreakpoint.sm ? 120 : (screen < IddsBreakpoint.md ? 150 : 200);
    final double cellWidth = screen < IddsBreakpoint.sm ? 80 : (screen < IddsBreakpoint.md ? 100 : 120);
    final bool small = screen < IddsBreakpoint.md;
    final double fontSize = small ? IddsFontSize.xs : IddsFontSize.sm;
    final double lineHeight = small ? IddsLineHeight.xs : IddsLineHeight.sm;
    final BorderSide line = BorderSide(color: c.strokePrimary);
    final bool enabled = onChanged != null;

    void choose(String row, String column) {
      onChanged!(<String, String>{...selected, row: column});
    }

    Widget cell({required Widget child, required double width, required bool header, bool last = false, bool alignStart = false}) {
      return Container(
        width: width,
        constraints: BoxConstraints(minHeight: header ? 52 : 48),
        padding: EdgeInsets.symmetric(horizontal: IddsSpacing.s12, vertical: header ? IddsSpacing.s16 : IddsSpacing.s12),
        alignment: alignStart ? AlignmentDirectional.centerStart : Alignment.center,
        decoration: BoxDecoration(border: last ? null : Border(right: line)),
        child: child,
      );
    }

    final Widget grid = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(color: c.backgroundSecondary, border: Border(bottom: line)),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                cell(child: const SizedBox(), width: labelWidth, header: true),
                for (int i = 0; i < columns.length; i++)
                  cell(
                    width: cellWidth,
                    header: true,
                    last: i == columns.length - 1,
                    child: Text(
                      columns[i].label,
                      textAlign: TextAlign.center,
                      style: theme.textStyle(
                        fontSize: fontSize,
                        lineHeight: lineHeight,
                        fontWeight: IddsFontWeight.semibold,
                        color: c.contentPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        for (final IddsChoiceGridItem row in rows)
          Container(
            decoration: BoxDecoration(border: Border(bottom: line)),
            child: Semantics(
              container: true,
              label: row.label,
              explicitChildNodes: true,
              child: IntrinsicHeight(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    cell(
                      width: labelWidth,
                      header: false,
                      alignStart: true,
                      child: ExcludeSemantics(
                        child: Text(
                          row.label,
                          style: theme.textStyle(fontSize: fontSize, lineHeight: lineHeight, color: c.contentPrimary),
                        ),
                      ),
                    ),
                    for (int i = 0; i < columns.length; i++)
                      cell(
                        width: cellWidth,
                        header: false,
                        last: i == columns.length - 1,
                        child: _GridRadio(
                          label: columns[i].label,
                          checked: selected[row.id] == columns[i].id,
                          onTap: enabled ? () => choose(row.id, columns[i].id) : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IddsRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.strokePrimary),
            borderRadius: BorderRadius.circular(IddsRadius.lg),
          ),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: grid),
        ),
      ),
    );
  }
}

class _GridRadio extends StatelessWidget {
  const _GridRadio({required this.label, required this.checked, required this.onTap});

  final String label;
  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: checked,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: BorderRadius.circular(12),
          rings: <(double, Color)>[(2.0, c.primary.shade500)],
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedContainer(
              duration: IddsDuration.base,
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // CSS: terpilih primary-500 penuh dengan titik 6px warna latar.
                color: checked ? c.primary.shade500 : c.backgroundPrimary,
                border: Border.all(
                  color: checked
                      ? c.primary.shade500
                      : state.hovered
                          ? c.contentSecondary
                          : c.strokeSecondary,
                  width: 2,
                ),
              ),
              child: checked
                  ? Container(width: 6, height: 6, decoration: BoxDecoration(color: c.backgroundPrimary, shape: BoxShape.circle))
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
