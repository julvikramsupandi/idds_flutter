import 'package:flutter/widgets.dart';
import 'package:idds_flutter/idds_flutter.dart';

/// Membungkus [child] dengan WidgetsApp + IddsTheme + Overlay untuk widget
/// test.
Widget testApp(Widget child, {IddsThemeData? theme}) {
  return WidgetsApp(
    color: const Color(0xFF000000),
    builder: (BuildContext context, Widget? _) => IddsTheme(
      data: theme ?? IddsThemeData(),
      child: _OverlayHost(
        // Latar penuh agar menekan area kosong tetap terdeteksi (seperti
        // Scaffold di aplikasi), dibutuhkan TapRegion "tekan di luar".
        child: ColoredBox(
          color: const Color(0xFFFFFFFF),
          child: Center(child: Padding(padding: const EdgeInsets.all(16), child: child)),
        ),
      ),
    ),
  );
}

/// Overlay (dibutuhkan popover) yang ikut diperbarui saat [child] berubah.
class _OverlayHost extends StatefulWidget {
  const _OverlayHost({required this.child});

  final Widget child;

  @override
  State<_OverlayHost> createState() => _OverlayHostState();
}

class _OverlayHostState extends State<_OverlayHost> {
  late final OverlayEntry _entry = OverlayEntry(builder: (BuildContext context) => widget.child);

  @override
  void didUpdateWidget(_OverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) => Overlay(initialEntries: <OverlayEntry>[_entry]);
}
