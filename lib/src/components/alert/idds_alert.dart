import 'package:flutter/widgets.dart';

import '../../foundation/idds_color_scale.dart';
import '../../foundation/idds_hit_area.dart';
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
    this.action,
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

  /// Langkah lanjutan dari pesan ini (mis. `IddsButton` "Coba lagi"),
  /// ditaruh di bawah [message]. Tidak ada di IDDS React; ditambahkan karena
  /// alert galat di aplikasi (terutama mobile) hampir selalu butuh aksi.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool compact = iddsIsCompact(context, IddsBreakpoint.sm);
    final _AlertStyle style = _AlertStyle.of(variant, c, isDark: theme.isDark);

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
              child: IconTheme(
                  data: IconThemeData(size: 16, color: style.accent),
                  child: title!),
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
          if (action != null)
            Padding(
              padding: EdgeInsets.only(
                  top: title == null && message == null ? 0 : IddsSpacing.s12),
              child: action!,
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
            ? const EdgeInsets.symmetric(
                vertical: IddsSpacing.s8, horizontal: IddsSpacing.s12)
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
              _DismissButton(
                  onPressed: onDismiss!,
                  label: dismissLabel,
                  color: style.text),
            ],
          ],
        ),
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton(
      {required this.onPressed, required this.label, required this.color});

  final VoidCallback onPressed;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    // container: tombol tutup jadi node aksesibilitas sendiri, tidak
    // tergabung dengan judul alert.
    // Ikon 14px seperti CSS, area tekan 48dp untuk layar sentuh. Paling luar:
    // induk seukuran ikon (mis. Semantics) akan menolak sentuhan di luarnya.
    return IddsHitArea(
      child: Semantics(
        container: true,
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
                    ? <BoxShadow>[
                        BoxShadow(color: c.guide.shade500, spreadRadius: 2)
                      ]
                    : null,
              ),
              child: IddsIcon(IddsIcons.x,
                  size: 14, color: color, strokeWidth: state.hovered ? 2.5 : 2),
            );
          },
        ),
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

  factory _AlertStyle.of(IddsAlertVariant variant, IddsColors c,
      {required bool isDark}) {
    final _AlertStyle light = _AlertStyle._light(variant, c);
    if (!isDark || variant == IddsAlertVariant.neutral) return light;
    // Dark mode: skala warna status IDDS sama di kedua mode, sehingga latar
    // `*-100` tetap terang dan menyilaukan di layar gelap. Dipakai latar
    // gelap bernuansa (warna 500 ±16% di atas background-primary), judul/ikon
    // skala 300 dan teks content-primary agar kontras ≥ 4,5:1. Garis tepi
    // tetap seperti mode terang.
    final IddsPalette palette = switch (variant) {
      IddsAlertVariant.info => c.guide,
      IddsAlertVariant.success => c.positive,
      IddsAlertVariant.caution => c.warning,
      _ => c.negative,
    };
    return _AlertStyle(
      background: Color.alphaBlend(
          palette.shade500.withValues(alpha: 0.16), c.backgroundPrimary),
      border: light.border,
      accent: palette.shade300,
      text: c.contentPrimary,
      icon: light.icon,
    );
  }

  /// Gaya mode terang (dan neutral di kedua mode), sesuai CSS IDDS.
  factory _AlertStyle._light(IddsAlertVariant variant, IddsColors c) {
    // Latar varian berwarna di CSS tidak berubah di dark mode; teks memakai
    // warna gelap tetap (CSS: content-primary). Dark mode memakai gaya lain
    // di [_AlertStyle.of].
    final Color onLight = IddsPrimitives.neutral.shade800;
    return switch (variant) {
      IddsAlertVariant.neutral => _AlertStyle(
          background: c.backgroundPrimary,
          border: c.strokeTertiary,
          accent: c.contentPrimary,
          text: c.contentPrimary,
          icon: IddsIcons.box,
        ),
      // Judul & ikon 600 (CSS 500: kontras ±4,35:1 di atas guide-100).
      IddsAlertVariant.info => _AlertStyle(
          background: c.guide.shade100,
          border: c.guide.shade500,
          accent: c.guide.shade600,
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
      // Judul & ikon 600 (CSS 500: kontras ±3,6:1 di atas negative-100).
      IddsAlertVariant.critical => _AlertStyle(
          background: c.negative.shade100,
          border: c.negative.shade500,
          accent: c.negative.shade600,
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
