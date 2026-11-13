import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'mobile_common.dart';
import 'phone_frame.dart';

/// Form pengajuan layanan tiga langkah: data diri, dokumen, lalu kirim.
/// Memperlihatkan Stepper, validasi per langkah, unggah berkas, dan tombol
/// aksi yang menempel di bawah layar.
class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen(
      {super.key, this.serviceName = 'Pindah Domisili'});

  /// Nama layanan yang diajukan, tampil di judul.
  final String serviceName;

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  static const List<IddsStep> _steps = <IddsStep>[
    IddsStep(label: 'Data Diri'),
    IddsStep(label: 'Dokumen'),
    IddsStep(label: 'Kirim'),
  ];

  static const List<IddsSelectOption<String>> _districts =
      <IddsSelectOption<String>>[
    IddsSelectOption<String>(value: 'kota-barat', label: 'Kota Barat'),
    IddsSelectOption<String>(value: 'kota-selatan', label: 'Kota Selatan'),
    IddsSelectOption<String>(value: 'kota-timur', label: 'Kota Timur'),
    IddsSelectOption<String>(value: 'kota-utara', label: 'Kota Utara'),
    IddsSelectOption<String>(value: 'dungingi', label: 'Dungingi'),
  ];

  final ScrollController _scroll = ScrollController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _nik = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final Map<String, Timer> _uploads = <String, Timer>{};

  int _step = 0;
  bool _submitted = false;
  DateTime? _birthDate;
  String? _district;
  IddsUploadFile? _ktp;
  IddsUploadFile? _kk;
  bool _agree = false;

  @override
  void dispose() {
    for (final Timer t in _uploads.values) {
      t.cancel();
    }
    _scroll.dispose();
    _name.dispose();
    _nik.dispose();
    _purpose.dispose();
    super.dispose();
  }

  String? get _nameError => _submitted && _name.text.trim().isEmpty
      ? 'Nama lengkap wajib diisi'
      : null;

  String? get _nikError => !_submitted
      ? null
      : _nik.text.isEmpty
          ? 'NIK wajib diisi'
          : _nik.text.length != 16
              ? 'NIK harus 16 digit'
              : null;

  String? get _districtError =>
      _submitted && _district == null ? 'Kecamatan wajib dipilih' : null;

  bool get _stepValid => switch (_step) {
        0 => _name.text.trim().isNotEmpty &&
            _nik.text.length == 16 &&
            _district != null,
        1 => _ktp?.status == IddsFileStatus.success &&
            _kk?.status == IddsFileStatus.success,
        _ => _agree,
      };

  /// Simulasi unggah: aplikasi sungguhan memilih berkas (mis. file_picker)
  /// lalu memperbarui `progress` dari proses unggah.
  void _pick(String key, String fileName, int size,
      ValueChanged<IddsUploadFile?> assign) {
    _uploads.remove(key)?.cancel();
    setState(() => assign(IddsUploadFile(
        name: fileName,
        size: size,
        status: IddsFileStatus.uploading,
        progress: 0)));
    double progress = 0;
    _uploads[key] =
        Timer.periodic(const Duration(milliseconds: 120), (Timer t) {
      progress += 0.1;
      setState(() => assign(progress >= 1
          ? IddsUploadFile(
              name: fileName, size: size, status: IddsFileStatus.success)
          : IddsUploadFile(
              name: fileName,
              size: size,
              status: IddsFileStatus.uploading,
              progress: progress)));
      if (progress >= 1) {
        t.cancel();
        _uploads.remove(key);
      }
    });
  }

  void _goTo(int step) {
    setState(() {
      _step = step;
      _submitted = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _next() {
    if (!_stepValid) {
      setState(() => _submitted = true);
      showPhoneToast(
        context,
        title: const Text('Lengkapi data terlebih dahulu'),
        description: Text(switch (_step) {
          0 => 'Periksa kembali isian yang ditandai merah.',
          1 => 'Unggah KTP-el dan Kartu Keluarga.',
          _ => 'Setujui pernyataan sebelum mengirim.',
        }),
        state: IddsToastState.destructive,
      );
      return;
    }
    if (_step < _steps.length - 1) {
      _goTo(_step + 1);
      return;
    }
    showPhoneToast(
      context,
      title: const Text('Pengajuan terkirim'),
      description: const Text(
          'Nomor pengajuan PD-2026-11-0042. Pantau statusnya di Riwayat.'),
      state: IddsToastState.positive,
    );
    _reset();
    Navigator.of(context).maybePop();
  }

  void _reset() {
    for (final Timer t in _uploads.values) {
      t.cancel();
    }
    _uploads.clear();
    _name.clear();
    _nik.clear();
    _purpose.clear();
    _birthDate = null;
    _district = null;
    _ktp = null;
    _kk = null;
    _agree = false;
    _goTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.of(context).canPop();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MobileAppBar(
          title: Text('Pengajuan ${widget.serviceName}'),
          onBack: canPop ? () => Navigator.of(context).maybePop() : null,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.all(IddsSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                IddsStepper(
                  steps: _steps,
                  currentStep: _step,
                  onStepTap: (int i) {
                    if (i < _step) _goTo(i);
                  },
                ),
                const SizedBox(height: IddsSpacing.s24),
                switch (_step) {
                  0 => _personalData(),
                  1 => _documents(),
                  _ => _review(),
                },
              ],
            ),
          ),
        ),
        MobileBottomBar(
          children: <Widget>[
            if (_step > 0)
              IddsButton(
                hierarchy: IddsButtonHierarchy.secondary,
                onPressed: () => _goTo(_step - 1),
                child: const Text('Kembali'),
              ),
            IddsButton(
              onPressed: _next,
              child: Text(
                  _step == _steps.length - 1 ? 'Kirim Pengajuan' : 'Lanjut'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _personalData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: IddsSpacing.s16,
      children: <Widget>[
        IddsTextField(
          controller: _name,
          label: const Text('Nama Lengkap'),
          required: true,
          placeholder: 'Sesuai KTP-el',
          status: _nameError == null
              ? IddsTextFieldStatus.neutral
              : IddsTextFieldStatus.error,
          statusMessage: _nameError,
          onChanged: (_) => setState(() {}),
        ),
        IddsTextField(
          controller: _nik,
          label: const Text('NIK'),
          required: true,
          placeholder: '16 digit angka',
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          maxLength: 16,
          showCharCount: true,
          status: _nikError == null
              ? IddsTextFieldStatus.neutral
              : IddsTextFieldStatus.error,
          statusMessage: _nikError,
          onChanged: (_) => setState(() {}),
        ),
        IddsDatePicker(
          label: const Text('Tanggal Lahir'),
          value: _birthDate,
          disableFuture: true,
          dateFormat: 'd MMMM yyyy',
          onChanged: (DateTime? d) => setState(() => _birthDate = d),
        ),
        IddsSelect<String>(
          label: const Text('Kecamatan Tujuan'),
          required: true,
          options: _districts,
          value: _district,
          errorText: _districtError,
          onChanged: (String? v) => setState(() => _district = v),
        ),
      ],
    );
  }

  Widget _documents() {
    final IddsThemeData theme = IddsTheme.of(context);
    TextStyle label() => theme.textStyle(
          fontSize: IddsFontSize.sm,
          lineHeight: IddsLineHeight.sm,
          fontWeight: IddsFontWeight.medium,
          color: theme.colors.contentPrimary,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: IddsSpacing.s8,
      children: <Widget>[
        Text('KTP-el *', style: label()),
        IddsSingleFileUpload(
          width: double.infinity,
          file: _ktp,
          title: 'Unggah KTP-el',
          description: 'JPG atau PDF, maksimal 2 MB',
          onPick: () => _pick(
              'ktp', 'ktp-el.jpg', 812000, (IddsUploadFile? f) => _ktp = f),
          onRemove: () => setState(() => _ktp = null),
        ),
        const SizedBox(height: IddsSpacing.s8),
        Text('Kartu Keluarga *', style: label()),
        IddsSingleFileUpload(
          width: double.infinity,
          file: _kk,
          title: 'Unggah Kartu Keluarga',
          description: 'JPG atau PDF, maksimal 2 MB',
          onPick: () => _pick('kk', 'kartu-keluarga.pdf', 1240000,
              (IddsUploadFile? f) => _kk = f),
          onRemove: () => setState(() => _kk = null),
        ),
        const SizedBox(height: IddsSpacing.s8),
        IddsTextArea(
          controller: _purpose,
          label: const Text('Keperluan'),
          placeholder: 'Contoh: pindah tempat kerja',
          minLines: 3,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _review() {
    final String district = _districts
        .firstWhere((IddsSelectOption<String> o) => o.value == _district,
            orElse: () => _districts.first)
        .label;
    final DateTime? d = _birthDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: IddsSpacing.s16,
      children: <Widget>[
        const IddsAlert(
          title: Text('Periksa kembali data Anda'),
          message: Text(
              'Data yang sudah dikirim tidak bisa diubah sampai pengajuan diproses.'),
        ),
        IddsCardPlain(
          padding: EdgeInsets.zero,
          child: IddsList(
            padding: EdgeInsets.zero,
            children: <Widget>[
              IddsListItem(
                  leading: const Icon(TablerIcons.user),
                  title: Text(_name.text),
                  subtitle: const Text('Nama lengkap')),
              IddsListItem(
                  leading: const Icon(TablerIcons.id),
                  title: Text(_nik.text),
                  subtitle: const Text('NIK')),
              IddsListItem(
                leading: const Icon(TablerIcons.calendar_event),
                title: Text(d == null ? '-' : '${d.day}/${d.month}/${d.year}'),
                subtitle: const Text('Tanggal lahir'),
              ),
              IddsListItem(
                  leading: const Icon(TablerIcons.map_pin),
                  title: Text(district),
                  subtitle: const Text('Kecamatan tujuan')),
              const IddsListItem(
                leading: Icon(TablerIcons.file_certificate),
                title: Text('2 dokumen'),
                subtitle: Text('KTP-el, Kartu Keluarga'),
              ),
            ],
          ),
        ),
        IddsCheckbox(
          value: _agree,
          invalid: _submitted && !_agree,
          onChanged: (bool v) => setState(() => _agree = v),
          label: 'Saya menyatakan data yang saya isi benar',
        ),
      ],
    );
  }
}
