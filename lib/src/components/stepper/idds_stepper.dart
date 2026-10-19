import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Satu langkah di [IddsStepper].
@immutable
class IddsStep {
  /// Membuat langkah.
  const IddsStep({required this.label, this.icon, this.enabled = true});

  /// Nama langkah.
  final String label;

  /// Ikon pengganti nomor langkah.
  final Widget? icon;

  /// Apakah langkah bisa ditekan.
  final bool enabled;
}

enum _StepStatus { completed, active, upcoming, error }

/// Penanda kemajuan proses bertahap.
///
/// Langkah sebelum [currentStep] ditandai selesai (centang hijau), langkah
/// [currentStep] aktif (biru), dan langkah dengan indeks di [errorSteps]
/// ditandai merah.
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
class IddsStepper extends StatelessWidget {
  /// Membuat stepper.
  const IddsStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.direction = Axis.horizontal,
    this.onStepTap,
    this.errorSteps = const <int>{},
  });

  /// Langkah-langkah.
  final List<IddsStep> steps;

  /// Indeks langkah aktif (mulai dari 0).
  final int currentStep;

  /// Horizontal (bawaan) atau vertikal.
  final Axis direction;

  /// Dipanggil dengan indeks langkah yang ditekan. Bila `null`, langkah
  /// tidak bisa ditekan.
  final ValueChanged<int>? onStepTap;

  /// Indeks langkah yang bermasalah.
  final Set<int> errorSteps;

  _StepStatus _status(int i) {
    if (errorSteps.contains(i)) return _StepStatus.error;
    if (i < currentStep) return _StepStatus.completed;
    if (i == currentStep) return _StepStatus.active;
    return _StepStatus.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final bool horizontal = direction == Axis.horizontal;

    Widget separator(int i) {
      final bool done = _status(i) == _StepStatus.completed;
      final Color color = done ? c.positive.shade600 : c.strokePrimary;
      return horizontal
          ? Expanded(
              child: Container(
                constraints: const BoxConstraints(minWidth: 40),
                height: 2,
                // Sejajar dengan tengah kotak 24px.
                margin: const EdgeInsets.only(top: 11),
                color: color,
              ),
            )
          : Padding(
              // Tengah garis tepat di tengah kotak 24px.
              padding: const EdgeInsets.only(left: 11),
              child: Container(width: 2, height: 72, color: color),
            );
    }

    final List<Widget> children = <Widget>[
      for (int i = 0; i < steps.length; i++) ...<Widget>[
        _StepItem(
          index: i,
          step: steps[i],
          status: _status(i),
          horizontal: horizontal,
          onTap: onStepTap != null && steps[i].enabled ? () => onStepTap!(i) : null,
        ),
        if (i < steps.length - 1) separator(i),
      ],
    ];

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: horizontal
          ? Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: children),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
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
    required this.onTap,
  });

  final int index;
  final IddsStep step;
  final _StepStatus status;
  final bool horizontal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final (Color border, Color foreground, Color background) = switch (status) {
      _StepStatus.active => (c.guide.shade500, c.guide.shade500, c.guide.shade50),
      _StepStatus.completed => (c.positive.shade600, c.positive.shade600, c.positive.shade50),
      _StepStatus.error => (c.negative.shade500, c.negative.shade500, c.negative.shade50),
      _StepStatus.upcoming => (c.strokePrimary, c.contentTertiary, c.backgroundSecondary),
    };
    final Color labelColor = status == _StepStatus.upcoming ? c.contentTertiary : c.contentPrimary;

    Widget content(bool hovered) {
      final Widget box = AnimatedContainer(
        duration: IddsDuration.base,
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(IddsRadius.lg),
          border: Border.all(color: hovered ? c.guide.shade500 : border),
        ),
        child: status == _StepStatus.completed
            ? IddsIcon(IddsIcons.check, size: 16, strokeWidth: 2.5, color: foreground)
            : IconTheme(
                data: IconThemeData(size: 16, color: foreground),
                child: DefaultTextStyle(
                  style: theme.textStyle(
                    fontSize: IddsFontSize.base,
                    lineHeight: 16,
                    fontWeight: IddsFontWeight.medium,
                    color: foreground,
                  ),
                  child: step.icon ?? Text('${index + 1}'),
                ),
              ),
      );
      final Widget label = Text(
        step.label,
        maxLines: 1,
        softWrap: false,
        style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: labelColor),
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
                    child: OverflowBox(maxWidth: double.infinity, child: label),
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
                    Padding(padding: const EdgeInsets.only(top: 4), child: label),
                  ],
                ),
              ),
      );
    }

    final String statusText = switch (status) {
      _StepStatus.completed => 'selesai',
      _StepStatus.active => 'aktif',
      _StepStatus.error => 'bermasalah',
      _StepStatus.upcoming => 'belum',
    };

    return Semantics(
      label: 'Langkah ${index + 1}: ${step.label}, $statusText',
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: onTap == null
          ? content(false)
          : IddsInteractive(
              onTap: onTap,
              builder: (BuildContext context, IddsInteractionState state) => content(state.hovered),
            ),
    );
  }
}
