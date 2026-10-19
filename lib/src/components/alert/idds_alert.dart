import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_primitives.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Varian [IddsAlert].
enum IddsAlertVariant {
  /// Putih dengan garis tepi gelap.
  neutral,

  /// Informasi (biru).
  info,

  /// Berhasil (hijau).
  success,

  /// Peringatan (kuning).
  caution,

  /// Galat atau kritis (merah).
  critical,
}

/// Pesan yang menonjol di dalam halaman.
///
/// ```dart
/// IddsAlert(
///   variant: IddsAlertVariant.success,
///   title: const Text('Data tersimpan'),
///   message: const Text('Perubahan sudah bisa dilihat publik.'),
///   onDismiss: () => setState(() => _visible = false),
/// )
/// ```
///
/// Alert bisa ditutup bila [onDismiss] diberikan. Menyembunyikan widget
/// setelah ditutup adalah tanggung jawab pemanggil.
class IddsAlert extends StatelessWidget {
  /// Membuat alert.
  const IddsAlert({
    super.key,
    this.variant = IddsAlertVariant.info,
    this.title,
    this.message,
    this.icon,
    this.showIcon = true,
    this.onDismiss,
    this.dismissLabel = 'Tutup peringatan',
  });

  /// Varian warna.
  final IddsAlertVariant variant;

  /// Judul singkat, biasanya satu baris [Text]. Ikon di dalamnya mengikuti
  /// warna judul.
  final Widget? title;

  /// Penjelasan di bawah judul, idealnya maksimal dua baris.
  final Widget? message;

  /// Ikon pengganti ikon bawaan varian.
  final Widget? icon;

  /// Tampilkan ikon.
  final bool showIcon;

  /// Dipanggil saat tombol tutup ditekan. Tombol tutup hanya muncul bila
  /// nilai ini tidak `null`.
  final VoidCallback? onDismiss;

  /// Label tombol tutup untuk pembaca layar.
  final String dismissLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool compact = iddsIsCompact(context, IddsBreakpoint.sm);
    final _AlertStyle style = _AlertStyle.of(variant, c);

    final Widget? leading = !showIcon
        ? null
        : IconTheme(
            data: IconThemeData(size: 20, color: style.accent),
            child: icon ?? IddsIcon(style.icon),
          );

    final Widget text = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null)
            DefaultTextStyle(
              style: theme.textStyle(
                fontSize: compact ? IddsFontSize.xs : IddsFontSize.sm,
                lineHeight: IddsLineHeight.sm,
                fontWeight: IddsFontWeight.semibold,
                color: style.accent,
              ),
              child: IconTheme(data: IconThemeData(size: 16, color: style.accent), child: title!),
            ),
          if (message != null)
            Padding(
              padding: EdgeInsets.only(top: title == null ? 0 : IddsSpacing.s4),
              child: DefaultTextStyle(
                style: theme.textStyle(
                  fontSize: compact ? IddsFontSize.xs2 : IddsFontSize.xs,
                  lineHeight: IddsLineHeight.xs,
                  color: style.text,
                ),
                child: message!,
              ),
            ),
        ],
      ),
    );

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: compact
            ? const EdgeInsets.symmetric(vertical: IddsSpacing.s8, horizontal: IddsSpacing.s12)
            : const EdgeInsets.all(IddsSpacing.s16),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(IddsRadius.lg),
          border: Border.all(color: style.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading,
              // CSS menambah margin-right 8px pada ikon di layar kecil.
              SizedBox(width: compact ? IddsSpacing.s16 : IddsSpacing.s8),
            ],
            text,
            if (onDismiss != null) ...<Widget>[
              const SizedBox(width: IddsSpacing.s8),
              _DismissButton(onPressed: onDismiss!, label: dismissLabel, color: style.text),
            ],
          ],
        ),
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.onPressed, required this.label, required this.color});

  final VoidCallback onPressed;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      child: IddsInteractive(
        onTap: onPressed,
        builder: (BuildContext context, IddsInteractionState state) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IddsRadius.sm),
              boxShadow: state.focused
                  ? <BoxShadow>[BoxShadow(color: c.guide.shade500, spreadRadius: 2)]
                  : null,
            ),
            child: IddsIcon(IddsIcons.x, size: 14, color: color, strokeWidth: state.hovered ? 2.5 : 2),
          );
        },
      ),
    );
  }
}

class _AlertStyle {
  const _AlertStyle({
    required this.background,
    required this.border,
    required this.accent,
    required this.text,
    required this.icon,
  });

  factory _AlertStyle.of(IddsAlertVariant variant, IddsColors c) {
    // Latar varian berwarna tidak berubah di dark mode, jadi teksnya memakai
    // warna gelap tetap (CSS: content-primary, yang menjadi putih di dark mode
    // dan tidak terbaca).
    final Color onLight = IddsPrimitives.neutral.shade800;
    return switch (variant) {
      IddsAlertVariant.neutral => _AlertStyle(
          background: c.backgroundPrimary,
          border: c.strokeTertiary,
          accent: c.contentPrimary,
          text: c.contentPrimary,
          icon: IddsIcons.box,
        ),
      IddsAlertVariant.info => _AlertStyle(
          background: c.guide.shade100,
          border: c.guide.shade500,
          accent: c.guide.shade500,
          text: onLight,
          icon: IddsIcons.infoCircle,
        ),
      IddsAlertVariant.success => _AlertStyle(
          background: c.positive.shade50,
          border: c.positive.shade600,
          accent: c.positive.shade600,
          text: onLight,
          icon: IddsIcons.check,
        ),
      // CSS memakai warning-500 untuk judul dan ikon (kontras ±1,6:1 di atas
      // warning-100). Dipakai warning-600 agar terbaca; garis tepi tetap 500.
      IddsAlertVariant.caution => _AlertStyle(
          background: c.warning.shade100,
          border: c.warning.shade500,
          accent: c.warning.shade600,
          text: onLight,
          icon: IddsIcons.alertTriangle,
        ),
      IddsAlertVariant.critical => _AlertStyle(
          background: c.negative.shade100,
          border: c.negative.shade500,
          accent: c.negative.shade500,
          text: onLight,
          icon: IddsIcons.alertCircle,
        ),
    };
  }

  final Color background;
  final Color border;
  final Color accent;
  final Color text;
  final IddsIconData icon;
}
