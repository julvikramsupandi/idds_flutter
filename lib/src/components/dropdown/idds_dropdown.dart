import 'package:flutter/widgets.dart';

import '../../foundation/idds_popover.dart';

/// Dropdown dasar: pemicu apa saja dengan panel berisi konten bebas
/// (Basic Dropdown IDDS).
///
/// ```dart
/// IddsDropdown(
///   triggerBuilder: (context, open, toggle) => IddsButton(
///     onPressed: toggle,
///     child: const Text('Filter'),
///   ),
///   contentBuilder: (context, close) => Padding(
///     padding: const EdgeInsets.all(16),
///     child: FilterForm(onApply: close),
///   ),
/// )
/// ```
///
/// Status terbuka bisa dikendalikan dari luar lewat [open] dan
/// [onOpenChanged]; bila [open] `null`, widget mengatur sendiri.
class IddsDropdown extends StatefulWidget {
  /// Membuat dropdown dasar.
  const IddsDropdown({
    super.key,
    required this.triggerBuilder,
    required this.contentBuilder,
    this.open,
    this.onOpenChanged,
    this.placement = IddsPopoverPlacement.bottomStart,
    this.matchTriggerWidth = false,
    this.width,
    this.maxHeight = 600,
    this.enabled = true,
    this.surface = true,
  });

  /// Membangun pemicu. [toggle] `null` bila [enabled] `false`.
  final Widget Function(BuildContext context, bool open, VoidCallback? toggle) triggerBuilder;

  /// Membangun isi panel. Panggil [close] untuk menutup.
  final Widget Function(BuildContext context, VoidCallback close) contentBuilder;

  /// Status terbuka (mode terkendali).
  final bool? open;

  /// Dipanggil saat status terbuka berubah.
  final ValueChanged<bool>? onOpenChanged;

  /// Posisi panel.
  final IddsPopoverPlacement placement;

  /// Panel minimal selebar pemicu.
  final bool matchTriggerWidth;

  /// Lebar tetap panel.
  final double? width;

  /// Tinggi maksimal panel.
  final double maxHeight;

  /// Apakah dropdown bisa dibuka.
  final bool enabled;

  /// Bungkus isi dengan [IddsPopoverSurface] (latar, garis tepi, bayangan).
  final bool surface;

  @override
  State<IddsDropdown> createState() => _IddsDropdownState();
}

class _IddsDropdownState extends State<IddsDropdown> {
  bool _open = false;

  bool get _isOpen => widget.enabled && (widget.open ?? _open);

  void _set(bool value) {
    if (value == _isOpen) return;
    if (widget.open == null) setState(() => _open = value);
    widget.onOpenChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool open = _isOpen;
    return IddsPopover(
      open: open,
      onDismiss: () => _set(false),
      placement: widget.placement,
      matchAnchorWidth: widget.matchTriggerWidth,
      width: widget.width,
      maxHeight: widget.maxHeight,
      panelBuilder: (BuildContext context) {
        final Widget content = widget.contentBuilder(context, () => _set(false));
        return widget.surface ? IddsPopoverSurface(child: content) : content;
      },
      child: widget.triggerBuilder(context, open, widget.enabled ? () => _set(!open) : null),
    );
  }
}
