import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class MoreInputsSection extends StatefulWidget {
  const MoreInputsSection({super.key});

  @override
  State<MoreInputsSection> createState() => _MoreInputsSectionState();
}

class _MoreInputsSectionState extends State<MoreInputsSection> {
  String _phone = '+6281234567890';
  String _otp = '';
  bool _otpError = false;
  IddsTime? _startTime = const IddsTime(8, 0);
  IddsTime? _endTime;
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
      title: 'Input lainnya',
      subtitle: 'Text Area, Password, Search, Phone, OTP, dan Time Picker.',
      usage: 'IddsSearchField memanggil onSearch 300 ms setelah pengguna berhenti mengetik. IddsPhoneInput menyimpan nilai dalam format internasional (+6281234567890). IddsTimePicker memakai IddsTime.',
      code: _inputsCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s24,
          runSpacing: IddsSpacing.s24,
          children: <Widget>[
            const SizedBox(
              width: 320,
              child: IddsTextArea(
                label: Text('Alamat lengkap'),
                placeholder: 'Jalan, RT/RW, kelurahan, kecamatan',
                maxLength: 200,
                showCharCount: true,
              ),
            ),
            const SizedBox(
              width: 320,
              child: IddsPasswordField(
                label: Text('Kata sandi'),
                required: true,
                helperText: 'Minimal 8 karakter',
              ),
            ),
            SizedBox(
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IddsSearchField(
                    label: const Text('Cari layanan'),
                    loading: _searching,
                    onSearch: _search,
                  ),
                  const SizedBox(height: IddsSpacing.s4),
                  GalleryCaption(_query.isEmpty ? 'Ketik untuk mencari (jeda 300 ms)' : 'Mencari: "$_query"'),
                ],
              ),
            ),
            SizedBox(
              width: 320,
              child: IddsPhoneInput(
                label: const Text('Nomor WhatsApp'),
                value: _phone,
                helperText: 'Nilai: $_phone',
                onChanged: (String v) => setState(() => _phone = v),
              ),
            ),
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
                helperText: _startTime == null ? null : 'Setelah ${_startTime!.format()}',
                onChanged: (IddsTime? t) => setState(() => _endTime = t),
              ),
            ),
          ],
        ),
        const SizedBox(height: IddsSpacing.s24),
        IddsOtpInput(
          title: 'Verifikasi nomor',
          description: 'Masukkan 6 digit kode yang dikirim ke 0812****7890. Coba 123456.',
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

const String _inputsCode = r'''
const IddsTextArea(label: Text('Alamat'), maxLength: 200, showCharCount: true)

const IddsPasswordField(label: Text('Kata sandi'), required: true)

IddsSearchField(
  label: const Text('Cari layanan'),
  loading: _searching,
  onSearch: (String q) => search(q),
)

IddsPhoneInput(
  label: const Text('Nomor WhatsApp'),
  value: _phone,
  onChanged: (String v) => setState(() => _phone = v),
)

IddsTimePicker(
  label: const Text('Jam mulai'),
  value: _startTime, // IddsTime?, mis. const IddsTime(8, 0)
  minuteStep: 15,
  onChanged: (IddsTime? t) => setState(() => _startTime = t),
)

IddsOtpInput(
  title: 'Verifikasi nomor',
  value: _otp,
  onChanged: (String v) => setState(() => _otp = v),
  onCompleted: (String code) => verify(code),
)
''';
