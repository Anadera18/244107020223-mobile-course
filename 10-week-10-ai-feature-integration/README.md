# Jobsheet: Matkul Mobile Development Week 10

| **Informasi** | **Detail** |
| --- | --- |
| Mata Kuliah | Mobile Development |
| Nama | Andhika Daffa Athaaillah |
| Absen | 02 |
| NIM | 244107020223 |
| Topik | AI Feature Integration — Gemini Chat |

---

# Practicum

## Tujuan

- Mengintegrasikan satu fitur AI cloud ke aplikasi Flutter.
- Memisahkan UI, layanan API, dan penyimpanan kredensial.
- Menangani loading, kegagalan API, dan mode offline.
- Mempertimbangkan privasi, biaya, dan validasi output.

## Fitur yang dibuat

Aplikasi **Campus AI Assistant** menyediakan percakapan tanya jawab dengan Gemini, pengaturan API key dari layar aplikasi, indikator loading, pesan kegagalan yang ramah, dan balasan offline deterministik untuk demonstrasi saat key belum diatur atau jaringan/API tidak tersedia. Pengguna dapat menghapus key tersimpan. Riwayat chat hanya disimpan di memori.

## Struktur dan stack

- Flutter + Dart, Material 3
- `lib/ai/`: Gemini REST client dan abstraksi penyimpanan key
- `lib/features/chat/`: model pesan dan layar chat
- `flutter_secure_storage`: menyimpan key pada secure storage perangkat
- `http`: HTTPS request ke Gemini `generateContent`
- `test/`: unit test parsing/validasi respons dan widget test chat/fallback

## Menjalankan aplikasi

```bash
flutter pub get
flutter run
```

Buka ikon pengaturan untuk menyimpan key Gemini; key tidak ditulis di source code, README, atau log. Untuk build lokal bisa gunakan secure storage perangkat. Jangan mengirim NIK, nomor telepon, alamat, atau data mahasiswa ke model.

## Prompt dan keputusan AI

System prompt membatasi asisten pada bantuan akademik umum berbahasa Indonesia dan meminta jawaban singkat. Prompt lengkap, user prompt, contoh output awal, serta keputusan accept/reject tercatat pada [`docs/ai-log.md`](docs/ai-log.md). Output model diperlakukan sebagai teks tidak tepercaya, ditampilkan sebagai plain text, dan tidak menjalankan perintah.

## Risiko dan mitigasi

| Risiko | Mitigasi |
| --- | --- |
| Kebocoran data pengguna | Kirim hanya pertanyaan yang sengaja diketik; jangan sertakan pengenal pribadi; riwayat tidak dipersistenkan. |
| Kebocoran API key | Simpan dengan secure storage, sediakan hapus key, jangan commit/log key. Aplikasi klien tetap dapat dianalisis; produksi sebaiknya memanggil backend yang mengelola secret. |
| Lonjakan biaya / penyalahgunaan | Batasi panjang input dan output token; batasi satu request berjalan pada satu waktu; pantau kuota dan penggunaan provider. |
| API gagal / offline | Pesan error yang ramah dan fallback lokal yang jelas diberi label sebagai contoh offline. |
| Jawaban keliru atau tidak relevan | Beri tahu pengguna untuk memverifikasi informasi penting; gunakan jawaban sebagai bantuan, bukan sumber otoritatif. |

## Test dan analisis

Perintah dan hasil final:

```text
flutter test --reporter expanded  All tests passed (9 tests)
flutter analyze                   No issues found
```

Screenshot UI aplikasi: [`screenshots/chat-home.png`](screenshots/chat-home.png). Log terminal test: [`screenshots/flutter-test-passed.txt`](screenshots/flutter-test-passed.txt).

## Reflection

- **Fitur AI apa dan mengapa?** Chat assistant memberi interaksi langsung dan memperlihatkan alur request cloud, loading, serta error/fallback yang menjadi fokus codelab.
- **Bagaimana privasi dijaga?** Key disimpan pada secure storage perangkat; input dibatasi dan UI mengingatkan agar tidak mengirim data pribadi; riwayat tidak disimpan.
- **Fallback jika API gagal?** Aplikasi menampilkan status gangguan dan menyediakan contoh jawaban lokal yang ditandai sebagai offline, bukan mengaku sebagai jawaban Gemini.
- **Pelajaran UX?** Loading dan status koneksi harus jelas, kegagalan perlu tindakan yang dimengerti, dan pengguna harus tahu bahwa jawaban AI dapat salah.

---

# Assignment

Mini project Week 10: Gemini chat, prompt log, secure key handling, risk table, offline fallback, tests, analyzer output, and screenshots are included in this folder.
