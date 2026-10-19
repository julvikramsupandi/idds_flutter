import 'package:flutter/widgets.dart';

import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Varian [IddsCard].
enum IddsCardVariant {
  /// Media di atas/bawah isi (bawaan).
  basic,

  /// Media di kiri/kanan isi; di layar < 640px media pindah ke atas.
  horizontal,

  /// Media sebagai latar dengan teks putih di atasnya.
  overlay,
}

/// Posisi media di [IddsCard].
enum IddsCardMediaPosition {
  /// Atas.
  top,

  /// Bawah.
  bottom,

  /// Kiri (varian horizontal).
  left,

  /// Kanan (varian horizontal).
  right,
}

/// Kartu konten IDDS dengan media, avatar, judul, keterangan, isi bebas,
/// dan tombol.
///
/// ```dart
/// IddsCard(
///   media: Image.network(url, fit: BoxFit.cover),
///   title: const Text('Beasiswa Pendidikan 2026'),
///   description: const Text('Pendaftaran dibuka hingga 30 November.'),
///   action: IddsButton(onPressed: _register, child: const Text('Daftar')),
/// )
/// ```
class IddsCard extends StatelessWidget {
  /// Membuat kartu.
  const IddsCard({
    super.key,
    this.variant = IddsCardVariant.basic,
    this.mediaPosition,
    this.media,
    this.avatar,
    this.title,
    this.description,
    this.child,
    this.action,
    this.onTap,
    this.descriptionMaxLines = 2,
    this.semanticLabel,
  });

  /// Varian.
  final IddsCardVariant variant;

  /// Posisi media. Bawaan: bawah (basic), kanan (horizontal), atas (overlay).
  final IddsCardMediaPosition? mediaPosition;

  /// Gambar atau video, biasanya `Image(fit: BoxFit.cover)`.
  final Widget? media;

  /// Avatar di atas judul, misalnya [IddsAvatar].
  final Widget? avatar;

  /// Judul, biasanya [Text]; bisa berisi ikon atau badge. Teks mendapat
  /// gaya judul kartu.
  final Widget? title;

  /// Keterangan, biasanya [Text]. Teks dipotong setelah
  /// [descriptionMaxLines] baris.
  final Widget? description;

  /// Isi tambahan di bawah keterangan.
  final Widget? child;

  /// Tombol di bagian bawah isi.
  final Widget? action;

  /// Bila diisi, seluruh kartu bisa ditekan dan menampilkan efek sorot.
  final VoidCallback? onTap;

  /// Batas baris keterangan.
  final int descriptionMaxLines;

  /// Label pembaca layar untuk kartu yang bisa ditekan. Bila kosong,
  /// pembaca layar membacakan isi kartu.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final double screen = iddsScreenWidth(context);
    final bool small = screen < IddsBreakpoint.sm;
    final bool medium = screen < IddsBreakpoint.lg;
    final IddsCardMediaPosition position = mediaPosition ??
        switch (variant) {
          IddsCardVariant.basic => IddsCardMediaPosition.bottom,
          IddsCardVariant.horizontal => IddsCardMediaPosition.right,
          IddsCardVariant.overlay => IddsCardMediaPosition.top,
        };
    final bool overlay = variant == IddsCardVariant.overlay;
    final Color titleColor = overlay ? c.baseWhite : c.contentPrimary;
    final Color descColor = overlay ? c.baseWhite : c.contentSecondary;

    // Ukuran teks: < 640px, < 1024px, lalu ukuran penuh.
    final (double titleSize, double titleLine, double descSize, double descLine, double avatarSize) = small
        ? (IddsFontSize.base, IddsLineHeight.sm, IddsFontSize.xs, IddsLineHeight.xs, 36.0)
        : medium
            ? (IddsFontSize.lg, IddsLineHeight.base, IddsFontSize.sm, IddsLineHeight.sm, 40.0)
            : (IddsFontSize.xl, IddsLineHeight.lg, IddsFontSize.base, IddsLineHeight.base, 48.0);
    final double padding = small ? IddsSpacing.s12 : (overlay && medium ? IddsSpacing.s16 : IddsSpacing.s24);
    final double gap = small ? IddsSpacing.s8 : (medium ? IddsSpacing.s12 : IddsSpacing.s16);

    final Widget content = Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: overlay && position == IddsCardMediaPosition.top ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: gap,
        children: <Widget>[
          if (avatar != null)
            SizedBox(width: avatarSize, height: avatarSize, child: ClipOval(child: FittedBox(child: avatar))),
          if (title != null || description != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: IddsSpacing.s4),
                    child: Semantics(
                      header: true,
                      child: DefaultTextStyle(
                        style: theme.textStyle(
                          fontSize: titleSize,
                          lineHeight: titleLine,
                          fontWeight: IddsFontWeight.semibold,
                          color: titleColor,
                        ),
                        child: IconTheme(data: IconThemeData(size: titleLine - 4, color: titleColor), child: title!),
                      ),
                    ),
                  ),
                if (description != null)
                  DefaultTextStyle(
                    maxLines: descriptionMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textStyle(fontSize: descSize, lineHeight: descLine, color: descColor),
                    child: description!,
                  ),
              ],
            ),
          if (child != null) child!,
          if (action != null) action!,
        ],
      ),
    );

    Widget body;
    switch (variant) {
      case IddsCardVariant.basic:
        final Widget? mediaBox = media == null
            ? null
            : ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 202),
                child: AspectRatio(aspectRatio: 16 / 9, child: SizedBox.expand(child: media)),
              );
        body = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (mediaBox != null && position == IddsCardMediaPosition.top) mediaBox,
            content,
            if (mediaBox != null && position != IddsCardMediaPosition.top) mediaBox,
          ],
        );
      case IddsCardVariant.horizontal:
        if (small || media == null) {
          body = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (media != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 202),
                  child: AspectRatio(aspectRatio: 16 / 9, child: SizedBox.expand(child: media)),
                ),
              content,
            ],
          );
        } else {
          final Widget mediaBox = SizedBox(width: 264, child: AspectRatio(aspectRatio: 5 / 4, child: SizedBox.expand(child: media)));
          body = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (position == IddsCardMediaPosition.left) mediaBox,
              Expanded(child: content),
              if (position != IddsCardMediaPosition.left) mediaBox,
            ],
          );
        }
        body = ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: body);
      case IddsCardVariant.overlay:
        final bool top = position != IddsCardMediaPosition.bottom;
        final double minHeight = small ? 300 : 362;
        body = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: small ? double.infinity : 360),
          child: Stack(
            children: <Widget>[
              if (media != null) Positioned.fill(child: media!),
              // CSS: gradasi gelap setinggi 60% kartu di sisi teks.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: top ? Alignment.bottomCenter : Alignment.topCenter,
                      end: top ? Alignment.topCenter : Alignment.bottomCenter,
                      colors: const <Color>[Color(0xB3000000), Color(0xE6000000), Color(0x00000000)],
                      stops: const <double>[0, 0.36, 0.6],
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Align(alignment: top ? Alignment.bottomLeft : Alignment.topLeft, child: content),
              ),
            ],
          ),
        );
    }

    final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);
    Widget card(bool hovered) => AnimatedContainer(
          duration: IddsDuration.base,
          decoration: BoxDecoration(
            color: c.backgroundPrimary,
            borderRadius: radius,
            border: Border.all(color: hovered ? c.strokeSecondary : c.strokePrimary),
            boxShadow: hovered ? IddsShadow.md : const <BoxShadow>[],
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(IddsRadius.lg - 1), child: body),
        );

    if (onTap == null) return Semantics(container: true, child: card(false));
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onTap,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) => IddsInsetRing(
          visible: state.focused,
          borderRadius: radius,
          rings: <(double, Color)>[(2.0, c.contentPrimary)],
          child: card(state.hovered || state.pressed),
        ),
      ),
    );
  }
}

/// Wadah polos bergaris tepi dengan padding yang membesar mengikuti layar
/// (Card Plain IDDS): 12px, 16px (≥ 640px), 20px (≥ 1024px), 24px
/// (≥ 1280px).
class IddsCardPlain extends StatelessWidget {
  /// Membuat kartu polos.
  const IddsCardPlain({super.key, required this.child, this.padding});

  /// Isi.
  final Widget child;

  /// Padding tetap; bawaan mengikuti lebar layar.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    final double screen = iddsScreenWidth(context);
    final double p = screen >= IddsBreakpoint.xl
        ? IddsSpacing.s24
        : screen >= IddsBreakpoint.lg
            ? IddsSpacing.s20
            : screen >= IddsBreakpoint.sm
                ? IddsSpacing.s16
                : IddsSpacing.s12;
    return Container(
      padding: padding ?? EdgeInsets.all(p - 1),
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(IddsRadius.lg),
        border: Border.all(color: c.strokePrimary),
      ),
      child: child,
    );
  }
}
