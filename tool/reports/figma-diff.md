# Perbedaan token Figma vs @idds/styles

Dibuat otomatis oleh `tool/generate_tokens.mjs`. Sumber kebenaran untuk
idds_flutter adalah CSS `@idds/styles` 1.6.38; Figma hanya pembanding.

## Penyesuaian idds_flutter (sengaja berbeda dari CSS)

| Brand | Field | CSS | idds_flutter | Alasan |
|---|---|---|---|---|
| neutral | primaryMainDark | `#141414` | `#ffffff` | Di CSS, `--ina-primary-primary` brand default tetap `#141414` di dark mode, sama dengan `--ina-background-primary` gelap (kontras 1:1), sehingga tombol primary tidak terlihat. Dibalik menjadi putih. |
| neutral | onPrimaryDark | `#ffffff` | `#141414` | Teks di atas warna utama putih (lihat baris di atas) dibuat gelap. |

## Nilai Figma yang berbeda dari CSS (16)

| Area | Token | Figma | CSS (dipakai) |
|---|---|---|---|
| Primitives | Neutral/50 | `#fdfbfb` | `#f8f8f7` |
| Primitives (brand) | BKN/Primary/800 | `#801233` | `#871436` |
| Primitives (brand) | LAN/Primary/800 | `#193454` | `#1e3a5c` |
| Brand BGN | Primary/Primary (warna utama) | `#071e49` | `#0058ff` |
| Brand BKN | Primary/800 | `#801233` | `#871436` |
| Brand INAgov | Secondary/25 | `#ffffff00` | `#ffffff` |
| Brand INAgov | Secondary/50 | `#ffffff00` | `#ffffff` |
| Brand INAgov | Secondary/800 | `#ffffff00` | `#164564` |
| Brand INAgov | Secondary/900 | `#ffffff00` | `#0f2d42` |
| Brand LAN | Primary/800 | `#193454` | `#1e3a5c` |
| Brand Neutral | Primary/50 | `#fdfbfb` | `#f8f8f7` |
| Brand Neutral | Primary/100 | `#f2f2f2` | `#f5f5f5` |
| Product Light | Background/Secondary | `#fdfbfb` | `#f8f8f7` |
| Product Light | Content/Positive | `#3cc14e` | `#288034` |
| Product Light | Stroke/Secondary | `#737373` | `#a3a3a3` |
| Product Dark | Stroke/Tertiary | `#1f1f1f` | `#e5e5e5` |

## Brand yang hanya ada di CSS

- INApas
- INAku

## Warna secondary yang diwarisi dari `:root`

- INAgov: secondary 800, 900 tidak didefinisikan, memakai nilai `:root`
- INApas: secondary 25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900 tidak didefinisikan, memakai nilai `:root`
- INAku: secondary 25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900 tidak didefinisikan, memakai nilai `:root`

## Variabel brand khusus yang belum dipetakan ke Dart

- INAgov: `--ina-brand-hover`, `--ina-neutral-hover`
- INApas: `--ina-inapas-brand-hover`, `--ina-inapas-neutral-hover`
- INAku: `--ina-inaku-brand-hover`, `--ina-inaku-neutral-hover`
- BKN: `--ina-bkn-brand-hover`, `--ina-bkn-neutral-hover`
- LAN: `--ina-lan-brand-hover`, `--ina-lan-neutral-hover`
- BGN: `--ina-bgn-brand-primary`, `--ina-bgn-stroke-primary`, `--ina-background-tertiary`, `--ina-sentiment-info-400`, `--ina-sentiment-info-500`, `--ina-sentiment-positive-500`, `--ina-sentiment-warning-500`

## Catatan lain

- (tidak ada)
