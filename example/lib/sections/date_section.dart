import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';

import 'common.dart';

class DateSection extends StatefulWidget {
  const DateSection({super.key});

  @override
  State<DateSection> createState() => _DateSectionState();
}

class _DateSectionState extends State<DateSection> {
  DateTime? _birthDate;
  DateTime? _visitDate;
  IddsDateRange? _leaveRange;
  List<DateTime> _meetingDates = <DateTime>[];
  DateTime? _inline = DateTime.now();

  static bool _isWeekday(DateTime d) => d.weekday != DateTime.saturday && d.weekday != DateTime.sunday;

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    return GallerySection(
      title: 'Date Picker',
      subtitle: 'Satu tanggal, rentang (dua bulan di layar ≥ 768px), dan banyak tanggal. '
          'Tekan nama bulan atau tahun untuk melompat. Keyboard: panah, Page Up/Down, Enter, Esc.',
      usage: 'Nilai disimpan di state aplikasi dan diperbarui lewat onChanged. Batasi tanggal dengan disablePast/disableFuture, firstDate/lastDate, atau selectableDayPredicate. Pola dateFormat memakai nama hari dan bulan berbahasa Indonesia.',
      code: _dateCode,
      children: <Widget>[
        Wrap(
          spacing: IddsSpacing.s24,
          runSpacing: IddsSpacing.s24,
          children: <Widget>[
            SizedBox(
              width: 280,
              child: IddsDatePicker(
                label: const Text('Tanggal lahir'),
                required: true,
                value: _birthDate,
                disableFuture: true,
                helperText: 'Tanggal setelah hari ini tidak bisa dipilih',
                onChanged: (DateTime? d) => setState(() => _birthDate = d),
              ),
            ),
            SizedBox(
              width: 280,
              child: IddsDatePicker(
                label: const Text('Jadwal kunjungan (hari kerja)'),
                value: _visitDate,
                dateFormat: 'EEEE, d MMM yyyy',
                disablePast: true,
                firstDayOfWeek: DateTime.monday,
                selectableDayPredicate: _isWeekday,
                onChanged: (DateTime? d) => setState(() => _visitDate = d),
              ),
            ),
            SizedBox(
              width: 280,
              child: IddsDateRangePicker(
                label: const Text('Periode cuti'),
                value: _leaveRange,
                helperText: _leaveRange?.isComplete ?? false ? '${_leaveRange!.dayCount} hari' : null,
                onChanged: (IddsDateRange? r) => setState(() => _leaveRange = r),
              ),
            ),
            SizedBox(
              width: 280,
              child: IddsMultiDatePicker(
                label: const Text('Tanggal rapat'),
                size: IddsDropdownSize.sm,
                values: _meetingDates,
                onChanged: (List<DateTime> v) => setState(() => _meetingDates = v),
              ),
            ),
            SizedBox(
              width: 280,
              child: IddsDatePicker(
                label: const Text('Hanya-baca'),
                value: DateTime(2026, 8, 17),
                readOnly: true,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(
              width: 280,
              child: IddsDatePicker(label: Text('Nonaktif'), value: null, onChanged: null),
            ),
          ],
        ),
        const SizedBox(height: IddsSpacing.s24),
        const GalleryCaption('Kalender langsung di halaman (IddsCalendar)'),
        const SizedBox(height: IddsSpacing.s8),
        Container(
          padding: const EdgeInsets.all(IddsSpacing.s16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.strokePrimary),
            borderRadius: BorderRadius.circular(IddsRadius.xl),
          ),
          child: IddsCalendar(
            mode: IddsCalendarMode.single,
            selected: <DateTime>[if (_inline != null) _inline!],
            onChanged: (List<DateTime> d) => setState(() => _inline = d.isEmpty ? null : d.first),
          ),
        ),
        if (_inline != null) ...<Widget>[
          const SizedBox(height: IddsSpacing.s8),
          GalleryCaption('Terpilih: ${iddsFormatDate(_inline!, 'EEEE, d MMMM yyyy')}'),
        ],
      ],
    );
  }
}

const String _dateCode = r'''
DateTime? _birthDate;

IddsDatePicker(
  label: const Text('Tanggal lahir'),
  required: true,
  value: _birthDate,
  disableFuture: true,
  dateFormat: 'd MMMM yyyy',
  onChanged: (DateTime? d) => setState(() => _birthDate = d),
)

IddsDateRangePicker(
  label: const Text('Periode cuti'),
  value: _leaveRange, // IddsDateRange?
  onChanged: (IddsDateRange? r) => setState(() => _leaveRange = r),
)

IddsMultiDatePicker(
  label: const Text('Tanggal rapat'),
  values: _meetingDates, // List<DateTime>
  onChanged: (List<DateTime> v) => setState(() => _meetingDates = v),
)

// Kalender langsung di halaman
IddsCalendar(
  mode: IddsCalendarMode.single, // single, range, multiple
  selected: [if (_date != null) _date!],
  onChanged: (List<DateTime> d) => setState(() => _date = d.firstOrNull),
)

iddsFormatDate(DateTime(2026, 10, 16), 'EEEE, d MMMM yyyy'); // Jumat, 16 Oktober 2026
''';
