import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Status satu langkah di [IddsStepper].
enum IddsStepStatus {
  /// Sudah selesai: centang hijau.
  completed,

  /// Sedang berjalan: warna utama brand.
  active,

  /// Belum dimulai: abu-abu.
  upcoming,

  /// Bermasalah: merah.
  error,
}

/// Satu langkah di [IddsStepper].
@immutable
class IddsStep {
  /// Membuat langkah.
  const IddsStep({
    this.label = '',
    this.icon,
    this.enabled = true,
    this.status,
    this.highlighted = false,
  });

  /// Nama langkah. Boleh kosong pada [IddsStepper.dense].
  final String label;

  /// Ikon pengganti nomor langkah.
  final Widget? icon;

  /// Apakah langkah bisa ditekan.
  final bool enabled;

  /// Status langkah ini. `null` = dihitung dari [IddsStepper.currentStep].
  /// Isi bila alurnya tidak lurus, mis. tahap 2 masih berjalan sementara
  /// tahap Anda (tahap 3) belum.
  final IddsStepStatus? status;

  /// Ditandai cincin luar, mis. "tahap Anda" di antara tahap orang lain.
  final bool highlighted;
}

/// Penanda kemajuan proses bertahap.
///
/// Langkah sebelum [currentStep] ditandai selesai (centang hijau), langkah
/// [currentStep] aktif (warna utama brand), dan langkah dengan indeks di
/// [errorSteps] ditandai merah. Status per langkah bisa ditentukan sendiri
/// lewat [IddsStep.status].
///
/// ```dart
/// IddsStepper(
///   currentStep: 1,
///   steps: const [
///     IddsStep(label: 'Data diri'),
///     IddsStep(label: 'Dokumen'),
///     IddsStep(label: 'Konfirmasi'),
///   ],
/// )
/// ```
///
/// Di kartu atau daftar, pakai [dense] (tanpa label, jarak rapat) dan
/// [maxVisible] agar langkah yang banyak diringkas menjadi "…":
///
/// ```dart
/// IddsStepper(
///   dense: true,
///   maxVisible: 7,
///   semanticLabel: 'Tahap 3 dari 9, giliran Anda',
///   steps: [
///     for (final step in steps)
///       IddsStep(status: step.status, highlighted: step.isMine),
///   ],
/// )
/// ```
class IddsStepper extends StatelessWidget {
  /// Membuat stepper.
  const IddsStepper({
    super.key,
    required this.steps,
    this.currentStep = 0,
    this.direction = Axis.horizontal,
    this.onStepTap,
    this.errorSteps = const <int>{},
    this.dense = false,
    this.maxVisible,
    this.semanticLabel,
  }) : assert(maxVisible == null || maxVisible >= 5);

  /// Langkah-langkah.
  final List<IddsStep> steps;

  /// Indeks langkah aktif (mulai dari 0). Diabaikan untuk langkah yang
  /// [IddsStep.status]-nya diisi.
  final int currentStep;

  /// Horizontal (bawaan) atau vertikal.
  final Axis direction;

  /// Dipanggil dengan indeks langkah yang ditekan. Bila `null`, langkah
  /// tidak bisa ditekan.
  final ValueChanged<int>? onStepTap;

  /// Indeks langkah yang bermasalah.
  final Set<int> errorSteps;

  /// Mode ringkas untuk kartu dan daftar (hanya horizontal): label tidak
  /// ditampilkan, garis minimal 8px (bukan 40px), tanpa padding tepi dan
  /// tinggi minimal 80px. Tinggi = kotak 24px (32px dengan cincin
  /// [IddsStep.highlighted]).
  final bool dense;

  /// Jumlah langkah terbanyak yang digambar (minimal 5). Bila lebih, langkah
  /// pertama, terakhir, dan di sekitar langkah ditandai/aktif tetap tampil;
  /// sisanya diganti "…". `null` = semua langkah.
  final int? maxVisible;

  /// Label pembaca layar untuk seluruh stepper. Bila diisi, langkah tidak
  /// dibacakan satu per satu (cocok di kartu daftar yang ramai).
  final String? semanticLabel;

  IddsStepStatus _status(int i) {
    final IddsStepStatus? explicit = steps[i].status;
    if (explicit != null) return explicit;
    if (errorSteps.contains(i)) return IddsStepStatus.error;
    if (i < currentStep) return IddsStepStatus.completed;
    if (i == currentStep) return IddsStepStatus.active;
    return IddsStepStatus.upcoming;
  }

  /// Indeks langkah yang digambar; `null` = "…".
  @visibleForTesting
  static List<int?> visibleIndexes(int count, int focus, int? maxVisible) {
    if (maxVisible == null || count <= maxVisible) {
      return <int>[for (int i = 0; i < count; i++) i];
    }
    // Pertama + terakhir + dua "…" memakan 4 tempat; sisanya jendela di
    // sekitar langkah fokus. Bila jendela menempel ujung, satu "…" hilang
    // dan jendela melebar satu.
    final int window = maxVisible - 4;
    int start = focus - (window - 1) ~/ 2;
    int end = start + window - 1;
    if (start <= 2) {
      start = 1;
      end = maxVisible - 3;
    } else if (end >= count - 3) {
      end = count - 2;
      start = count - maxVisible + 2;
    }
    return <int?>[
      0,
      if (start > 1) null,
      for (int i = start; i <= end; i++) i,
      if (end < count - 2) null,
      count - 1,
    ];
  }

  /// Langkah yang wajib tampil saat diringkas: yang ditandai, lalu yang
  /// aktif, lalu [currentStep].
  int get _focus {
    final int highlighted = steps.indexWhere((IddsStep s) => s.highlighted);
    if (highlighted >= 0) return highlighted;
    for (int i = 0; i < steps.length; i++) {
      if (_status(i) == IddsStepStatus.active) return i;
    }
    return currentStep.clamp(0, steps.isEmpty ? 0 : steps.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final bool horizontal = direction == Axis.horizontal;
    final bool isDense = dense && horizontal;
    final List<int?> visible = visibleIndexes(
      steps.length,
      _focus,
      maxVisible,
    );

    Widget separator(int? before) {
      final bool done =
          before != null && _status(before) == IddsStepStatus.completed;
      final Color color = done ? c.positive.shade600 : c.strokePrimary;
      return horizontal
          ? Expanded(
              child: Container(
                constraints: BoxConstraints(minWidth: isDense ? 8 : 40),
                height: 2,
                // Sejajar dengan tengah kotak 24px.
                margin: EdgeInsets.only(top: isDense ? 0 : 11),
                color: color,
              ),
            )
          : Padding(
              // Tengah garis tepat di tengah kotak 24px.
              padding: const EdgeInsets.only(left: 11),
              child: Container(width: 2, height: 72, color: color),
            );
    }

    final List<Widget> children = <Widget>[];
    for (int v = 0; v < visible.length; v++) {
      final int? i = visible[v];
      if (v > 0) children.add(separator(visible[v - 1]));
      children.add(
        i == null
            ? _Gap(horizontal: horizontal)
            : _StepItem(
                index: i,
                step: steps[i],
                status: _status(i),
                horizontal: horizontal,
                dense: isDense,
                onTap: onStepTap != null && steps[i].enabled
                    ? () => onStepTap!(i)
                    : null,
              ),
      );
    }

    // Mode ringkas tanpa `Container(alignment:)`: di induk longgar (kartu,
    // Column) alignment membuat stepper setinggi ruang yang tersedia.
    final Widget body = isDense
        ? Row(children: children)
        : horizontal
            ? Container(
                constraints: const BoxConstraints(minHeight: 80),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );

    final String? label = semanticLabel;
    if (label != null) {
      return Semantics(
        container: true,
        label: label,
        excludeSemantics: true,
        child: body,
      );
    }
    return Semantics(container: true, explicitChildNodes: true, child: body);
  }
}

/// Pengganti langkah yang diringkas.
class _Gap extends StatelessWidget {
  const _Gap({required this.horizontal});

  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: horizontal ? 16 : 24,
        height: 24,
        child: Center(
          child: Text(
            '…',
            style: theme.textStyle(
              fontSize: IddsFontSize.xs,
              lineHeight: 16,
              color: theme.colors.contentTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.index,
    required this.step,
    required this.status,
    required this.horizontal,
    required this.dense,
    required this.onTap,
  });

  final int index;
  final IddsStep step;
  final IddsStepStatus status;
  final bool horizontal;
  final bool dense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    // CSS IDDS memakai `guide` (biru) untuk langkah aktif; di sini warna
    // utama brand agar "posisi sekarang" tidak tertukar dengan warna
    // informasi (README "Penyesuaian dari IDDS").
    final (Color border, Color foreground) = switch (status) {
      IddsStepStatus.active => (c.primaryMain, c.primaryMain),
      IddsStepStatus.completed => (c.positive.shade600, c.positive.shade600),
      IddsStepStatus.error => (c.negative.shade500, c.negative.shade500),
      IddsStepStatus.upcoming => (c.strokePrimary, c.contentTertiary),
    };
    // Skala 50 tetap terang di dark mode; latar diganti nuansa warna di atas
    // `background-primary` (pola sama dengan IddsAlert).
    final Color background = switch (status) {
      IddsStepStatus.upcoming => c.backgroundSecondary,
      _ when theme.isDark => Color.alphaBlend(
          border.withValues(alpha: 0.16),
          c.backgroundPrimary,
        ),
      IddsStepStatus.active => c.primary.shade50,
      IddsStepStatus.completed => c.positive.shade50,
      IddsStepStatus.error => c.negative.shade50,
    };
    final Color labelColor = status == IddsStepStatus.upcoming
        ? c.contentTertiary
        : c.contentPrimary;

    Widget content(bool hovered) {
      Widget box = AnimatedContainer(
        duration: IddsDuration.base,
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(IddsRadius.lg),
          border: Border.all(color: hovered ? c.guide.shade500 : border),
        ),
        child: status == IddsStepStatus.completed
            ? IddsIcon(
                IddsIcons.check,
                size: 16,
                strokeWidth: 2.5,
                color: foreground,
              )
            : IconTheme(
                data: IconThemeData(size: 16, color: foreground),
                child: DefaultTextStyle(
                  style: theme.textStyle(
                    fontSize: dense ? IddsFontSize.xs : IddsFontSize.base,
                    lineHeight: 16,
                    fontWeight: IddsFontWeight.medium,
                    color: foreground,
                  ),
                  child: step.icon ?? Text('${index + 1}'),
                ),
              ),
      );
      if (step.highlighted) {
        // Cincin luar 2px dengan celah 2px (pola focus ring), sesudut
        // dengan kotak. Bukan `BoxShadow` tembus pandang: bayangan itu
        // menjadi blok pudar yang menutup ujung garis penghubung dan
        // warnanya tampak "bocor" keluar kotak.
        box = DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IddsRadius.lg + 4),
            border: Border.all(color: border, width: 2),
          ),
          child: Padding(padding: const EdgeInsets.all(4), child: box),
        );
      }
      if (dense) return Opacity(opacity: step.enabled ? 1 : 0.6, child: box);

      final Widget label = Text(
        step.label,
        maxLines: 1,
        softWrap: false,
        style: theme.textStyle(
          fontSize: IddsFontSize.xs,
          lineHeight: IddsLineHeight.xs,
          color: labelColor,
        ),
      );

      return Opacity(
        opacity: step.enabled ? 1 : 0.6,
        child: horizontal
            // CSS: label absolut 32px di bawah kotak, di tengah, dan tidak
            // ikut menentukan lebar langkah.
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  box,
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 24,
                    height: IddsLineHeight.xs,
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      child: label,
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: 24,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    box,
                    const SizedBox(width: IddsSpacing.s12),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: label,
                    ),
                  ],
                ),
              ),
      );
    }

    final String statusText = switch (status) {
      IddsStepStatus.completed => 'selesai',
      IddsStepStatus.active => 'aktif',
      IddsStepStatus.error => 'bermasalah',
      IddsStepStatus.upcoming => 'belum',
    };
    final String name = step.label.isEmpty ? '' : ': ${step.label}';

    return Semantics(
      label: 'Langkah ${index + 1}$name, $statusText',
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: onTap == null
          ? content(false)
          : IddsInteractive(
              onTap: onTap,
              builder: (BuildContext context, IddsInteractionState state) =>
                  content(state.hovered),
            ),
    );
  }
}
