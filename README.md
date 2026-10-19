# IDDS Flutter

[![pub package](https://img.shields.io/pub/v/idds_flutter.svg)](https://pub.dev/packages/idds_flutter)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Port Flutter dari [INA Digital Design System (IDDS)](https://design.inadigital.go.id/):
token desain, tema multi-brand (terang/gelap), dan komponen UI yang mengikuti
spesifikasi `@idds/react` / `@idds/styles`. Berjalan di Android, iOS, web, dan
desktop.

*Bukan produk resmi INA Digital. Package ini dibuat secara independen agar
IDDS dapat dipakai di aplikasi Flutter.*

## Status

| Bagian | Status |
|---|---|
| Token (warna, tipografi, spacing, radius, shadow, durasi, breakpoint) | ✅ |
| Brand: Neutral, INAgov, INApas, INAku, PANRB, BKN, LAN, BGN | ✅ |
| Brand kustom (`fromSeed`, `fromPalette`, `fromScale`) | ✅ |
| Button, Badge, Avatar, Alert | ✅ |
| Text Input, Checkbox, Radio, Toggle | ✅ |
| Chip, Button Group, Breadcrumb, Tab Menu, Stepper, Pagination | ✅ |
| Dropdown: Select, Multi Select, Action, Basic | ✅ |
| Date Picker: satu tanggal, rentang, banyak tanggal, kalender | ✅ |
| File Upload, Single File Upload (tampilan saja) | ✅ |
| Modal, Drawer, Toast, Tooltip | ✅ |
| Accordion, Card, Divider, Spinner, Progress Bar, Skeleton | ✅ |
| Table (urutan, pilihan baris, pencarian, pagination, edit di sel, kolom aksi menempel) | ✅ |
| Text Area, Password, Search, Phone, OTP, Time Picker | ✅ |
| Month/Year Picker, Theme Toggle, Bottom Sheet, List, Multiple Choice Grid | ✅ |
| Chart: Line/Area, Bar (berkelompok, bertumpuk, mendatar), Pie/Donut | ✅ |

## Instalasi

```yaml
dependencies:
  idds_flutter: ^0.1.0
```

## Pemakaian

```dart
import 'package:flutter/material.dart';
import 'package:idds_flutter/idds_flutter.dart';
import 'package:idds_flutter/material.dart'; // opsional, untuk widget Material

void main() {
  final idds = IddsThemeData(brand: IddsBrand.inagov);
  runApp(MaterialApp(
    theme: idds.toMaterialTheme(),
    builder: (context, child) => IddsTheme(data: idds, child: child!),
    home: Scaffold(
      body: Center(
        child: IddsButton(
          onPressed: () {},
          prefixIcon: const Icon(Icons.save),
          child: const Text('Simpan'),
        ),
      ),
    ),
  ));
}
```

`IddsTheme` hanya bergantung pada `package:flutter/widgets.dart`, jadi bisa
dipakai juga dengan `CupertinoApp` atau `WidgetsApp`.

### Brand dan mode gelap

```dart
IddsThemeData(brand: IddsBrand.panrb, brightness: Brightness.dark)
```

Gunakan `AnimatedIddsTheme` agar pergantian brand atau mode gelap dianimasikan.

Beberapa nilai sengaja dibuat berbeda dari CSS IDDS karena nilai aslinya
tidak terbaca. Daftarnya ada di bagian [Penyesuaian dari IDDS](#penyesuaian-dari-idds).

### Brand kustom

```dart
// Dari satu warna. Skala 25–900, warna dark mode, dan warna teks dibuat otomatis.
IddsBrand.fromSeed(const Color(0xFF7C3AED), name: 'Ungu');

// Dari palet IDDS yang sudah dirancang desainer.
import 'package:idds_flutter/primitives.dart';
IddsBrand.fromPalette(IddsPrimitives.violet);
```

`fromSeed` membuat skala di ruang warna OKLCH dengan kurva terang-gelap yang
diturunkan dari brand resmi IDDS. Warna seed dipakai persis sebagai warna
utama. Warna teks di atasnya (putih/hitam) dipilih berdasarkan kontras WCAG.

### Token

```dart
final colors = IddsTheme.of(context).colors;
colors.contentPrimary;   // teks utama
colors.primaryMain;      // warna utama brand (mengikuti mode)
colors.negative.shade500;

IddsSpacing.s16;         // 16px (--ina-spacing-4)
IddsRadius.lg;           // 8px
IddsFontSize.sm;         // 14px
IddsShadow.md;           // List<BoxShadow>
```

Palet primitive (`IddsPrimitives`) sengaja diimpor terpisah lewat
`package:idds_flutter/primitives.dart`. Untuk layar dan komponen, pakai token
semantik.

### Ikon

IDDS memakai [Tabler Icons](https://tabler.io/icons). Ikon yang dibutuhkan
komponen sendiri (centang, panah, X, kalender, dll.) sudah ikut di package
ini sebagai `IddsIcons`, digambar dari SVG Tabler, jadi package tidak
bergantung pada package ikon apa pun.

Untuk ikon lain di aplikasi Anda, pakai package ikon Tabler, misalnya
[`flutter_tabler_icons`](https://pub.dev/packages/flutter_tabler_icons)
(dipakai di galeri contoh). Semua slot ikon di komponen menerima widget
apa saja:

```dart
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

IddsButton(
  prefixIcon: const Icon(TablerIcons.plus),
  onPressed: () {},
  child: const Text('Tambah'),
)
```

### Font

IDDS memakai font **Inter**, yang tidak dibundel di package ini. Pilih salah satu:

- Pakai [google_fonts](https://pub.dev/packages/google_fonts) lewat
  `textStyleBuilder` (dipakai galeri contoh). Font diunduh saat pertama
  dipakai lalu disimpan di cache:

  ```dart
  TextStyle inter(TextStyle style) => GoogleFonts.inter(textStyle: style);

  IddsThemeData(brand: IddsBrand.inagov, textStyleBuilder: inter)
  ```

  Pakai fungsi tingkat atas (bukan lambda di dalam `build`) agar tema tidak
  dianggap berubah di setiap build. Jangan cukup mengisi
  `fontFamily: GoogleFonts.inter().fontFamily`: google_fonts mendaftarkan
  setiap ketebalan sebagai keluarga font tersendiri, sehingga cara itu hanya
  memuat ketebalan regular. Di macOS, tambahkan
  `com.apple.security.network.client` ke berkas `.entitlements`.
- Atau tambahkan file Inter (400, 500, 600, 700) ke aset aplikasi dan
  daftarkan dengan nama `Inter` di `pubspec.yaml` aplikasi Anda; tidak perlu
  internet.

Tanpa salah satunya, Flutter memakai font bawaan sistem.

### Ukuran di layar kecil

Seperti versi web, komponen mengecil satu tingkat saat lebar layar di bawah
640px (misalnya Button `md` dari 40px menjadi 32px). Matikan dengan
`IddsThemeData(compactOnSmallScreens: false)`.

### Komponen

```dart
IddsBadge(variant: IddsBadgeVariant.success, child: Text('Aktif'))

IddsAvatar(image: NetworkImage(url), initials: 'JS')

IddsAlert(
  variant: IddsAlertVariant.caution,
  title: Text('Sesi hampir berakhir'),
  message: Text('Simpan pekerjaan Anda.'),
  onDismiss: () {},
)

IddsTextField(
  label: Text('Email'),
  required: true,
  status: IddsTextFieldStatus.error,
  statusMessage: 'Format email tidak valid.',
)

IddsCheckbox(value: agreed, onChanged: (v) {}, label: 'Saya setuju')

IddsRadioGroup<String>(
  label: 'Jenis kelamin',
  value: gender,
  onChanged: (v) {},
  options: [
    IddsRadioOption(value: 'L', label: 'Laki-laki'),
    IddsRadioOption(value: 'P', label: 'Perempuan'),
  ],
)

IddsToggle(value: notificationsOn, onChanged: (v) {}, semanticLabel: 'Notifikasi')

IddsChipGroup<int>(
  selected: {30},
  onChanged: (v) {},
  options: [
    IddsChipOption(value: 7, label: '7 hari'),
    IddsChipOption(value: 30, label: '30 hari'),
  ],
  // Chip "Kustomisasi" dengan kolom isian angka.
  customization: IddsChipCustomization.integer(suffix: 'hari'),
)

IddsTabMenu<String>(value: tab, onChanged: (v) {}, items: [
  IddsTabItem(value: 'profil', label: Text('Profil')),
  IddsTabItem(value: 'dokumen', label: Text('Dokumen')),
])

IddsStepper(currentStep: 1, steps: [
  IddsStep(label: 'Data diri'),
  IddsStep(label: 'Dokumen'),
])

IddsPagination(
  currentPage: page,
  totalPages: 12,
  onPageChanged: (p) {},
  pageSize: 10,
  onPageSizeChanged: (n) {},
)

IddsSelect<String>(
  label: Text('Provinsi'),
  searchable: true,
  value: province,
  onChanged: (v) {},
  options: [
    IddsSelectOption(value: 'jabar', label: 'Jawa Barat'),
    IddsSelectOption(value: 'jateng', label: 'Jawa Tengah'),
  ],
)

IddsMultiSelect<String>(values: {'ktp'}, onChanged: (v) {}, showPreview: true, options: [
  IddsSelectOption(value: 'ktp', label: 'KTP Elektronik'),
  IddsSelectOption(value: 'kk', label: 'Kartu Keluarga'),
])

IddsDatePicker(
  label: Text('Tanggal lahir'),
  value: birthDate,
  onChanged: (d) {},
  disableFuture: true,
)

IddsDateRangePicker(value: leaveRange, onChanged: (r) {}) // IddsDateRange(start, end)

IddsMultiDatePicker(values: meetingDates, onChanged: (v) {})

// Format tanggal berbahasa Indonesia tanpa package intl.
iddsFormatDate(DateTime(2026, 8, 17), 'EEEE, d MMMM yyyy') // Senin, 17 Agustus 2026

// File Upload hanya tampilan: pilih & unggah berkas di aplikasi Anda.
IddsFileUpload(
  label: Text('Dokumen pendukung'),
  files: [
    IddsUploadFile(name: 'ktp.pdf', size: 245760, status: IddsFileStatus.success),
    IddsUploadFile(name: 'kk.pdf', size: 870400, status: IddsFileStatus.uploading, progress: 0.4),
  ],
  onPick: () async {
    // contoh dengan package file_picker:
    // final result = await FilePicker.platform.pickFiles(allowMultiple: true);
  },
  onRemove: (i) {},
)

IddsSingleFileUpload(file: taxFile, onPick: () {}, onRemove: () {})

final bool? confirmed = await showIddsModal<bool>(
  context: context,
  builder: (context) => IddsModal(
    title: Text('Hapus dokumen?'),
    actions: [
      IddsButton(onPressed: () => Navigator.pop(context, false), child: Text('Batal')),
      IddsButton(onPressed: () => Navigator.pop(context, true), child: Text('Hapus')),
    ],
    child: Text('Dokumen yang dihapus tidak bisa dikembalikan.'),
  ),
);

showIddsDrawer(
  context: context,
  position: IddsDrawerPosition.right,
  builder: (context) => IddsDrawer(title: const Text('Filter'), child: FilterForm()),
);

showIddsToast(
  context: context,
  title: Text('Data berhasil disimpan'),
  state: IddsToastState.positive, // normal, destructive, positive
  position: IddsToastPosition.topRight,
)

IddsTooltip(message: 'Unduh dokumen', child: IddsButton(onPressed: () {}, child: Text('Unduh')))

IddsAccordionGroup(items: [
  IddsAccordionItem(title: Text('Siapa yang bisa mendaftar?'), child: Text('...')),
  IddsAccordionItem(title: Text('Dokumen apa saja?'), child: Text('...')),
])

IddsCard(
  media: Image.network(url, fit: BoxFit.cover),
  title: Text('Beasiswa 2026'),
  description: Text('Pendaftaran dibuka hingga 30 November.'),
  action: IddsButton(onPressed: () {}, child: Text('Daftar')),
)

IddsSpinner(title: 'Memuat data')
IddsProgressBar(value: 0.4) // value: null = tak tentu
IddsSkeleton(height: 16)
IddsDivider(label: Text('atau'))

IddsTable<Employee>(
  rows: currentPageRows, // data diurutkan/dipotong oleh aplikasi
  columns: [
    IddsTableColumn(
      header: 'Nama',
      sortKey: 'name',
      cell: (context, p) => Text(p.name),
      // Ketuk sel untuk mengedit; Enter menyimpan, Esc membatalkan.
      editor: IddsTableCellEditor(
        value: (p) => p.name,
        validator: (v) => v.trim().isEmpty ? 'Nama wajib diisi' : null,
        onSubmitted: (p, v) => saveName(p, v),
      ),
    ),
    IddsTableColumn(header: 'Unit', cell: (context, p) => Text(p.unit)),
    IddsTableColumn(header: 'Aksi', cell: (context, p) => actionButton(p)),
  ],
  stickyLastColumn: true, // kolom Aksi tetap terlihat saat digeser
  sort: sort,
  onSortChanged: (s) {},
  page: page,
  totalPages: totalPages,
  onPageChanged: (p) {},
)

IddsTextArea(label: Text('Alamat'), maxLength: 200, showCharCount: true)
IddsPasswordField(label: Text('Kata sandi'))
IddsSearchField(onSearch: (q) {}) // jeda 300 ms
IddsPhoneInput(value: '+6281234567890', onChanged: (v) {}) // 239 negara
IddsOtpInput(length: 6, value: otpCode, onChanged: (v) {}, onCompleted: (v) {})
IddsTimePicker(value: IddsTime(8, 0), minuteStep: 15, onChanged: (t) {})

IddsMonthPicker(value: 8, onChanged: (m) {})
IddsYearPicker(value: 2026, onChanged: (y) {})
IddsThemeToggle(dark: dark, onChanged: (v) {}) // simpan di state, lalu ganti IddsThemeData
showIddsBottomSheet(context: context, builder: (context) => ...)
IddsList(children: [IddsListItem(title: Text('KTP'), onTap: () {})])
IddsChoiceGrid(rows: [...], columns: [...], selected: answers, onChanged: (v) {})

IddsActionMenu(items: [
  IddsActionMenuItem(label: 'Ubah', onTap: () {}),
  IddsActionMenuDivider(),
  IddsActionMenuItem(label: 'Hapus', onTap: () {}, type: IddsActionMenuItemType.danger),
])
```

`IddsFileUpload` dan `IddsSingleFileUpload` tidak membuka pemilih berkas dan
tidak membaca isi berkas, sehingga package ini tetap tanpa dependensi
tambahan. Aplikasi memanggil pemilih berkas di `onPick` (misalnya
`file_picker`), mengunggah sendiri, lalu memperbarui `IddsUploadFile.status`
dan `progress`. `iddsValidateFile` memeriksa nama, ekstensi, dan ukuran dengan
pesan yang sama seperti versi web; untuk seret-dan-lepas di web/desktop pakai
package seperti `desktop_drop` dan isi `dragOver`. Validasi isi berkas (magic
number) sebaiknya tetap dilakukan di server.

`showIddsModal` dan `showIddsDrawer` membutuhkan `Navigator` (sudah ada di
`MaterialApp`/`CupertinoApp`). Tema IDDS dari halaman pemanggil ikut terbawa,
jadi `IddsTheme` tidak harus membungkus seluruh aplikasi. Modal dan drawer
tertutup dengan tombol X, Esc, atau menekan latar (bisa dimatikan dengan
`barrierDismissible: false`).

Dropdown memakai `Overlay`, yang sudah disediakan `MaterialApp`,
`CupertinoApp`, atau `WidgetsApp` dengan Navigator. Panel otomatis pindah ke
atas bila ruang di bawah tidak cukup, tertutup saat menekan di luar atau Esc,
dan bisa dinavigasi dengan panah atas/bawah dan Enter. Untuk panel dengan
isi bebas, pakai `IddsDropdown` atau `IddsPopover` langsung. Bila lebar panel
tidak ditentukan, panel mengikuti lebar isinya, jadi hindari `ListView`
langsung di dalamnya (pakai `SingleChildScrollView` + `Column`, atau
tentukan `width`).

Semua komponen interaktif bisa dipakai dengan keyboard (Tab, Enter, Space),
menampilkan cincin fokus, dan memberi informasi ke pembaca layar.

`IddsTextField` memakai `TextField` Material di dalamnya (untuk seleksi
teks, salin/tempel, dan autofill), begitu juga kolom pencarian dropdown dan
isian halaman Pagination. Semuanya tetap bisa dipakai di `WidgetsApp` atau
`CupertinoApp`. Komponen lain hanya bergantung pada
`package:flutter/widgets.dart`.

### Grafik

IDDS untuk web (React dan Vue) tidak punya komponen grafik; situs IDDS hanya
memberi panduan Line, Bar, dan Pie Chart serta palet warnanya. Package ini
menyediakan tiga grafik sederhana yang digambar sendiri tanpa dependensi:

```dart
IddsLineChart(
  labels: const ['Jan', 'Feb', 'Mar', 'Apr'],
  area: true,
  series: const [
    IddsChartSeries(name: 'Permohonan', values: [1200, 1350, 1280, 1510]),
    IddsChartSeries(name: 'Selesai', values: [1100, 1240, null, 1390]),
  ],
)

IddsBarChart(
  labels: const ['Kota Gorontalo', 'Kab. Gorontalo', 'Bone Bolango'],
  horizontal: true, // atau stacked: true
  showValues: true,
  series: const [IddsChartSeries(name: 'Penerima', values: [4200, 5100, 2150])],
)

IddsPieChart(
  donut: true,
  centerLabel: 'Pengajuan',
  slices: const [
    IddsChartSlice(label: 'Aplikasi', value: 5400),
    IddsChartSlice(label: 'Loket', value: 1800),
  ],
)
```

Warna diambil dari `IddsChartColors.categorical` sesuai urutan seri (bisa
diganti per seri lewat `color`). Legenda tampil otomatis bila ada dua seri
atau lebih, sorot atau ketuk grafik untuk melihat tooltip, dan nilai `null`
membuat garis terputus. Angka diringkas dengan `iddsCompactNumber`
(1,2 rb, 3,4 jt, 5 M); ganti lewat `valueFormat`.

Untuk grafik yang lebih rumit (zoom, sumbu waktu, scatter, dll.), pakai
package grafik lain dengan palet IDDS, misalnya `fl_chart`:

```dart
LineChart(LineChartData(
  lineBarsData: [
    for (final (i, data) in seriesSpots.indexed)
      LineChartBarData(
        spots: data,
        color: IddsChartColors.categorical[i],
        barWidth: 2,
        dotData: const FlDotData(show: false),
      ),
  ],
  gridData: FlGridData(
    drawVerticalLine: false,
    getDrawingHorizontalLine: (_) =>
        FlLine(color: IddsTheme.of(context).colors.strokePrimary, strokeWidth: 1),
  ),
))
```

`IddsChartColors.sequential` (7 tingkat biru) cocok untuk peta panas atau
data bertingkat, dan `IddsChartColors.single` untuk grafik satu seri.

## Penyesuaian dari IDDS

Package ini mengikuti `@idds/styles` sedekat mungkin. Nilai berikut sengaja
diubah karena di CSS aslinya tidak terbaca atau hilang di dark mode:

| Komponen | CSS IDDS | idds_flutter |
|---|---|---|
| Brand Neutral, dark mode | Warna utama `#141414` sama dengan latar | Dibalik: putih, teks gelap |
| Badge soft brand / neutral, dark mode | Teks sewarna dengan latar | Teks warna brand terang / `content-primary` |
| Badge fill brand | Teks `primary-25` | Teks `onPrimary` |
| Alert caution | Judul & ikon `warning-500` (kontras ±1,6:1) | `warning-600` |
| Alert berwarna, dark mode | Deskripsi `content-primary` (putih di atas latar terang) | Teks gelap tetap |
| Radio, hover | Latar `neutral-50` (terang di dark mode) | `background-secondary` |
| Text Input, status warning | Pesan `warning-500` (kontras ±1,8:1) | `warning-600` |
| Chip, dark mode | Teks `content-primary` di atas latar terang, latar outline `neutral-25` | Teks gelap tetap, latar `background-primary` |
| Chip filled terpilih | Teks putih di atas `primary-300` (tidak terbaca di brand terang) | Putih/hitam sesuai kontras |
| Button Group & Tab Menu, dark mode | Teks `primary-25`/warna utama di atas latar yang sama terang | `onPrimary` / warna utama mode terang |
| Pagination & Breadcrumb, fokus | Latar `neutral-100` (terang di dark mode) | `background-tertiary` |
| Chip Kustomisasi | Label tetap "Kustomisasi"; lebar isian 25% wadah | Label menampilkan nilai ("Kustomisasi: 45 hari", bisa dimatikan); lebar isian minimal 200px |
| Date Picker satu tanggal | Panel tetap terbuka setelah memilih | Panel tertutup setelah memilih |
| Date Picker, pilih bulan/tahun | Dropdown kecil di kepala kalender | Grid bulan/tahun di dalam panel |
| Date Picker rentang, dua bulan | Kedua bulan bisa digeser terpisah | Bulan kedua selalu bulan berikutnya |
| Date Picker, tanggal terpilih | Teks `base-white` (tak terbaca di brand Neutral dark) | `onPrimary` |
| File Upload, bilah kemajuan | `primary-300` (abu-abu muda di brand Neutral) | Warna utama brand |
| File Upload, pesan error & "Lihat Selengkapnya", dark mode | Latar `error-25` terang, teks `primary-500` | Latar biasa, warna versi gelap |
| Modal, lebar bawaan | Mengikuti isi, minimal 480px | Tetap 480px (`IddsModalSize.sm`), dibatasi lebar layar |
| Drawer kiri/kanan, sudut | Sudut membulat di sisi yang menempel tepi layar | Sudut membulat di sisi yang menghadap halaman |
| Toast gaya outline | Ikon selalu putih (tidak terlihat di latar terang) | Ikon mengikuti warna teks |
| Tooltip kartu, tombol "Lanjut" | Teks `white` di atas warna brand | `onPrimary` |
| Skeleton & Spinner, dark mode | Warna `neutral-200`/`neutral-300` dan warna 100 (terang) | Latar tersier / garis tepi / warna 800 |
| Table, teks kosong | "No data found" | "Data tidak ditemukan" |
| Table, sel yang bisa diedit | Label isian berisi teks placeholder di atas isian; latar sel `primary-50` dan hover tombol `neutral-100` (terang di dark mode) | Placeholder sebagai petunjuk di dalam isian; ada validasi dengan pesan galat; di dark mode latar sekunder/tersier |
| Table, kolom terakhir menempel | Tanpa pemisah | Garis kiri dan bayangan tipis saat ada isi tabel di belakangnya |
| Phone Input, bendera | Gambar bendera | Emoji bendera (huruf kode negara bila font emoji tidak tersedia) |
| Time Picker, tombol "Pilih" | Teks putih di atas `content-primary` (tak terbaca di dark mode) | Warna latar halaman |
| Menu aksi, dark mode | Fokus berlatar `primary-100`, hover bahaya `negative-100`, teks warna 600 | Latar netral, teks warna 400 |
| Chart | Hanya panduan dan palet, tanpa komponen | `IddsLineChart`, `IddsBarChart`, `IddsPieChart` |
| Theme Toggle | Lintasan bulat `neutral-300`/`primary-500` di belakang ikon (bulan biru tertutup lintasan biru di dark mode); hover `background-secondary` (nyaris tak terlihat) | Tanpa lintasan; hover `background-tertiary` seperti tombol tertiary |
| Chart, palet kategori | Beberapa warna mirip (merah `#FF5C5C` dan oranye `#FF8806`; ungu `#8770FF` dan biru `#0AA7FF` bagi buta warna) dan terlalu terang di latar putih (`#44CCD5`, `#FFCC14`, `#4CE160`) | Urutan resmi tetap dipakai, tetapi identitas seri tidak hanya lewat warna: legenda selalu tampil untuk 2+ seri, tooltip menyebut nama seri, ada celah 2px antar segmen, dan teks memakai warna teks. Batasi 4–5 seri, atau atur `color` sendiri |

Daftar perbedaan token antara Figma dan CSS ada di `tool/reports/figma-diff.md`.

## Pengembangan

Token di `lib/src/tokens/` **dibuat otomatis** dari `@idds/styles`. Jangan
diedit manual.

```sh
cd tool
npm install
npm run generate
```

Untuk memperbarui ke versi IDDS terbaru, ubah versi `@idds/styles` di
`tool/package.json`, lalu jalankan ulang perintah di atas. Generator juga
menulis `tool/reports/figma-diff.md`, yang berisi semua nilai yang berbeda
antara Figma (`tool/figma/`) dan CSS.

```sh
flutter analyze
flutter test
cd example && flutter create . && flutter run
```

## Lisensi

MIT. Token diturunkan dari `@idds/styles` (MIT) milik INA Digital dan ikon
dari Tabler Icons (MIT); lihat
[LICENSE](LICENSE). Nama dan logo INA Digital serta lembaga pemerintah yang
disebut di tema brand adalah milik pemiliknya masing-masing.
