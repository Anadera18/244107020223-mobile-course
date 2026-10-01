# AI Challenge - Storage Comparison (Week 5)

## 1. Prompt yang digunakan

```
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

## 2. Output awal AI (ringkasan)

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| --- | --- | --- | --- | --- |
| Kompleksitas query | Tidak ada (key-value) | Terbatas (filter di memori) | SQL penuh (WHERE, ORDER BY, JOIN) | SQL penuh, type-safe |
| Relasi | Tidak | Manual | Foreign key | Foreign key + generated API |
| Reaktivitas (stream) | Tidak | `watch()` per box | Tidak bawaan | `watch()` bawaan |
| Type-safety | Rendah | Sedang (adapter) | Rendah (Map) | Tinggi (codegen) |
| Boilerplate | Sangat kecil | Sedang | Sedang | Besar (codegen + migrasi) |
| Kemudahan testing | Mudah (mock) | Sedang | Sedang (inject db) | Mudah (in-memory DB) |

Rekomendasi awal AI: SharedPreferences untuk tema; Drift untuk catatan.

Skema untuk 1000+ catatan:

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty);
```

## 3. Verification checklist

| Pertanyaan | Temuan |
| --- | --- |
| AI menaruh daftar catatan di SharedPreferences? | Tidak. Catatan diarahkan ke database. |
| Skema mendukung antrean sync? | Ya, ada `updated_at` dan `dirty`. Ditambah index `dirty` agar `countDirty` cepat pada 1000+ baris. |
| Klaim "real-time" didukung stream? | Hanya Drift dan Hive (`watch`) yang punya stream bawaan. sqflite tidak. Di proyek ini refresh dilakukan manual lewat Riverpod (`AsyncValue.guard` setelah mutasi). |
| Estimasi boilerplate masuk akal? | Drift butuh `build_runner`, kelas tabel, dan migrasi. Untuk satu tabel sederhana, itu berlebihan. sqflite hanya butuh satu file `db.dart`. |

## 4. Keputusan final

| Kebutuhan | Pilihan | Alasan |
| --- | --- | --- |
| Preferensi (tema, terakhir dibuka) | SharedPreferences | Nilai primitif kecil, API paling sederhana. |
| Catatan + cache posts | SQLite (sqflite) | Data koleksi, butuh ORDER BY, dirty flag, dan update parsial. Satu tabel, jadi tidak perlu codegen. |

Keputusan berbeda dari rekomendasi AI (Drift): Drift unggul di type-safety dan stream, tetapi
skema proyek ini hanya dua tabel, jadi biaya boilerplate dan migrasi tidak sebanding.
Reaktivitas sudah dipenuhi Riverpod. Drift jadi pilihan bila skema membesar
atau butuh query reaktif kompleks.

## 5. Aturan konflik sinkronisasi

Last-write-wins berdasarkan `updated_at`. Jika sama, versi lokal menang.
Diimplementasikan di `resolveConflict` (`lib/data/sync.dart`) dan diuji di `test/note_test.dart`.
