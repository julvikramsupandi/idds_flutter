import 'package:flutter/foundation.dart' show immutable;

/// Nama hari dan bulan dalam bahasa Indonesia.
abstract final class IddsDateNames {
  /// Nama bulan lengkap, Januari = indeks 0.
  static const List<String> months = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Nama bulan singkat, Januari = indeks 0.
  static const List<String> shortMonths = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Nama hari lengkap, Senin = indeks 0 (sama dengan `DateTime.monday - 1`).
  static const List<String> weekdays = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// Nama hari singkat, Senin = indeks 0.
  static const List<String> shortWeekdays = <String>['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
}

/// Rentang tanggal untuk [IddsDateRangePicker]. [end] `null` berarti
/// pengguna baru memilih tanggal awal.
@immutable
class IddsDateRange {
  /// Membuat rentang. Bila [end] sebelum [start], keduanya ditukar.
  factory IddsDateRange({required DateTime start, DateTime? end}) {
    final DateTime s = iddsDateOnly(start);
    final DateTime? e = end == null ? null : iddsDateOnly(end);
    if (e != null && e.isBefore(s)) return IddsDateRange._(e, s);
    return IddsDateRange._(s, e);
  }

  const IddsDateRange._(this.start, this.end);

  /// Tanggal awal.
  final DateTime start;

  /// Tanggal akhir (inklusif), atau `null` bila belum dipilih.
  final DateTime? end;

  /// Rentang sudah lengkap.
  bool get isComplete => end != null;

  /// Jumlah hari, termasuk tanggal awal dan akhir. 1 bila belum lengkap.
  int get dayCount => end == null ? 1 : iddsDaysBetween(start, end!) + 1;

  /// Apakah [date] berada di dalam rentang (inklusif).
  bool contains(DateTime date) {
    final DateTime d = iddsDateOnly(date);
    final DateTime last = end ?? start;
    return !d.isBefore(start) && !d.isAfter(last);
  }

  @override
  bool operator ==(Object other) => other is IddsDateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'IddsDateRange($start, $end)';
}

/// Tanggal tanpa jam (tengah malam waktu lokal).
DateTime iddsDateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Apakah dua waktu jatuh pada tanggal yang sama.
bool iddsIsSameDay(DateTime? a, DateTime? b) =>
    a != null && b != null && a.year == b.year && a.month == b.month && a.day == b.day;

/// Selisih hari kalender dari [from] ke [to] (aman terhadap pergantian
/// jam musim panas).
int iddsDaysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// Jumlah hari dalam bulan.
int iddsDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// Tanggal 1 pada bulan [date] ditambah [months] bulan.
DateTime iddsAddMonths(DateTime date, int months) => DateTime(date.year, date.month + months);

/// Tanggal [date] ditambah [days] hari kalender.
DateTime iddsAddDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

/// Memformat tanggal dengan pola sederhana.
///
/// Token yang dikenali: `d`, `dd` (tanggal), `M`, `MM` (bulan angka), `MMM`
/// (Jan), `MMMM` (Januari), `yy`, `yyyy` (tahun), `EEE` (Sen), `EEEE`
/// (Senin). Karakter lain disalin apa adanya; teks di antara tanda kutip
/// tunggal tidak diproses.
///
/// ```dart
/// iddsFormatDate(DateTime(2026, 8, 17));                    // 17/08/2026
/// iddsFormatDate(DateTime(2026, 8, 17), 'EEEE, d MMMM yyyy'); // Senin, 17 Agustus 2026
/// ```
String iddsFormatDate(DateTime date, [String pattern = 'dd/MM/yyyy']) {
  final StringBuffer out = StringBuffer();
  int i = 0;
  while (i < pattern.length) {
    final String ch = pattern[i];
    if (ch == "'") {
      final int close = pattern.indexOf("'", i + 1);
      final int end = close < 0 ? pattern.length : close;
      out.write(pattern.substring(i + 1, end));
      i = end + 1;
      continue;
    }
    int run = 1;
    while (i + run < pattern.length && pattern[i + run] == ch) {
      run++;
    }
    switch (ch) {
      case 'd':
        out.write(run >= 2 ? '${date.day}'.padLeft(2, '0') : '${date.day}');
      case 'M':
        out.write(switch (run) {
          1 => '${date.month}',
          2 => '${date.month}'.padLeft(2, '0'),
          3 => IddsDateNames.shortMonths[date.month - 1],
          _ => IddsDateNames.months[date.month - 1],
        });
      case 'y':
        out.write(run == 2 ? '${date.year % 100}'.padLeft(2, '0') : '${date.year}');
      case 'E':
        out.write(run >= 4
            ? IddsDateNames.weekdays[date.weekday - 1]
            : IddsDateNames.shortWeekdays[date.weekday - 1]);
      default:
        out.write(ch * run);
    }
    i += run;
  }
  return out.toString();
}

/// Membaca tanggal berformat angka seperti `dd/MM/yyyy`, `yyyy-MM-dd`, atau
/// `d-M-yyyy`. Hanya token `d`, `M`, dan `y` yang didukung; pemisah apa saja.
/// Mengembalikan `null` bila tidak cocok atau tanggal tidak valid.
DateTime? iddsParseDate(String text, [String pattern = 'dd/MM/yyyy']) {
  final List<String> order = <String>[];
  final StringBuffer regex = StringBuffer('^');
  int i = 0;
  while (i < pattern.length) {
    final String ch = pattern[i];
    int run = 1;
    while (i + run < pattern.length && pattern[i + run] == ch) {
      run++;
    }
    if (ch == 'd' || ch == 'M') {
      order.add(ch);
      regex.write(r'(\d{1,2})');
    } else if (ch == 'y') {
      order.add(ch);
      regex.write(run == 2 ? r'(\d{2})' : r'(\d{4})');
    } else {
      regex.write(RegExp.escape(ch * run));
    }
    i += run;
  }
  regex.write(r'$');
  final RegExpMatch? match = RegExp(regex.toString()).firstMatch(text.trim());
  if (match == null) return null;
  int? day;
  int? month;
  int? year;
  for (int g = 0; g < order.length; g++) {
    final int value = int.parse(match.group(g + 1)!);
    switch (order[g]) {
      case 'd':
        day = value;
      case 'M':
        month = value;
      case 'y':
        year = value < 100 ? 2000 + value : value;
    }
  }
  if (day == null || month == null || year == null) return null;
  if (month < 1 || month > 12 || day < 1 || day > iddsDaysInMonth(year, month)) return null;
  return DateTime(year, month, day);
}
