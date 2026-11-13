## Belum dirilis

- `LICENSE` kini hanya berisi teks MIT standar agar dikenali pub.dev sebagai
  lisensi OSI. Catatan pihak ketiga (token `@idds/styles`, Tabler Icons,
  nama/logo instansi) dipindah ke berkas `NOTICE`.
- Seluruh kode diformat dengan `dart format` (lebar baris bawaan 80) agar
  lolos pemeriksaan analisis statis pub.dev. Tidak ada perubahan perilaku.

## 0.2.2

- `IddsButton`: isi tombol kini di tengah saat tombol dibuat selebar induk
  (mis. `SizedBox(width: double.infinity, child: IddsButton(...))`), sesuai
  CSS IDDS `justify-content: center`. Sebelumnya teks menempel di kiri.
- Galeri: Beranda kini dibuka dengan tab **Mobile**, berisi contoh aplikasi
  layanan publik (Masuk, Beranda Layanan, Form Pengajuan) di bingkai ponsel
  360px yang bisa dicoba langsung dari web. Contoh dasbor lama pindah ke tab
  **Web**.
- README & pub.dev: screenshot kini menampilkan enam layar aplikasi mobile
  (empat brand, mode terang dan gelap) dan dasbor web dengan tab baru.

## 0.2.1

Temuan dari pemakaian di aplikasi Godigi (Android/iOS).

- `IddsTextField`/`IddsPasswordField`: kotak input tidak lagi dipadatkan di
  layar < 640px. Tinggi tetap `sm` 40, `md` 44, `lg` 48 dan teks isian 14px
  (sebelumnya `md` 36px di HP, di bawah minimum IDDS 40px). Label dan teks
  bantuan tetap mengikuti mode compact.
- `IddsOtpInput`: kotak selalu satu baris dan menyusut mengikuti lebar induk
  (sebelumnya 6 kotak 40px + jarak 12px turun ke baris kedua di kartu HP
  320px). Jarak antarkotak 8px di layar ≤ 640px.
- `IddsOtpInput`: **tekan lama pada kotak memunculkan menu "Tempel"**
  (label `pasteLabel`). Sebelumnya tempel hanya lewat Ctrl/Cmd+V atau saran
  papan klip keyboard; di HP tidak ada menu tempel. Fungsi publik
  `IddsOtpInput.codeFromText` mengambil kode dari teks bebas (mis. pesan
  "Kode Anda 123 456") untuk tombol tempel milik aplikasi.
- `IddsAlert` di **dark mode**: latar varian berwarna kini gelap bernuansa
  (sebelumnya `*-100` terang yang menyilaukan), judul/ikon skala 300, teks
  `content-primary`. Mode terang: judul & ikon varian info dan critical memakai
  600 agar kontras ≥ 4,5:1. Test kontras untuk semua varian di kedua mode.
- `IddsTextField`/`IddsSearchField`: area tekan tombol hapus (✕) kini 40px ×
  tinggi kolom; ikon tetap 16px. Sebelumnya hanya 20 × 20px, sulit dikenai
  jari di HP.

## 0.2.0

Perbaikan dari pemakaian di aplikasi mobile (Android/iOS).

- **Perubahan perilaku:** `showIddsToast` kini bawaan `replaceExisting: true`
  (aturan IDDS: maksimal satu toast aktif). Isi `false` untuk menumpuk seperti
  0.1.x.
- `showIddsToast`/`dismissAllIddsToasts` bisa dipanggil dengan context di atas
  overlay (mis. `navigatorKey.currentContext`), atau parameter `overlay`.
  Sebelumnya gagal dengan "No Overlay widget found".
- `IddsAlert.action`: langkah lanjutan di bawah pesan.
- Tombol tutup Alert & Toast: area tekan 48dp tanpa mengubah tampilan.
- Toast di perangkat sentuh: masuk bergeser dari tepi, geser untuk menutup,
  timer dijeda selama disentuh, posisi bawah di atas keyboard.
- Toast saat pembaca layar aktif: durasi ×2; toast ber-aksi tidak tertutup
  otomatis.

## 0.1.1

- Menambahkan screenshot galeri untuk halaman pub.dev.
- README memuat cuplikan galeri.

## 0.1.0

Rilis pertama.

- Token desain hasil generate dari `@idds/styles` 1.6.38: palet primitive,
  8 brand (Neutral, INAgov, INApas, INAku, PANRB, BKN, LAN, BGN), warna
  semantik terang/gelap, tipografi, spacing, radius, shadow, durasi,
  breakpoint, dan warna grafik.
- `IddsTheme`, `AnimatedIddsTheme`, dan `IddsThemeData` (termasuk
  `textStyleBuilder` untuk font dari google_fonts).
- Brand kustom: `IddsBrand.fromSeed`, `IddsBrand.fromPalette`,
  `IddsBrand.fromScale`.
- Integrasi Material lewat `package:idds_flutter/material.dart`.
- Komponen: `IddsButton`, `IddsBadge`, `IddsAvatar`, `IddsAlert`,
  `IddsTextField`, `IddsCheckbox`, `IddsRadio`, `IddsRadioGroup`, `IddsToggle`,
  `IddsChip`, `IddsChipGroup`, `IddsButtonGroup`, `IddsBreadcrumb`,
  `IddsTabMenu`, `IddsStepper`, `IddsPagination` (dengan pilihan jumlah baris
  per halaman).
- Dropdown: `IddsSelect`, `IddsMultiSelect` (pencarian, pencarian server,
  muat lebih banyak, indikator centang/radio, pratinjau pilihan),
  `IddsActionMenu`, dan `IddsDropdown`.
- `IddsMonthPicker`, `IddsYearPicker`, `IddsThemeToggle`, `showIddsBottomSheet`
  (tarik untuk menutup, mode terkunci), `IddsList`/`IddsListItem`/
  `IddsListSubheader`, dan `IddsChoiceGrid` (Multiple Choice Grid).
- Input: `IddsTextArea` (juga `minLines`/`maxLines` di `IddsTextField`),
  `IddsPasswordField`, `IddsSearchField`, `IddsPhoneInput` (239 negara),
  `IddsOtpInput`, dan `IddsTimePicker` (`IddsTime`).
- `IddsTable`: kolom bisa diurutkan, pilihan baris, baris belang, status
  memuat, pencarian, pagination, edit langsung di sel
  (`IddsTableCellEditor`, `IddsTableFieldInput`), dan kolom terakhir yang
  menempel (`stickyLastColumn`); data dikelola aplikasi.
- Grafik tanpa dependensi: `IddsLineChart` (garis/area), `IddsBarChart`
  (berkelompok, bertumpuk, mendatar), dan `IddsPieChart` (lingkaran/donat),
  dengan legenda, tooltip, animasi, dan `iddsCompactNumber`.
- Accordion (`IddsAccordion`, `IddsAccordionGroup`, `IddsAccordionCard`,
  `IddsCollapse`), Card (`IddsCard` basic/horizontal/overlay, `IddsCardPlain`),
  `IddsDivider`, dan indikator memuat (`IddsSpinner`, `IddsProgressBar`,
  `IddsCircleProgress`, `IddsSkeleton`).
- Toast (`showIddsToast`, 8 posisi, solid/outline, tutup otomatis) dan
  Tooltip (`IddsTooltip`: gelembung, kartu terang/gelap/media, 12 posisi).
- Modal dan Drawer: `showIddsModal`/`IddsModal` (ukuran sm–full, judul,
  aksi, isi bergulir) dan `showIddsDrawer`/`IddsDrawer` (kanan, kiri, atas,
  bawah; panel dari bawah di layar kecil).
- Date Picker: `IddsDatePicker`, `IddsDateRangePicker`, `IddsMultiDatePicker`,
  dan `IddsCalendar` (navigasi keyboard, pilihan bulan/tahun, batas tanggal,
  hari pertama minggu bisa diatur). `iddsFormatDate`, `iddsParseDate`, dan
  `IddsDateRange`.
- File Upload (tampilan saja): `IddsFileUpload`, `IddsSingleFileUpload`,
  `IddsUploadFile`, `iddsFormatFileSize`, dan `iddsValidateFile`.
- Chip "Kustomisasi" lewat `IddsChipGroup.customization`
  (`IddsChipCustomization.text`, `IddsChipCustomization.integer`).
- `IddsPopover`: panel melayang yang menempel pada widget, dasar dropdown dan
  date picker; otomatis pindah ke atas dan bergeser agar tetap di dalam layar.
- `IddsIcon` dan `IddsIcons` (ikon garis Tabler yang dipakai komponen).
- Penyesuaian kontras dari CSS IDDS (lihat README, "Penyesuaian dari IDDS").
- Galeri contoh (`example/`): beranda bergaya dasbor dengan pilihan tema
  INAgov/PANRB/LAN/BKN, menu sidebar (layar lebar) atau drawer (layar
  sempit), satu halaman per kelompok komponen dengan penjelasan dan contoh
  kode bergaya editor VS Code yang bisa disalin, serta ikon Tabler.
