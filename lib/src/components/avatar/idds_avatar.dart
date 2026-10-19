import 'package:flutter/widgets.dart';

import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';

/// Ukuran [IddsAvatar] dalam pixel.
enum IddsAvatarSize {
  /// 16px.
  s16(16, 6),

  /// 24px.
  s24(24, 10),

  /// 32px (bawaan).
  s32(32, 10),

  /// 40px.
  s40(40, 12),

  /// 48px.
  s48(48, 12);

  const IddsAvatarSize(this.dimension, this.fontSize);

  /// Lebar dan tinggi.
  final double dimension;

  /// Ukuran font inisial.
  final double fontSize;
}

/// Bentuk [IddsAvatar].
enum IddsAvatarShape {
  /// Lingkaran (bawaan).
  circle,

  /// Persegi dengan sudut 8px.
  square,
}

/// Foto profil, atau inisial bila foto tidak ada atau gagal dimuat.
///
/// ```dart
/// IddsAvatar(image: NetworkImage(url), initials: 'JS')
/// ```
class IddsAvatar extends StatelessWidget {
  /// Membuat avatar.
  const IddsAvatar({
    super.key,
    this.image,
    this.initials,
    this.size = IddsAvatarSize.s32,
    this.shape = IddsAvatarShape.circle,
    this.semanticLabel,
  });

  /// Foto. Bila `null` atau gagal dimuat, [initials] ditampilkan.
  final ImageProvider? image;

  /// Inisial, maksimal 2 huruf (otomatis kapital).
  final String? initials;

  /// Ukuran.
  final IddsAvatarSize size;

  /// Bentuk.
  final IddsAvatarShape shape;

  /// Label untuk pembaca layar, misalnya nama orang.
  final String? semanticLabel;

  /// Inisial yang ditampilkan: dua karakter pertama, kapital.
  String get displayInitials {
    final String text = (initials ?? '').trim();
    return (text.length > 2 ? text.substring(0, 2) : text).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final BorderRadius radius = shape == IddsAvatarShape.circle
        ? BorderRadius.circular(size.dimension / 2)
        : BorderRadius.circular(IddsRadius.lg);

    final Widget initialsWidget = Center(
      child: Text(
        displayInitials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: theme.textStyle(
          fontSize: size.fontSize,
          lineHeight: size.fontSize * 1.2,
          fontWeight: IddsFontWeight.normal,
        ),
      ),
    );

    final Widget content = image == null
        ? initialsWidget
        : Image(
            image: image!,
            fit: BoxFit.cover,
            width: size.dimension,
            height: size.dimension,
            errorBuilder: (BuildContext context, Object error, StackTrace? stack) => initialsWidget,
          );

    return Semantics(
      label: semanticLabel ?? (image == null ? displayInitials : null),
      image: image != null,
      excludeSemantics: true,
      child: Container(
        width: size.dimension,
        height: size.dimension,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: theme.colors.backgroundSecondary, borderRadius: radius),
        // Garis tepi di atas foto agar tidak tertutup di bagian lengkung.
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: theme.colors.strokePrimary),
        ),
        child: content,
      ),
    );
  }
}
