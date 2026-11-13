import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class TextFieldSection extends StatelessWidget {
  const TextFieldSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Text Field',
      subtitle: 'Label, teks bantuan, status validasi, penghitung karakter, '
          'dan tiga ukuran.',
      usage:
          'Simpan nilai di TextEditingController (atau initialValue untuk nilai awal saja). Status error/warning/success menampilkan pesan lewat statusMessage. Tinggi kotak tetap 40/44/48px di semua layar sesuai minimum IDDS.',
      code: _textFieldCode,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: IddsSpacing.s16,
            children: <Widget>[
              IddsTextField(
                label: Text('Nama lengkap'),
                required: true,
                placeholder: 'Masukkan nama sesuai KTP',
                helperText: 'Gunakan nama tanpa gelar.',
                prefixIcon: Icon(TablerIcons.user),
              ),
              IddsTextField(
                label: Text('Email'),
                initialValue: 'nama@contoh',
                status: IddsTextFieldStatus.error,
                statusMessage: 'Format email tidak valid.',
                keyboardType: TextInputType.emailAddress,
              ),
              IddsTextField(
                label: Text('Bio'),
                placeholder: 'Ceritakan sedikit tentang Anda',
                maxLength: 60,
                showCharCount: true,
                status: IddsTextFieldStatus.success,
                helperText: 'Opsional.',
              ),
            ],
          ),
        ),
        const SizedBox(height: IddsSpacing.s24),
        const GalleryCaption('Ukuran dan nonaktif'),
        const SizedBox(height: IddsSpacing.s8),
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
      ],
    );
  }
}

class CheckboxSection extends StatefulWidget {
  const CheckboxSection({super.key});

  @override
  State<CheckboxSection> createState() => _CheckboxSectionState();
}

class _CheckboxSectionState extends State<CheckboxSection> {
  bool _agree = false;
  bool _newsletter = true;
  final Set<String> _hobbies = <String>{'Membaca'};

  static const List<String> _allHobbies = <String>[
    'Membaca',
    'Olahraga',
    'Musik',
  ];

  @override
  Widget build(BuildContext context) {
    final bool allHobbies = _hobbies.length == _allHobbies.length;
    return GallerySection(
      title: 'Checkbox',
      subtitle: 'Status tidak valid, teks tambahan, indeterminate untuk '
          '"pilih semua", dan nonaktif.',
      usage:
          'Nilai dikendalikan dari luar lewat value dan onChanged. indeterminate menampilkan tanda strip, biasanya untuk kotak "pilih semua" saat hanya sebagian anak yang terpilih. invalid menandai kotak wajib yang belum dicentang.',
      code: _checkboxCode,
      children: <Widget>[
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
          onChanged: (bool v) => setState(
            () => v ? _hobbies.addAll(_allHobbies) : _hobbies.clear(),
          ),
          label: 'Semua hobi',
        ),
        for (final String hobby in _allHobbies)
          Padding(
            padding: const EdgeInsets.only(
              left: IddsSpacing.s32,
              top: IddsSpacing.s8,
            ),
            child: IddsCheckbox(
              value: _hobbies.contains(hobby),
              onChanged: (bool v) => setState(
                () => v ? _hobbies.add(hobby) : _hobbies.remove(hobby),
              ),
              label: hobby,
            ),
          ),
        const SizedBox(height: IddsSpacing.s12),
        const IddsCheckbox(value: true, onChanged: null, label: 'Nonaktif'),
      ],
    );
  }
}

class RadioSection extends StatefulWidget {
  const RadioSection({super.key});

  @override
  State<RadioSection> createState() => _RadioSectionState();
}

class _RadioSectionState extends State<RadioSection> {
  String? _gender;
  String _plan = 'basic';

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Radio',
      subtitle: 'Grup wajib dengan pesan error, susunan mendatar, dan opsi '
          'nonaktif.',
      usage:
          'IddsRadioGroup menampilkan label grup dan opsi-opsinya; nilai terpilih disimpan di state dan diperbarui lewat onChanged. direction: Axis.horizontal untuk opsi sebaris.',
      code: _radioCode,
      children: <Widget>[
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
        const SizedBox(height: IddsSpacing.s24),
        IddsRadioGroup<String>(
          label: 'Paket (horizontal)',
          direction: Axis.horizontal,
          value: _plan,
          onChanged: (String v) => setState(() => _plan = v),
          options: const <IddsRadioOption<String>>[
            IddsRadioOption<String>(value: 'basic', label: 'Basic'),
            IddsRadioOption<String>(value: 'pro', label: 'Pro'),
            IddsRadioOption<String>(
              value: 'gov',
              label: 'Instansi',
              enabled: false,
            ),
          ],
        ),
      ],
    );
  }
}

class ToggleSection extends StatefulWidget {
  const ToggleSection({super.key});

  @override
  State<ToggleSection> createState() => _ToggleSectionState();
}

class _ToggleSectionState extends State<ToggleSection> {
  bool _notify = true;
  bool _small = false;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Toggle',
      subtitle: 'Ukuran bawaan dan kecil, serta keadaan nonaktif.',
      usage:
          'Untuk pengaturan yang langsung berlaku (nyala/mati). Isi semanticLabel agar pembaca layar tahu fungsinya bila tidak ada teks di dekatnya.',
      code: _toggleCode,
      children: <Widget>[
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
              value: _small,
              size: IddsToggleSize.sm,
              onChanged: (bool v) => setState(() => _small = v),
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

const String _textFieldCode = r'''
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

IddsTextField(
  label: const Text('Bio'),
  maxLength: 60,
  showCharCount: true,
  size: IddsTextFieldSize.lg, // sm, md (bawaan), lg
)
''';

const String _checkboxCode = r'''
IddsCheckbox(
  value: _agreed,
  label: 'Saya menyetujui syarat dan ketentuan',
  invalid: !_agreed,
  onChanged: (bool v) => setState(() => _agreed = v),
)

// "Pilih semua" dengan tanda strip saat sebagian terpilih
IddsCheckbox(
  value: allSelected,
  indeterminate: _selected.isNotEmpty && !allSelected,
  label: 'Semua hobi',
  onChanged: (bool v) => setState(() => v ? _selected.addAll(all) : _selected.clear()),
)
''';

const String _radioCode = r'''
IddsRadioGroup<String>(
  label: 'Jenis kelamin',
  required: true,
  value: _gender,
  error: _gender == null,
  helperText: _gender == null ? 'Wajib dipilih.' : null,
  options: const [
    IddsRadioOption(value: 'L', label: 'Laki-laki'),
    IddsRadioOption(value: 'P', label: 'Perempuan'),
  ],
  onChanged: (String v) => setState(() => _gender = v),
)
''';

const String _toggleCode = r'''
IddsToggle(
  value: _notifications,
  size: IddsToggleSize.md, // sm atau md
  semanticLabel: 'Notifikasi',
  onChanged: (bool v) => setState(() => _notifications = v),
)
''';
