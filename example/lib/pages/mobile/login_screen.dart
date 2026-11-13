import 'package:flutter/widgets.dart';
import 'package:idds_flutter/idds_flutter.dart';

import '../brand_logo.dart';
import 'phone_frame.dart';

/// Layar masuk aplikasi layanan publik: NIK/email, kata sandi, dan masuk
/// dengan kode OTP lewat bottom sheet.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.brand});

  final IddsBrand brand;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _account = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _accountError;
  String? _passwordError;
  bool _remember = true;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    setState(() {
      _accountError = _account.text.trim().isEmpty ? 'NIK atau email wajib diisi' : null;
      _passwordError = _password.text.isEmpty ? 'Kata sandi wajib diisi' : null;
    });
    if (_accountError != null || _passwordError != null) return;
    showPhoneToast(
      context,
      title: const Text('Berhasil masuk'),
      description: const Text('Ini hanya contoh; tidak ada data yang dikirim.'),
      state: IddsToastState.positive,
    );
  }

  void _openOtp() {
    showIddsBottomSheet<void>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) => const _OtpSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(IddsSpacing.s24, safe.top + IddsSpacing.s40, IddsSpacing.s24, safe.bottom + IddsSpacing.s24),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BrandLogo(brand: widget.brand, height: 36),
            const SizedBox(height: IddsSpacing.s32),
            Text(
              'Masuk ke akun Anda',
              style: theme.textStyle(
                fontSize: IddsFontSize.xl2,
                lineHeight: IddsLineHeight.xl,
                fontWeight: IddsFontWeight.semibold,
                color: c.contentPrimary,
              ),
            ),
            const SizedBox(height: IddsSpacing.s8),
            Text(
              'Gunakan NIK atau email yang terdaftar untuk mengakses layanan.',
              style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentSecondary),
            ),
            const SizedBox(height: IddsSpacing.s24),
            IddsTextField(
              controller: _account,
              label: const Text('NIK atau Email'),
              placeholder: 'Contoh: 7501xxxxxxxxxxxx',
              keyboardType: TextInputType.emailAddress,
              status: _accountError == null ? IddsTextFieldStatus.neutral : IddsTextFieldStatus.error,
              statusMessage: _accountError,
              onChanged: (_) {
                if (_accountError != null) setState(() => _accountError = null);
              },
            ),
            const SizedBox(height: IddsSpacing.s16),
            IddsPasswordField(
              controller: _password,
              label: const Text('Kata Sandi'),
              placeholder: 'Masukkan kata sandi',
              status: _passwordError == null ? IddsTextFieldStatus.neutral : IddsTextFieldStatus.error,
              statusMessage: _passwordError,
              onChanged: (_) {
                if (_passwordError != null) setState(() => _passwordError = null);
              },
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: IddsSpacing.s12),
            Row(
              children: <Widget>[
                Expanded(
                  child: IddsCheckbox(
                    value: _remember,
                    onChanged: (bool v) => setState(() => _remember = v),
                    label: 'Ingat saya',
                  ),
                ),
                IddsButton(
                  hierarchy: IddsButtonHierarchy.link,
                  onPressed: () => showPhoneToast(context, title: const Text('Tautan atur ulang kata sandi telah dikirim')),
                  child: const Text('Lupa kata sandi?'),
                ),
              ],
            ),
            const SizedBox(height: IddsSpacing.s24),
            IddsButton(onPressed: _login, child: const Text('Masuk')),
            const SizedBox(height: IddsSpacing.s16),
            const IddsDivider(label: Text('atau')),
            const SizedBox(height: IddsSpacing.s16),
            IddsButton(
              hierarchy: IddsButtonHierarchy.secondary,
              onPressed: _openOtp,
              child: const Text('Masuk dengan Kode OTP'),
            ),
            const SizedBox(height: IddsSpacing.s32),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: IddsSpacing.s4,
              children: <Widget>[
                Text(
                  'Belum punya akun?',
                  style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentSecondary),
                ),
                IddsButton(
                  hierarchy: IddsButtonHierarchy.link,
                  onPressed: () => showPhoneToast(context, title: const Text('Halaman pendaftaran belum tersedia di contoh ini')),
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpSheet extends StatefulWidget {
  const _OtpSheet();

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        IddsSpacing.s16,
        IddsSpacing.s8,
        IddsSpacing.s16,
        IddsSpacing.s16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: IddsSpacing.s16,
        children: <Widget>[
          IddsOtpInput(
            value: _code,
            title: 'Masukkan Kode OTP',
            description: 'Kode 6 digit telah dikirim ke nomor 0812-****-7890.',
            onChanged: (String v) => setState(() => _code = v),
          ),
          Text(
            'Contoh: isi 6 angka apa saja.',
            style: theme.textStyle(fontSize: IddsFontSize.xs, lineHeight: IddsLineHeight.xs, color: theme.colors.contentTertiary),
          ),
          IddsButton(
            onPressed: _code.length < 6
                ? null
                : () {
                    // Toast dipasang di Overlay bingkai sebelum panel ditutup.
                    showPhoneToast(context, title: const Text('Kode OTP terverifikasi'), state: IddsToastState.positive);
                    Navigator.pop(context);
                  },
            child: const Text('Verifikasi'),
          ),
        ],
      ),
    );
  }
}
