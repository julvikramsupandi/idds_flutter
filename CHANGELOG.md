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
