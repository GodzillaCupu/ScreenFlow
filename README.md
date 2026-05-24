# ScriptFlow ✍️

> AI-powered script management & teleprompter app for content creators.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Local-First](https://img.shields.io/badge/Architecture-Local--First-22C55E)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/Gemini-AI%20Engine-4285F4?logo=google)](https://ai.google.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-green)](https://flutter.dev/multi-platform)
[![Deploy to GitHub Pages](https://github.com/GodzillaCupu/ScreenFlow/actions/workflows/flutter-gh-pages.yml/badge.svg)](https://github.com/GodzillaCupu/ScreenFlow/actions/workflows/flutter-gh-pages.yml)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

---

## 📖 Tentang ScriptFlow

ScriptFlow adalah aplikasi produktivitas berbasis **local-first** (tanpa backend cloud) yang membantu kreator konten mengelola siklus pembuatan video — mulai dari **ideasi naskah** hingga **eksekusi rekaman**. Naskah, folder proyek, dan rekaman audio disimpan **sepenuhnya di perangkat**; hanya fitur AI (**Google Gemini 3.5 Flash**) yang memerlukan koneksi. Cocok untuk menulis & merekam podcast secara offline di perjalanan.

**Target Platform:** Android & Web Desktop (satu codebase Flutter)

🌐 **Akses Web Resmi (GitHub Pages):** [https://GodzillaCupu.github.io/ScreenFlow/](https://GodzillaCupu.github.io/ScreenFlow/)

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🤖 **AI Content Assistant** | Generate naskah otomatis dari topik/kata kunci via Gemini AI (v3.5 Flash) |
| 📁 **Project Management** | Kelompokkan naskah per proyek (YouTube, TikTok, Podcast, dll.) |
| ✏️ **Text Editor** | Editor minimalis dengan auto-save ke database lokal |
| 📜 **Teleprompter Mode** | Teks berjalan otomatis, kecepatan & font size adjustable |
| 🎙️ **Audio Recording** | Rekam suara lokal lewat mikrofon device langsung di layar Teleprompter (offline) |
| 🔍 **Search & Archive** | Pencarian naskah yang efisien serta fitur pengarsipan (*Archive*) untuk menjaga dashboard tetap rapi |
| 👤 **Local Profile** | Kustomisasi profil kreator (Display Name & Bio) secara lokal |
| 📤 **Export .txt** | Simpan naskah ke penyimpanan lokal + share sheet |
| 📴 **Offline by Default** | Naskah & rekaman selalu tersedia tanpa koneksi |

---

## 🛠️ Tech Stack

```
Frontend   → Flutter (Android + Web)
State Mgmt → Riverpod
Database   → Isar (local, on-device)
Storage    → path_provider (audio recordings + .txt exports, on-device)
AI Engine  → Google Gemini (client-side via google_generative_ai, key in .env)
Auth       → None (local-first; login screen is an optional local gate)
```

---

## 📁 Struktur Proyek

```
scriptflow/
├── android/ · web/             # Platform config (mic + internet permissions)
├── .env / .env.example         # Gemini API key (git-ignored, bundled asset)
├── lib/
│   ├── core/
│   │   ├── config/             # env_config (reads .env)
│   │   ├── constants/          # app constants (debounce, teleprompter limits)
│   │   ├── layout/             # AdaptiveLayout, mobile/desktop shells, sidebar
│   │   ├── router/             # go_router table
│   │   ├── theme/              # colors + theme (Inter/Poppins, dark)
│   │   └── providers.dart      # DI graph (repos + services)
│   ├── data/                   # ── LOCAL STORAGE / REPOSITORY ──
│   │   ├── models/             # Isar collections: Project, Script
│   │   ├── local/              # isar_service (opens the DB)
│   │   └── repositories/       # ScriptRepository / ProjectRepository (+ Isar impl)
│   ├── services/               # gemini · audio_recorder · export(.txt)
│   ├── features/
│   │   ├── archive/            # archived scripts
│   │   ├── auth/               # login + onboarding (local gate, no cloud)
│   │   ├── dashboard/          # workspace + project folder + search
│   │   ├── editor/             # editor + auto-save controller + Muse (AI) panel
│   │   ├── teleprompter/       # auto-scroll screen + audio recording controls
│   │   ├── scripts/            # script picker (Editor/Prompter tabs)
│   │   └── settings/           # local-first preferences & profile
│   ├── shared/widgets/         # FolderCard, ScriptCard, StatusBadge
│   └── main.dart
└── pubspec.yaml
```

---

## 🚀 Memulai

### Prasyarat

Pastikan kamu sudah menginstall:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.27` (Dart `>=3.6`)
- Android Studio / VS Code dengan Flutter extension
- API key Gemini dari [Google AI Studio](https://aistudio.google.com/app/apikey) (untuk fitur AI)

### 1. Clone Repository

```bash
git clone https://github.com/your-username/scriptflow.git
cd scriptflow
```

### 2. Konfigurasi Environment (.env)

```bash
# Salin template, lalu isi GEMINI_API_KEY
cp .env.example .env
```

`.env` sudah di-`.gitignore` dan di-bundle sebagai Flutter asset. Tanpa key,
aplikasi tetap berjalan — hanya fitur AI "The Muse" yang nonaktif.

> ⚠️ **Catatan keamanan:** API key yang di-bundle ke aplikasi klien bisa
> diekstrak. `.env` hanya melindungi dari commit git. Untuk produksi, restrict
> key di Google Cloud Console atau proxy lewat serverless function.

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Generate Kode Isar (build_runner)

Model Isar membutuhkan `*.g.dart` yang di-generate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Jalankan Aplikasi

```bash
# Android (target utama)
flutter run

# Web (Chrome) — catatan: Isar di web perlu setup tambahan, lihat di bawah
flutter run -d chrome
```

---

## 🗄️ Local Data Model (Isar)

Disimpan on-device via Isar. Script terhubung ke Project lewat `projectId`.
File rekaman & ekspor disimpan di app documents dir via `path_provider`.

```
Project (collection)
  ├── uuid: string (unik)
  ├── title: string
  ├── type: enum (youtubeLongform | shorts | podcast | videoEssay | other)
  ├── description: string?
  ├── createdAt / updatedAt: DateTime
  └── isArchived: bool

Script (collection)
  ├── uuid: string (unik)
  ├── projectId: string?          → uuid Project pemilik
  ├── title / content: string
  ├── status: enum (drafting | review | readyToRecord | approved)
  ├── wordCount: int
  ├── scrollSpeed / fontSize / mirror / focusMode   → preferensi teleprompter
  ├── recordingPaths: List<String>   → path .m4a lokal
  └── createdAt / updatedAt / isArchived

On-device files:
  <appDocs>/recordings/<scriptUuid>/take_*.m4a
  <appDocs>/exports/<title>.txt
```

> **Isar di Web:** dukungan web Isar terbatas & butuh inisialisasi WASM. Karena
> akses data sudah diabstraksi lewat `ScriptRepository`/`ProjectRepository`
> (lihat `lib/data/repositories/`), untuk web kamu cukup membuat implementasi
> Hive dan menukar binding di `lib/core/providers.dart` — kode fitur tak berubah.

---

## 🎨 Design System

| Elemen | Nilai |
|---|---|
| **Primary Background** | `#1E293B` (Slate 800) |
| **Surface** | `#0F172A` (Slate 900) |
| **Text Primary** | `#F8FAFC` (Off-white) |
| **Accent AI** | `#3B82F6` (Blue 500) |
| **Accent Record** | `#22C55E` (Green 500) |
| **Font** | Inter / Roboto |
| **Theme** | Dark Mode First |

---

## 🚀 Deployment Otomatis (GitHub Pages)

Proyek ini telah terintegrasi penuh dengan **GitHub Actions** untuk melakukan kompilasi dan pembaruan otomatis ke **GitHub Pages**. Setiap kali Anda melakukan `git push` ke cabang `main`, alur kerja CI/CD akan otomatis dijalankan untuk:
1. Mempersiapkan lingkungan Flutter stable.
2. Mengunduh dependensi (`flutter pub get`).
3. Menjalankan pembuatan kode model database (`dart run build_runner build`).
4. Men-build web aplikasi dengan base href yang sesuai (`/ScreenFlow/`).
5. Mempublikasikan hasil build langsung ke cabang `gh-pages` untuk ditayangkan langsung secara online.

---

## 🗺️ Roadmap

- [x] Inisialisasi project (local-first, tanpa Firebase)
- [x] Onboarding flow + login screen (gate lokal, tanpa cloud auth)
- [x] Web/mobile responsive layout (sidebar + bottom nav)
- [x] Dashboard — project & script management (Isar)
- [x] Script editor dengan auto-save ke DB lokal
- [x] Integrasi Gemini AI (generate, brainstorm, fix grammar)
- [x] Teleprompter mode (auto-scroll, speed/font/mirror/focus)
- [x] Export .txt + share sheet
- [x] Audio recording di layar teleprompter
- [x] Search & filter (Archive / dalam folder)
- [x] Profil lokal (display name/bio) di Settings
- [x] Integrasi CI/CD & Web Hosting (GitHub Pages otomatis via GitHub Actions)
- [ ] Version history (Riwayat revisi script)

---

## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch fitur: `git checkout -b feat/nama-fitur`
3. Commit perubahan: `git commit -m 'feat: tambah fitur X'`
4. Push ke branch: `git push origin feat/nama-fitur`
5. Buat Pull Request

Gunakan [Conventional Commits](https://www.conventionalcommits.org/) untuk format pesan commit.

---

## 📄 Lisensi

Didistribusikan di bawah [MIT License](LICENSE).

---

<p align="center">
  Built with ❤️ using Flutter · Local-First
</p>
