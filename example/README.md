# idds_flutter example

Galeri untuk mencoba brand, mode gelap, dan komponen idds_flutter.

- **Beranda**: contoh dasbor seperti bagian "Pilih Tema" di situs IDDS
  (formulir masuk, grafik lingkaran dan batang, kartu survei). Ganti tema
  INAgov/PANRB/LAN/BKN untuk melihat semua komponen ikut berubah.
- **Menu**: setiap kelompok komponen punya halaman sendiri. Di layar
  ≥ 1024px menu tampil sebagai sidebar; di layar lebih kecil dibuka lewat
  tombol menu (memakai `showIddsDrawer`).
- **Cara pakai**: setiap bagian diakhiri penjelasan singkat dan contoh kode
  Dart bergaya editor VS Code (nomor baris, pewarnaan sintaks dari
  [re_highlight](https://pub.dev/packages/re_highlight), tema terang/gelap)
  dengan tombol **Salin**.
- Pilihan brand dan mode gelap ada di bilah atas.
- Font **Inter** (font resmi IDDS) dimuat lewat
  [google_fonts](https://pub.dev/packages/google_fonts) dengan
  `IddsThemeData(textStyleBuilder: ...)`. Pertama kali dijalankan butuh
  internet; setelah itu font tersimpan di cache. Untuk macOS, folder
  `macos/Runner/*.entitlements` perlu `com.apple.security.network.client`.

```sh
cd example
flutter create . --platforms=android,ios,web,macos   # sekali saja, membuat folder platform
flutter run -d chrome                               # atau -d macos / perangkat lain
```
