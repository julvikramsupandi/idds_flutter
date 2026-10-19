import 'dart:async';

import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

/// Contoh File Upload. Pemilihan dan pengunggahan berkas di sini hanya
/// simulasi; di aplikasi nyata panggil pemilih berkas (mis. package
/// `file_picker`) di `onPick` lalu unggah ke server.
class FileUploadSection extends StatefulWidget {
  const FileUploadSection({super.key});

  @override
  State<FileUploadSection> createState() => _FileUploadSectionState();
}

class _FileUploadSectionState extends State<FileUploadSection> {
  static const List<(String, int)> _samples = <(String, int)>[
    ('surat-pernyataan.pdf', 245760),
    ('ktp.jpg', 1258291),
    ('kartu-keluarga.pdf', 870400),
    ('pas-foto.png', 524288),
    ('installer.exe', 3145728),
    ('ijazah.pdf', 1835008),
  ];

  final List<IddsUploadFile> _files = <IddsUploadFile>[];
  final List<String> _errors = <String>[];
  final Map<String, Timer> _timers = <String, Timer>{};
  int _next = 0;
  IddsUploadFile? _single;
  Timer? _singleTimer;

  @override
  void dispose() {
    for (final Timer t in _timers.values) {
      t.cancel();
    }
    _singleTimer?.cancel();
    super.dispose();
  }

  void _pick() {
    final (String name, int size) = _samples[_next % _samples.length];
    _next++;
    final String? error = iddsValidateFile(
      name: name,
      size: size,
      allowedExtensions: const <String>['pdf', 'jpg', 'png'],
      maxSize: 2 * 1024 * 1024,
    );
    setState(() {
      _errors.clear();
      if (_files.length >= 6) {
        _errors.add('Maksimal 6 file yang dapat diupload');
        return;
      }
      _files.add(IddsUploadFile(
        name: name,
        size: size,
        status: error == null ? IddsFileStatus.uploading : IddsFileStatus.error,
        progress: 0,
        error: error,
      ));
    });
    if (error == null) _upload(name);
  }

  void _upload(String name) {
    _timers[name]?.cancel();
    _timers[name] = Timer.periodic(const Duration(milliseconds: 200), (Timer t) {
      final int i = _files.indexWhere((IddsUploadFile f) => f.name == name);
      if (i < 0) {
        t.cancel();
        return;
      }
      final double progress = (_files[i].progress ?? 0) + 0.1;
      setState(() {
        _files[i] = progress >= 1
            ? IddsUploadFile(name: name, size: _files[i].size, status: IddsFileStatus.success)
            : _files[i].copyWith(progress: progress);
      });
      if (progress >= 1) t.cancel();
    });
  }

  void _pickSingle() {
    setState(() => _single = const IddsUploadFile(name: 'npwp.pdf', size: 409600, status: IddsFileStatus.uploading, progress: 0));
    _singleTimer?.cancel();
    _singleTimer = Timer.periodic(const Duration(milliseconds: 150), (Timer t) {
      final double progress = (_single?.progress ?? 0) + 0.1;
      setState(() {
        _single = progress >= 1
            ? const IddsUploadFile(name: 'npwp.pdf', size: 409600, status: IddsFileStatus.success)
            : _single!.copyWith(progress: progress);
      });
      if (progress >= 1) t.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'File Upload',
      subtitle: 'Hanya tampilan: aplikasi memilih dan mengunggah berkas sendiri, lalu mengisi status. '
          'Di sini prosesnya disimulasikan; installer.exe sengaja ditolak oleh iddsValidateFile.',
      usage: 'Komponen ini hanya tampilan. Pilih berkas dengan package pilihan Anda (misalnya file_picker), validasi dengan iddsValidateFile, unggah sendiri, lalu perbarui status dan progress tiap berkas di state.',
      code: _uploadCode,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: IddsFileUpload(
            label: const Text('Dokumen pendukung'),
            required: true,
            description: 'PDF, JPG, atau PNG. Maksimal 2 MB per berkas.',
            files: _files,
            errors: _errors,
            onPick: _pick,
            onRemove: (int i) => setState(() {
              _timers.remove(_files[i].name)?.cancel();
              _files.removeAt(i);
              _errors.clear();
            }),
            onCancel: (int i) => setState(() {
              _timers.remove(_files[i].name)?.cancel();
              _files.removeAt(i);
            }),
            onRetry: (int i) => setState(() => _errors
              ..clear()
              ..add('${_files[i].name}: berkas ini tetap ditolak, pilih berkas lain.')),
          ),
        ),
        const SizedBox(height: IddsSpacing.s24),
        const GalleryCaption('Single File Upload'),
        const SizedBox(height: IddsSpacing.s8),
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s16,
          children: <Widget>[
            IddsSingleFileUpload(
              file: _single,
              description: 'PDF, maksimal 2 MB',
              onPick: _pickSingle,
              onRemove: () => setState(() => _single = null),
            ),
            const IddsSingleFileUpload(
              file: IddsUploadFile(name: 'foto.exe', size: 1, status: IddsFileStatus.error, error: 'Ekstensi file harus: pdf'),
              onPick: null,
              description: 'Nonaktif',
            ),
          ],
        ),
      ],
    );
  }
}

const String _uploadCode = r'''
final List<IddsUploadFile> _files = [];

IddsFileUpload(
  label: const Text('Dokumen pendukung'),
  required: true,
  description: 'PDF, JPG, atau PNG. Maksimal 2 MB.',
  files: _files,
  onPick: () async {
    final (String name, int size) = await pickFile(); // fungsi Anda
    final String? error = iddsValidateFile(
      name: name,
      size: size,
      allowedExtensions: const ['pdf', 'jpg', 'png'],
      maxSize: 2 * 1024 * 1024,
    );
    setState(() => _files.add(IddsUploadFile(
          name: name,
          size: size,
          status: error == null ? IddsFileStatus.uploading : IddsFileStatus.error,
          progress: 0,
          error: error,
        )));
    // Saat unggah berjalan: _files[i] = _files[i].copyWith(progress: 0.5);
    // Selesai: status: IddsFileStatus.success
  },
  onRemove: (int i) => setState(() => _files.removeAt(i)),
)

IddsSingleFileUpload(
  file: _taxFile, // IddsUploadFile?
  description: 'PDF, maksimal 2 MB',
  onPick: pickTaxFile,
  onRemove: () => setState(() => _taxFile = null),
)
''';
