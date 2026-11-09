# Jobsheet: Matkul Mobile Development Week 11

| **Informasi** | **Detail** |
| --- | --- |
| Mata Kuliah | Mobile Development |
| Nama | Andhika Daffa Athaaillah |
| Absen | 02 |
| NIM | 244107020223 |
| Topik | Performance Optimization |

---

# Practicum

## Tujuan

- Memahami bottleneck build, layout, paint, memori, dan jaringan pada Flutter.
- Membandingkan list eager dengan lazy loading.
- Menerapkan optimasi widget dan repaint isolation.
- Mengukur perubahan dengan bukti yang dapat direproduksi.

## Fitur yang dibuat

Aplikasi **Performance Lab** menampilkan katalog belajar berisi 120 baris. Tombol Baseline menampilkan implementasi pembanding berbasis `ListView(children: ...)` yang membuat semua widget anak sekaligus. Tombol Optimized menggunakan `ListView.builder`, widget dan ikon statis yang konstan, serta `RepaintBoundary` per baris. Kedua mode menggunakan konten yang sama agar perbandingan adil.

## Profiling dan temuan

Folder Week 11 awalnya hanya scaffold kosong, tanpa aplikasi Week 7–10 yang dapat diprofilkan. Karena itu, proyek ini menyediakan skenario baseline/optimized terisolasi yang dapat dijalankan langsung. Temuan dan batas pengukuran dicatat di [`docs/performance-findings.md`](docs/performance-findings.md), sedangkan prosedur dan perbandingan ada di [`docs/performance-report.md`](docs/performance-report.md).

Temuan utama:

1. Baseline membuat seluruh 120 row sekaligus; lazy list membangun row yang terlihat dan sekitar viewport.
2. Widget statis yang tidak `const` dan dirakit ulang pada baseline meningkatkan kerja build.
3. Tanpa isolasi repaint, perubahan kecil dapat membuat area daftar ikut dicat ulang; versi optimized mengisolasi setiap row.

Tidak ada Android emulator/perangkat pada environment saat tugas ini dikerjakan. Screenshot dan pemeriksaan widget dibuat pada viewport 430 × 900; angka frame/memori DevTools tidak direkayasa dan dicatat sebagai belum diukur pada perangkat. Gunakan `flutter run --profile` untuk pengukuran perangkat yang representatif.

## Stack dan struktur

- Flutter + Dart, Material 3
- `lib/main.dart`: aplikasi perbandingan baseline dan optimized
- `test/`: widget tests untuk mode dan lazy rendering
- `docs/`: temuan dan laporan profiling
- `screenshots/`: screenshot UI dan hasil test

## Menjalankan aplikasi

```bash
flutter pub get
flutter run
```

Pilih **Baseline** atau **Optimized**, lalu gulir cepat ke bawah. Pada perangkat Android/iOS untuk profiling, jalankan `flutter run --profile`, rekam skenario yang sama di DevTools Performance, lalu ambil snapshot di Memory sebelum dan sesudah beberapa kali scroll/navigasi.

## Test dan analisis

```text
flutter test --reporter expanded  All tests passed (3 tests)
flutter analyze                   No issues found
```

Screenshot aplikasi: [`screenshots/performance-lab.png`](screenshots/performance-lab.png). Hasil test: [`screenshots/flutter-test-passed.txt`](screenshots/flutter-test-passed.txt).

## Reflection

- **Optimasi paling berdampak?** Untuk daftar panjang, `ListView.builder` menghindari pembuatan semua item sebelum diperlukan.
- **Bagaimana memastikan bukan placebo?** Kedua mode menampilkan data yang sama; widget test memeriksa tipe list dan membuktikan item ke-120 belum dirender pada optimized awal. Perbandingan frame tetap perlu diulang pada profile build dan perangkat target.
- **Trade-off?** Builder dan widget terpisah sedikit menambah struktur kode. `RepaintBoundary` dapat menambah layer/memori, sehingga perlu dipakai pada area yang manfaat isolasi catnya terukur.
- **Kapan menghindari premature optimization?** Sebelum menemukan bottleneck melalui profiling; optimasi tanpa pengukuran dapat menambah kompleksitas tanpa perbaikan yang terlihat.

---

# Assignment

Demo baseline dan optimized, laporan profiling yang menyebut keterbatasan pengukuran, tiga teknik optimasi, tests, analyzer output, dan screenshot tersedia di folder Week 11.
