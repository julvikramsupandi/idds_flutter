import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'application_form_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'phone_frame.dart';

/// Contoh aplikasi layanan publik di tiga bingkai ponsel: Masuk, Beranda,
/// dan Form Pengajuan. Setiap bingkai bisa dicoba langsung.
class MobileShowcase extends StatelessWidget {
  const MobileShowcase({super.key, required this.brand});

  final IddsBrand brand;

  @override
  Widget build(BuildContext context) {
    final List<_Screen> screens = <_Screen>[
      _Screen(
        'Masuk',
        'Text Field, Password, Checkbox, Button, Divider, OTP di Bottom Sheet, Toast',
        LoginScreen(brand: brand),
      ),
      const _Screen(
        'Beranda Layanan',
        'Avatar, Badge, Search, Card, Progress Bar, List, Bottom Sheet. Pilih layanan lalu "Ajukan Sekarang".',
        HomeScreen(),
      ),
      const _Screen(
        'Form Pengajuan',
        'Stepper, Text Field, Date Picker, Select, Single File Upload, Text Area, Alert, Checkbox',
        ApplicationFormScreen(),
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Usahakan semua bingkai sebaris: bingkai diperkecil (layar di
        // dalamnya tetap 360px), paling kecil [_minScale]. Bila tidak muat,
        // jumlah per baris dikurangi.
        const double gap = IddsSpacing.s24;
        const double full = PhoneFrame.defaultOuterWidth;
        double width = full;
        for (int perRow = screens.length; perRow >= 1; perRow--) {
          final double fit =
              (constraints.maxWidth - gap * (perRow - 1)) / perRow;
          if (fit >= full * _minScale || perRow == 1) {
            width = math.min(full, fit);
            break;
          }
        }
        return SizedBox(
          width: constraints.maxWidth,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: gap,
            runSpacing: IddsSpacing.s40,
            children: <Widget>[
              for (final _Screen s in screens)
                SizedBox(width: width, child: _FramedScreen(screen: s)),
            ],
          ),
        );
      },
    );
  }
}

/// Skala terkecil bingkai sebelum pindah ke baris berikutnya; di bawah ini
/// teks 12px di dalam bingkai mulai sulit dibaca.
const double _minScale = 0.72;

class _Screen {
  const _Screen(this.title, this.components, this.child);

  final String title;
  final String components;
  final Widget child;
}

class _FramedScreen extends StatelessWidget {
  const _FramedScreen({required this.screen});

  final _Screen screen;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: PhoneFrame.defaultOuterWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PhoneFrame(child: screen.child),
          const SizedBox(height: IddsSpacing.s16),
          Text(
            screen.title,
            style: theme.textStyle(
              fontSize: IddsFontSize.base,
              lineHeight: IddsLineHeight.base,
              fontWeight: IddsFontWeight.semibold,
              color: c.contentPrimary,
            ),
          ),
          const SizedBox(height: IddsSpacing.s4),
          Text(
            screen.components,
            style: theme.textStyle(
                fontSize: IddsFontSize.xs,
                lineHeight: IddsLineHeight.xs,
                color: c.contentSecondary),
          ),
        ],
      ),
    );
  }
}
