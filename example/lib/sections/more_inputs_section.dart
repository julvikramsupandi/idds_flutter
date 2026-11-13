import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class TextAreaSection extends StatelessWidget {
  const TextAreaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const GallerySection(
      title: 'Text Area',
      subtitle: 'Isian teks beberapa baris dengan penghitung karakter.',
      usage:
          'Untuk teks panjang seperti alamat atau keterangan. minLines/maxLines mengatur tinggi; setelah maxLines isi bisa digulir.',
      code: _textAreaCode,
      children: <Widget>[
        SizedBox(
          width: 360,
          child: IddsTextArea(
            label: Text('Alamat lengkap'),
            placeholder: 'Jalan, RT/RW, kelurahan, kecamatan',
            maxLength: 200,
            showCharCount: true,
          ),
        ),
      ],
    );
  }
}

class PasswordSection extends StatelessWidget {
  const PasswordSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const GallerySection(
      title: 'Password',
      subtitle: 'Tombol mata untuk menampilkan atau menyembunyikan isi.',
      usage:
          'IddsPasswordField menerima parameter yang sama dengan IddsTextField (controller, status, statusMessage) dan menyembunyikan isi secara bawaan.',
      code: _passwordCode,
      children: <Widget>[
        SizedBox(
          width: 360,
          child: IddsPasswordField(
            label: Text('Kata sandi'),
            required: true,
            helperText: 'Minimal 8 karakter',
          ),
        ),
      ],
    );
  }
}

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  String _query = '';
  bool _searching = false;

  Future<void> _search(String q) async {
    setState(() {
      _query = q;
      _searching = q.isNotEmpty;
    });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Search',
      subtitle: 'Pencarian dengan jeda ketik dan indikator memuat.',
      usage:
          'IddsSearchField memanggil onSearch 300 ms setelah pengguna berhenti mengetik (atur lewat debounce). Isi loading selama hasil dimuat.',
      code: _searchCode,
      children: <Widget>[
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IddsSearchField(
                label: const Text('Cari layanan'),
                loading: _searching,
                onSearch: _search,
              ),
              const SizedBox(height: IddsSpacing.s4),
              GalleryCaption(
                _query.isEmpty
                    ? 'Ketik untuk mencari (jeda 300 ms)'
                    : 'Mencari: "$_query"',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PhoneInputSection extends StatefulWidget {
  const PhoneInputSection({super.key});

  @override
  State<PhoneInputSection> createState() => _PhoneInputSectionState();
}

class _PhoneInputSectionState extends State<PhoneInputSection> {
  String _phone = '+6281234567890';

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Phone Input',
      subtitle: 'Pilihan kode negara (239 negara) dan nomor telepon.',
      usage:
          'Nilai disimpan dalam format internasional, misalnya +6281234567890. Kode negara bawaan Indonesia (+62).',
      code: _phoneCode,
      children: <Widget>[
        SizedBox(
          width: 360,
          child: IddsPhoneInput(
            label: const Text('Nomor WhatsApp'),
            value: _phone,
            helperText: 'Nilai: $_phone',
            onChanged: (String v) => setState(() => _phone = v),
          ),
        ),
      ],
    );
  }
}

class OtpSection extends StatefulWidget {
  const OtpSection({super.key});

  @override
  State<OtpSection> createState() => _OtpSectionState();
}

class _OtpSectionState extends State<OtpSection> {
  String _otp = '';
  bool _otpError = false;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'OTP',
      subtitle: 'Kotak kode satu baris yang menyusut mengikuti lebar layar.',
      usage:
          'onCompleted dipanggil saat semua kotak terisi. Tekan lama kotak untuk menu "Tempel"; IddsOtpInput.codeFromText mengambil kode dari teks bebas (mis. isi SMS).',
      code: _otpCode,
      children: <Widget>[
        IddsOtpInput(
          title: 'Verifikasi nomor',
          description:
              'Masukkan 6 digit kode yang dikirim ke 0812****7890. Coba 123456, atau salin lalu tekan lama kotak → Tempel.',
          value: _otp,
          error: _otpError,
          helperText: _otpError ? 'Kode salah, coba lagi.' : null,
          onChanged: (String v) => setState(() {
            _otp = v;
            _otpError = false;
          }),
          onCompleted: (String v) {
            if (v == '123456') {
              showGallerySnack(context, 'Kode benar');
            } else {
              setState(() => _otpError = true);
            }
          },
        ),
      ],
    );
  }
}

class TimePickerSection extends StatefulWidget {
  const TimePickerSection({super.key});

  @override
  State<TimePickerSection> createState() => _TimePickerSectionState();
}

class _TimePickerSectionState extends State<TimePickerSection> {
  IddsTime? _startTime = const IddsTime(8, 0);
  IddsTime? _endTime;

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: 'Time Picker',
      subtitle: 'Format 24 jam dan 12 jam, langkah menit, dan batas waktu.',
      usage:
          'Nilai bertipe IddsTime (jam, menit). minuteStep membatasi pilihan menit; minTime/maxTime membatasi rentang, misalnya jam selesai setelah jam mulai.',
      code: _timeCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s24,
          runSpacing: IddsSpacing.s24,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: IddsTimePicker(
                label: const Text('Jam mulai'),
                value: _startTime,
                minuteStep: 15,
                onChanged: (IddsTime? t) => setState(() => _startTime = t),
              ),
            ),
            SizedBox(
              width: 220,
              child: IddsTimePicker(
                label: const Text('Jam selesai (12 jam)'),
                value: _endTime,
                use12Hours: true,
                minTime: _startTime,
                helperText: _startTime == null
                    ? null
                    : 'Setelah ${_startTime!.format()}',
                onChanged: (IddsTime? t) => setState(() => _endTime = t),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const String _textAreaCode = r'''
const IddsTextArea(
  label: Text('Alamat lengkap'),
  maxLength: 200,
  showCharCount: true,
  minLines: 3,
  maxLines: 6,
)
''';

const String _passwordCode = r'''
IddsPasswordField(
  controller: _passwordController,
  label: const Text('Kata sandi'),
  required: true,
  helperText: 'Minimal 8 karakter',
)
''';

const String _searchCode = r'''
IddsSearchField(
  label: const Text('Cari layanan'),
  loading: _searching,
  onSearch: (String q) => search(q), // dipanggil 300 ms setelah berhenti mengetik
)
''';

const String _phoneCode = r'''
IddsPhoneInput(
  label: const Text('Nomor WhatsApp'),
  value: _phone, // mis. '+6281234567890'
  onChanged: (String v) => setState(() => _phone = v),
)
''';

const String _otpCode = r'''
// Tekan lama kotak → menu "Tempel" (label: pasteLabel).
IddsOtpInput(
  title: 'Verifikasi nomor',
  value: _otp,
  onChanged: (String v) => setState(() => _otp = v),
  onCompleted: (String code) => verify(code),
)

// Tombol tempel milik aplikasi: ambil kode dari isi papan klip.
final String code = IddsOtpInput.codeFromText(clipboardText); // '123456'
''';

const String _timeCode = r'''
IddsTimePicker(
  label: const Text('Jam mulai'),
  value: _startTime, // IddsTime?, mis. const IddsTime(8, 0)
  minuteStep: 15,
  onChanged: (IddsTime? t) => setState(() => _startTime = t),
)

IddsTimePicker(
  label: const Text('Jam selesai'),
  value: _endTime,
  use12Hours: true,
  minTime: _startTime,
  onChanged: (IddsTime? t) => setState(() => _endTime = t),
)
''';
