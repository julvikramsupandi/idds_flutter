import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import '../../foundation/idds_icon.dart';
import '../../foundation/idds_interactive.dart';
import '../../foundation/idds_theme.dart';
import '../../foundation/idds_theme_data.dart';
import '../../tokens/idds_colors.g.dart';
import '../../tokens/idds_dimension_tokens.g.dart';
import '../../tokens/idds_typography_tokens.g.dart';
import '../dropdown/idds_dropdown_trigger.dart' show IddsFieldLabel;

/// Status satu berkas di [IddsFileUpload] / [IddsSingleFileUpload].
enum IddsFileStatus {
  /// Sudah dipilih, belum diunggah.
  idle,

  /// Sedang diunggah; [IddsUploadFile.progress] dipakai bila ada.
  uploading,

  /// Berhasil diunggah.
  success,

  /// Gagal; pesan di [IddsUploadFile.error].
  error,
}

/// Data tampilan satu berkas. Package ini tidak membaca berkas: aplikasi
/// memilih berkas (misalnya dengan package `file_picker`), mengunggahnya,
/// lalu memperbarui status di sini.
@immutable
class IddsUploadFile {
  /// Membuat data berkas.
  const IddsUploadFile({
    required this.name,
    required this.size,
    this.status = IddsFileStatus.idle,
    this.progress,
    this.error,
  });

  /// Nama berkas, misalnya `ktp.pdf`.
  final String name;

  /// Ukuran dalam byte.
  final int size;

  /// Status unggah.
  final IddsFileStatus status;

  /// Kemajuan unggah 0–1. `null` saat tidak diketahui.
  final double? progress;

  /// Pesan error, ditampilkan saat [status] error.
  final String? error;

  /// Salinan dengan perubahan.
  IddsUploadFile copyWith({String? name, int? size, IddsFileStatus? status, double? progress, String? error}) {
    return IddsUploadFile(
      name: name ?? this.name,
      size: size ?? this.size,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

/// Ukuran berkas yang mudah dibaca, sama seperti IDDS: `0 Bytes`, `512 Bytes`,
/// `1.5 KB`, `2.25 MB`.
String iddsFormatFileSize(int bytes) {
  if (bytes <= 0) return '0 Bytes';
  const List<String> units = <String>['Bytes', 'KB', 'MB', 'GB'];
  final int i = math.min(units.length - 1, (math.log(bytes) / math.log(1024)).floor());
  final double value = bytes / math.pow(1024, i);
  String text = value.toStringAsFixed(2);
  // Seperti parseFloat(toFixed(2)) di versi web: buang nol di belakang.
  if (text.contains('.')) text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  return '$text ${units[i]}';
}

/// Memeriksa berkas dengan aturan yang sama seperti versi web IDDS dan
/// mengembalikan pesan error berbahasa Indonesia, atau `null` bila valid.
///
/// [allowedExtensions] tanpa titik, misalnya `['pdf', 'png']`. [maxSize]
/// dalam byte.
String? iddsValidateFile({required String name, required int size, List<String>? allowedExtensions, int? maxSize}) {
  if (RegExp(r'''[<>"'/\\\x00-\x1F\x7F]''').hasMatch(name)) {
    return 'Nama file mengandung karakter yang tidak diizinkan';
  }
  if (allowedExtensions != null && allowedExtensions.isNotEmpty) {
    final int dot = name.lastIndexOf('.');
    final String ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
    final List<String> allowed = <String>[for (final String e in allowedExtensions) e.toLowerCase().replaceFirst('.', '')];
    if (!allowed.contains(ext)) return 'Ekstensi file harus: ${allowed.join(', ')}';
  }
  if (maxSize != null && maxSize > 0 && size > maxSize) {
    return 'Ukuran file maksimal ${(maxSize / 1048576).toStringAsFixed(2)} MB';
  }
  return null;
}

/// Area unggah berkas dengan daftar berkas (File Upload IDDS).
///
/// Widget ini hanya tampilan. Saat area atau tombol "Pilih File" ditekan,
/// [onPick] dipanggil; aplikasi membuka pemilih berkas sendiri, lalu
/// mengisi [files]. Untuk seret-dan-lepas di web/desktop, gunakan package
/// seperti `desktop_drop` dan isi [dragOver] selama berkas diseret di atas
/// area.
///
/// ```dart
/// IddsFileUpload(
///   label: const Text('Dokumen pendukung'),
///   description: 'PDF atau JPG, maksimal 2 MB',
///   files: _files,
///   onPick: _pickFiles,
///   onRemove: (i) => setState(() => _files.removeAt(i)),
/// )
/// ```
class IddsFileUpload extends StatefulWidget {
  /// Membuat area unggah.
  const IddsFileUpload({
    super.key,
    required this.files,
    required this.onPick,
    this.onRemove,
    this.onRetry,
    this.onCancel,
    this.label,
    this.required = false,
    this.title = 'Unggah File',
    this.description = 'Unggah atau seret dan lepas ke dalam kotak ini.',
    this.buttonLabel = 'Pilih File',
    this.errors = const <String>[],
    this.dragOver = false,
    this.collapseAfter = 5,
    this.showMoreLabel = 'Lihat Selengkapnya',
    this.showLessLabel = 'Sembunyikan',
  });

  /// Berkas yang ditampilkan di bawah area.
  final List<IddsUploadFile> files;

  /// Dipanggil saat area atau tombol ditekan. `null` membuat komponen
  /// nonaktif.
  final VoidCallback? onPick;

  /// Dipanggil dengan indeks berkas yang dihapus. Bila `null`, tombol hapus
  /// tidak tampil.
  final ValueChanged<int>? onRemove;

  /// Dipanggil dengan indeks berkas berstatus error yang dicoba ulang.
  final ValueChanged<int>? onRetry;

  /// Dipanggil dengan indeks berkas yang unggahannya dibatalkan.
  final ValueChanged<int>? onCancel;

  /// Label di atas area.
  final Widget? label;

  /// Tampilkan tanda wajib (*).
  final bool required;

  /// Judul di dalam area.
  final String title;

  /// Keterangan di dalam area.
  final String description;

  /// Teks tombol.
  final String buttonLabel;

  /// Pesan error umum (mis. jumlah berkas melebihi batas), ditampilkan di
  /// bawah daftar.
  final List<String> errors;

  /// Tampilan saat berkas sedang diseret di atas area.
  final bool dragOver;

  /// Jumlah berkas yang tampil sebelum tombol "Lihat Selengkapnya". 0 atau
  /// kurang: semua berkas selalu tampil.
  final int collapseAfter;

  /// Teks tombol menampilkan semua berkas.
  final String showMoreLabel;

  /// Teks tombol menyembunyikan berkas.
  final String showLessLabel;

  @override
  State<IddsFileUpload> createState() => _IddsFileUploadState();
}

class _IddsFileUploadState extends State<IddsFileUpload> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool enabled = widget.onPick != null;
    final bool collapsible = widget.collapseAfter > 0 && widget.files.length > widget.collapseAfter;
    final int shown = collapsible && !_expanded ? widget.collapseAfter : widget.files.length;
    final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);

    final Widget dropzone = Semantics(
      button: true,
      enabled: enabled,
      label: '${widget.title}. ${widget.description}',
      onTap: widget.onPick,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: widget.onPick,
        builder: (BuildContext context, IddsInteractionState state) {
          final bool highlight = widget.dragOver || state.hovered;
          final Color border = widget.dragOver
              ? c.contentPrimary
              : state.hovered
                  ? c.strokeSecondary
                  : c.strokePrimary;
          return Opacity(
            opacity: enabled ? 1 : 0.5,
            child: IddsInsetRing(
              visible: state.focused,
              borderRadius: radius,
              rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.contentPrimary)],
              child: CustomPaint(
                painter: _DashedBorderPainter(color: border, radius: IddsRadius.lg),
                child: AnimatedContainer(
                  duration: IddsDuration.base,
                  padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s24, vertical: IddsSpacing.s40),
                  decoration: BoxDecoration(
                    color: highlight && enabled ? c.backgroundSecondary : c.backgroundPrimary,
                    borderRadius: radius,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: IddsSpacing.s16,
                    children: <Widget>[
                      IddsIcon(IddsIcons.upload, size: 24, color: c.contentPrimary),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: IddsSpacing.s4,
                        children: <Widget>[
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: theme.textStyle(
                              fontSize: IddsFontSize.base,
                              lineHeight: IddsLineHeight.base,
                              fontWeight: IddsFontWeight.semibold,
                              color: c.contentPrimary,
                            ),
                          ),
                          Text(
                            widget.description,
                            textAlign: TextAlign.center,
                            style: theme.textStyle(
                              fontSize: IddsFontSize.sm,
                              lineHeight: IddsLineHeight.sm,
                              color: c.contentSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Tombol hanya tampilan; seluruh area sudah bisa ditekan.
                      ExcludeSemantics(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s16, vertical: IddsSpacing.s8 - 1),
                          decoration: BoxDecoration(
                            color: c.backgroundPrimary,
                            borderRadius: radius,
                            border: Border.all(color: c.strokePrimary),
                          ),
                          child: Text(
                            widget.buttonLabel,
                            style: theme.textStyle(
                              fontSize: IddsFontSize.sm,
                              lineHeight: IddsLineHeight.sm,
                              fontWeight: IddsFontWeight.semibold,
                              color: c.contentPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.label != null) IddsFieldLabel(label: widget.label!, required: widget.required, small: false),
        dropzone,
        if (widget.files.isNotEmpty) ...<Widget>[
          const SizedBox(height: IddsSpacing.s24),
          for (int i = 0; i < shown; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == shown - 1 ? 0 : IddsSpacing.s8),
              child: _FileRow(
                file: widget.files[i],
                onRemove: widget.onRemove == null ? null : () => widget.onRemove!(i),
                onRetry: widget.onRetry == null ? null : () => widget.onRetry!(i),
                onCancel: widget.onCancel == null ? null : () => widget.onCancel!(i),
              ),
            ),
        ],
        if (collapsible)
          Padding(
            padding: const EdgeInsets.only(top: IddsSpacing.s8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _ShowMoreButton(
                label: _expanded ? widget.showLessLabel : widget.showMoreLabel,
                expanded: _expanded,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
            ),
          ),
        if (widget.errors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: IddsSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: IddsSpacing.s4,
              children: <Widget>[for (final String e in widget.errors) _ErrorMessage(e)],
            ),
          ),
      ],
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file, required this.onRemove, required this.onRetry, required this.onCancel});

  final IddsUploadFile file;
  final VoidCallback? onRemove;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool isError = file.status == IddsFileStatus.error;
    final Color border = switch (file.status) {
      IddsFileStatus.error => c.negative.shade500,
      IddsFileStatus.success => c.positive.shade500,
      IddsFileStatus.uploading => c.primary.shade300,
      IddsFileStatus.idle => c.strokePrimary,
    };
    final Widget indicator = switch (file.status) {
      IddsFileStatus.uploading => _Spinner(color: c.contentSecondary),
      IddsFileStatus.error => IddsIcon(IddsIcons.circleX, size: 20, color: c.negative.shade500),
      // Versi web juga menampilkan centang untuk berkas yang baru dipilih.
      _ => IddsIcon(IddsIcons.circleCheck, size: 20, color: c.positive.shade600),
    };
    final int? percent = file.status == IddsFileStatus.uploading && file.progress != null
        ? (file.progress!.clamp(0, 1) * 100).round()
        : null;

    final String statusText = switch (file.status) {
      IddsFileStatus.uploading => ', sedang diunggah${percent == null ? '' : ' $percent%'}',
      IddsFileStatus.success => ', berhasil diunggah',
      IddsFileStatus.error => ', gagal${file.error == null ? '' : ': ${file.error}'}',
      IddsFileStatus.idle => '',
    };

    return Semantics(
      container: true,
      label: '${file.name}, ${iddsFormatFileSize(file.size)}$statusText',
      explicitChildNodes: true,
      child: AnimatedContainer(
        duration: IddsDuration.base,
        padding: const EdgeInsets.all(IddsSpacing.s12 - 1),
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          borderRadius: BorderRadius.circular(IddsRadius.lg),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: IddsSpacing.s12,
          children: <Widget>[
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox(width: 24, height: 24, child: Center(child: indicator)),
              ),
            ),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: IddsSpacing.s4,
                  children: <Widget>[
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textStyle(
                        fontSize: IddsFontSize.sm,
                        lineHeight: IddsLineHeight.sm,
                        fontWeight: IddsFontWeight.semibold,
                        color: isError ? c.negative.shade500 : c.contentPrimary,
                      ),
                    ),
                    Text(
                      percent == null ? iddsFormatFileSize(file.size) : '${iddsFormatFileSize(file.size)} · $percent%',
                      style: theme.textStyle(
                        fontSize: IddsFontSize.xs,
                        lineHeight: IddsLineHeight.xs,
                        color: c.contentSecondary,
                      ),
                    ),
                    if (file.status == IddsFileStatus.uploading && file.progress != null)
                      _ProgressBar(value: file.progress!),
                    if (isError && file.error != null)
                      Text(
                        file.error!,
                        style: theme.textStyle(
                          fontSize: IddsFontSize.xs,
                          lineHeight: IddsLineHeight.xs,
                          color: c.negative.shade500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: IddsSpacing.s8,
              children: <Widget>[
                if (file.status == IddsFileStatus.uploading)
                  if (onCancel != null)
                    _IconAction(icon: IddsIcons.x, label: 'Batalkan unggah ${file.name}', danger: true, onTap: onCancel!),
                if (isError && onRetry != null)
                  _IconAction(icon: IddsIcons.refresh, label: 'Coba lagi ${file.name}', danger: false, onTap: onRetry!),
                if (file.status != IddsFileStatus.uploading && onRemove != null)
                  _IconAction(icon: IddsIcons.trash, label: 'Hapus ${file.name}', danger: true, onTap: onRemove!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Kotak unggah satu berkas berukuran ringkas (Single File Upload IDDS).
///
/// Tampilan mengikuti [file]: kosong/idle menampilkan judul dan keterangan,
/// [IddsFileStatus.uploading] menampilkan bilah kemajuan, dan
/// [IddsFileStatus.success] menampilkan nama berkas dengan tombol hapus.
class IddsSingleFileUpload extends StatelessWidget {
  /// Membuat kotak unggah satu berkas.
  const IddsSingleFileUpload({
    super.key,
    required this.file,
    required this.onPick,
    this.onRemove,
    this.title = 'Unggah File',
    this.description = 'Maksimal 2 MB',
    this.dragOver = false,
    this.width,
  });

  /// Berkas saat ini, atau `null` bila belum ada.
  final IddsUploadFile? file;

  /// Dipanggil saat kotak ditekan (hanya bila belum ada berkas). `null`
  /// membuat komponen nonaktif.
  final VoidCallback? onPick;

  /// Dipanggil saat tombol hapus ditekan.
  final VoidCallback? onRemove;

  /// Judul saat kosong.
  final String title;

  /// Keterangan di bawah judul atau nama berkas.
  final String description;

  /// Tampilan saat berkas sedang diseret di atas kotak.
  final bool dragOver;

  /// Lebar. Bawaan: 300px, atau selebar yang tersedia bila lebih sempit.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final IddsUploadFile? file = this.file;
    final bool enabled = onPick != null;
    final bool hasFile = file != null && file.status == IddsFileStatus.success;
    final bool uploading = file != null && file.status == IddsFileStatus.uploading;
    final bool isError = file != null && file.status == IddsFileStatus.error;
    final bool canPick = enabled && !hasFile && !uploading;
    final BorderRadius radius = BorderRadius.circular(IddsRadius.lg);

    final TextStyle titleStyle = theme.textStyle(
      fontSize: IddsFontSize.sm,
      lineHeight: IddsLineHeight.sm,
      fontWeight: IddsFontWeight.semibold,
      color: enabled ? c.contentPrimary : c.contentTertiary,
    );
    final TextStyle descStyle = theme.textStyle(
      fontSize: IddsFontSize.xs,
      lineHeight: IddsLineHeight.xs,
      color: !enabled
          ? c.contentTertiary
          : isError
              ? c.negative.shade500
              : c.contentSecondary,
    );

    Widget content(IddsInteractionState state) {
      final bool active = dragOver || state.hovered;
      final List<Widget> children;
      if (uploading) {
        final double? progress = file.progress;
        children = <Widget>[
          IddsIcon(IddsIcons.upload, size: 24, color: c.contentPrimary),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: IddsSpacing.s4,
              children: <Widget>[
                _ProgressBar(value: progress ?? 0),
                Text(progress == null ? 'Mengunggah...' : '${(progress.clamp(0, 1) * 100).round()}%', style: descStyle),
              ],
            ),
          ),
        ];
      } else if (hasFile) {
        children = <Widget>[
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.backgroundSecondary, borderRadius: radius),
            child: IddsIcon(IddsIcons.file, size: 16, color: c.contentPrimary),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
                Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: descStyle),
              ],
            ),
          ),
          if (onRemove != null && enabled)
            _IconAction(icon: IddsIcons.trash, label: 'Hapus ${file.name}', danger: true, size: 18, onTap: onRemove!),
        ];
      } else {
        children = <Widget>[
          SizedBox(
            width: 32,
            height: 32,
            child: Center(child: IddsIcon(IddsIcons.upload, size: 24, color: enabled ? c.contentPrimary : c.contentTertiary)),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: <Widget>[
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
                Text(
                  isError ? (file.error ?? description) : description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: descStyle,
                ),
              ],
            ),
          ),
        ];
      }

      return IddsInsetRing(
        visible: state.focused,
        borderRadius: radius,
        inset: 1,
        rings: <(double, Color)>[(2.0, c.backgroundPrimary), (1.0, c.contentPrimary)],
        child: AnimatedContainer(
          duration: IddsDuration.base,
          height: 72,
          padding: const EdgeInsets.all(IddsSpacing.s12 - 1),
          decoration: BoxDecoration(
            color: enabled ? c.backgroundPrimary : c.backgroundSecondary,
            borderRadius: radius,
            border: Border.all(
              color: isError
                  ? c.negative.shade500
                  : active && canPick
                      ? c.contentPrimary
                      : c.strokePrimary,
            ),
          ),
          child: Row(spacing: IddsSpacing.s12, children: children),
        ),
      );
    }

    final Widget box = Semantics(
      button: canPick,
      enabled: enabled,
      label: hasFile ? '${file.name}, $description' : '$title, ${isError ? (file.error ?? description) : description}',
      onTap: canPick ? onPick : null,
      child: IddsInteractive(
        onTap: canPick ? onPick : null,
        canRequestFocus: canPick,
        mouseCursor: canPick ? null : MouseCursor.defer,
        builder: (BuildContext context, IddsInteractionState state) => content(state),
      ),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = width ?? 300;
        return SizedBox(width: constraints.hasBoundedWidth ? math.min(w, constraints.maxWidth) : w, child: box);
      },
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.label, required this.danger, required this.onTap, this.size = 20});

  final IddsIconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) {
          final Color color = danger
              ? (state.hovered ? c.negative.shade600 : c.negative.shade500)
              : c.primary.shade500;
          return IddsInsetRing(
            visible: state.focused,
            borderRadius: BorderRadius.circular(IddsRadius.base),
            rings: <(double, Color)>[(2.0, c.contentPrimary)],
            child: Container(
              width: size + 4,
              height: size + 4,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: !danger && state.hovered ? (theme.isDark ? c.backgroundSecondary : c.primary.shade25) : null,
                borderRadius: BorderRadius.circular(IddsRadius.base),
              ),
              child: IddsIcon(icon, size: size, color: color),
            ),
          );
        },
      ),
    );
  }
}

class _ShowMoreButton extends StatelessWidget {
  const _ShowMoreButton({required this.label, required this.expanded, required this.onTap});

  final String label;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: IddsInteractive(
        onTap: onTap,
        builder: (BuildContext context, IddsInteractionState state) {
          // CSS: primary-500; di dark mode warna terang mode gelap dipakai
          // agar tetap terbaca.
          final Color color = theme.isDark ? c.primaryMain : (state.hovered ? c.primary.shade600 : c.primary.shade500);
          return IddsInsetRing(
            visible: state.focused,
            borderRadius: BorderRadius.circular(IddsRadius.sm),
            rings: <(double, Color)>[(2.0, c.contentPrimary)],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: IddsSpacing.s4,
              children: <Widget>[
                Text(
                  label,
                  style: theme
                      .textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: color)
                      .copyWith(
                        decoration: state.hovered ? TextDecoration.underline : TextDecoration.none,
                        decorationColor: color,
                      ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: IddsDuration.base,
                  child: IddsIcon(IddsIcons.chevronDown, size: 16, color: color),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: IddsSpacing.s12 - 1, vertical: IddsSpacing.s8 - 1),
      decoration: BoxDecoration(
        // CSS: latar error-25; di dark mode latar terang diganti latar biasa.
        color: theme.isDark ? c.backgroundPrimary : c.negative.shade50,
        borderRadius: BorderRadius.circular(IddsRadius.base),
        border: Border.all(color: c.negative.shade500),
      ),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: theme.textStyle(
            fontSize: IddsFontSize.xs,
            lineHeight: IddsLineHeight.xs,
            color: theme.isDark ? c.negative.shade400 : c.negative.shade500,
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final IddsColors c = IddsTheme.of(context).colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        height: 4,
        color: c.backgroundSecondary,
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: IddsDuration.slow,
          widthFactor: value.clamp(0, 1).toDouble(),
          heightFactor: 1,
          // CSS: primary-300 (abu-abu muda di brand Neutral); diganti warna
          // utama agar kemajuan terlihat jelas.
          child: ColoredBox(color: c.primaryMain),
        ),
      ),
    );
  }
}

/// Ikon refresh yang berputar terus.
class _Spinner extends StatefulWidget {
  const _Spinner({required this.color});

  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: IddsIcon(IddsIcons.refresh, size: 20, color: widget.color),
    );
  }
}

/// Garis tepi putus-putus dengan sudut membulat (CSS `border: 1px dashed`).
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final RRect rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);
    const double dash = 4;
    const double gap = 3;
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, math.min(distance + dash, metric.length)), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => oldDelegate.color != color || oldDelegate.radius != radius;
}
