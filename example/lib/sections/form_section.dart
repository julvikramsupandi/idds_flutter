import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class FormSection extends StatefulWidget {
  const FormSection({super.key});

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  bool _agree = false;
  bool _newsletter = true;
  final Set<String> _hobbies = <String>{'Membaca'};
  String? _gender;
  String _plan = 'basic';
  bool _notify = true;
  bool _darkPreview = false;

  static const List<String> _allHobbies = <String>['Membaca', 'Olahraga', 'Musik'];

  @override
  Widget build(BuildContext context) {
    final bool allHobbies = _hobbies.length == _allHobbies.length;
    return GallerySection(
      title: 'Form',
      usage: 'Semua isian dikendalikan dari luar: simpan nilai di state (atau TextEditingController) dan perbarui lewat onChanged. Status error/warning/success menampilkan pesan lewat statusMessage.',
      code: _formCode,
      children: <Widget>[
        const IddsTextField(
          label: Text('Nama lengkap'),
          required: true,
          placeholder: 'Masukkan nama sesuai KTP',
          helperText: 'Gunakan nama tanpa gelar.',
          prefixIcon: Icon(TablerIcons.user),
        ),
        const SizedBox(height: IddsSpacing.s16),
        const IddsTextField(
          label: Text('Email'),
          initialValue: 'nama@contoh',
          status: IddsTextFieldStatus.error,
          statusMessage: 'Format email tidak valid.',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: IddsSpacing.s16),
        const IddsTextField(
          label: Text('Bio'),
          placeholder: 'Ceritakan sedikit tentang Anda',
          maxLength: 60,
          showCharCount: true,
          status: IddsTextFieldStatus.success,
          helperText: 'Opsional.',
        ),
        const SizedBox(height: IddsSpacing.s16),
        Wrap(
          spacing: IddsSpacing.s16,
          runSpacing: IddsSpacing.s16,
          children: <Widget>[
            for (final IddsTextFieldSize s in IddsTextFieldSize.values)
              SizedBox(
                width: 220,
                child: IddsTextField(size: s, placeholder: 'Ukuran ${s.name}'),
              ),
            const SizedBox(
              width: 220,
              child: IddsTextField(enabled: false, initialValue: 'Nonaktif'),
            ),
          ],
        ),
        const SizedBox(height: IddsSpacing.s32),
        const GalleryCaption('Checkbox'),
        const SizedBox(height: IddsSpacing.s8),
        IddsCheckbox(
          value: _agree,
          onChanged: (bool v) => setState(() => _agree = v),
          label: 'Saya menyetujui syarat dan ketentuan',
          invalid: !_agree,
        ),
        const SizedBox(height: IddsSpacing.s12),
        IddsCheckbox(
          value: _newsletter,
          onChanged: (bool v) => setState(() => _newsletter = v),
          label: 'Terima kabar terbaru',
          subtext: 'Maksimal satu email per minggu.',
        ),
        const SizedBox(height: IddsSpacing.s12),
        IddsCheckbox(
          value: allHobbies,
          indeterminate: _hobbies.isNotEmpty && !allHobbies,
          onChanged: (bool v) => setState(() => v ? _hobbies.addAll(_allHobbies) : _hobbies.clear()),
          label: 'Semua hobi',
        ),
        for (final String hobby in _allHobbies)
          Padding(
            padding: const EdgeInsets.only(left: IddsSpacing.s32, top: IddsSpacing.s8),
            child: IddsCheckbox(
              value: _hobbies.contains(hobby),
              onChanged: (bool v) => setState(() => v ? _hobbies.add(hobby) : _hobbies.remove(hobby)),
              label: hobby,
            ),
          ),
        const SizedBox(height: IddsSpacing.s12),
        const IddsCheckbox(value: true, onChanged: null, label: 'Nonaktif'),
        const SizedBox(height: IddsSpacing.s32),
        IddsRadioGroup<String>(
          label: 'Jenis kelamin',
          required: true,
          value: _gender,
          error: _gender == null,
          helperText: _gender == null ? 'Wajib dipilih.' : null,
          onChanged: (String v) => setState(() => _gender = v),
          options: const <IddsRadioOption<String>>[
            IddsRadioOption<String>(value: 'L', label: 'Laki-laki'),
            IddsRadioOption<String>(value: 'P', label: 'Perempuan'),
          ],
        ),
        const SizedBox(height: IddsSpacing.s16),
        IddsRadioGroup<String>(
          label: 'Paket (horizontal)',
          direction: Axis.horizontal,
          value: _plan,
          onChanged: (String v) => setState(() => _plan = v),
          options: const <IddsRadioOption<String>>[
            IddsRadioOption<String>(value: 'basic', label: 'Basic'),
            IddsRadioOption<String>(value: 'pro', label: 'Pro'),
            IddsRadioOption<String>(value: 'gov', label: 'Instansi', enabled: false),
          ],
        ),
        const SizedBox(height: IddsSpacing.s32),
        const GalleryCaption('Toggle'),
        const SizedBox(height: IddsSpacing.s8),
        Wrap(
          spacing: IddsSpacing.s16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            IddsToggle(
              value: _notify,
              onChanged: (bool v) => setState(() => _notify = v),
              semanticLabel: 'Notifikasi',
            ),
            IddsToggle(
              value: _darkPreview,
              size: IddsToggleSize.sm,
              onChanged: (bool v) => setState(() => _darkPreview = v),
              semanticLabel: 'Contoh kecil',
            ),
            const IddsToggle(value: true, onChanged: null),
            const IddsToggle(value: false, onChanged: null),
          ],
        ),
      ],
    );
  }
}

const String _formCode = r'''
IddsTextField(
  controller: _nameController,
  label: const Text('Nama lengkap'),
  required: true,
  placeholder: 'Masukkan nama sesuai KTP',
  helperText: 'Gunakan nama tanpa gelar.',
  prefixIcon: const Icon(TablerIcons.user),
)

IddsTextField(
  label: const Text('Email'),
  keyboardType: TextInputType.emailAddress,
  status: IddsTextFieldStatus.error, // neutral, error, warning, success
  statusMessage: 'Format email tidak valid.',
)

IddsCheckbox(
  value: _agreed,
  label: 'Saya menyetujui syarat dan ketentuan',
  onChanged: (bool v) => setState(() => _agreed = v),
)

IddsRadioGroup<String>(
  label: 'Jenis kelamin',
  value: _gender,
  options: const [
    IddsRadioOption(value: 'L', label: 'Laki-laki'),
    IddsRadioOption(value: 'P', label: 'Perempuan'),
  ],
  onChanged: (String v) => setState(() => _gender = v),
)

IddsToggle(
  value: _notifications,
  semanticLabel: 'Notifikasi',
  onChanged: (bool v) => setState(() => _notifications = v),
)
''';
