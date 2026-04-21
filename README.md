# ScriptFlow ✍️

> AI-powered script management & teleprompter app for content creators.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-FFCA28?logo=firebase)](https://firebase.google.com)
[![Gemini AI](https://img.shields.io/badge/Gemini-AI%20Engine-4285F4?logo=google)](https://ai.google.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-green)](https://flutter.dev/multi-platform)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

---

## 📖 Tentang ScriptFlow

ScriptFlow adalah aplikasi produktivitas berbasis **cloud-native** yang membantu kreator konten mengelola siklus pembuatan video — mulai dari **ideasi naskah** hingga **eksekusi rekaman**. Didukung oleh **Google Gemini AI** untuk penulisan naskah otomatis dan fitur **teleprompter terintegrasi** untuk memudahkan proses pengambilan gambar.

**Target Platform:** Android & Web Desktop (satu codebase Flutter)

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🤖 **AI Content Assistant** | Generate naskah otomatis dari topik/kata kunci via Gemini AI |
| 📁 **Project Management** | Kelompokkan naskah per proyek (YouTube, TikTok, Podcast, dll.) |
| ✏️ **Text Editor** | Editor minimalis dengan auto-save ke cloud |
| 📜 **Teleprompter Mode** | Teks berjalan otomatis, kecepatan & font size adjustable |
| 🎙️ **Audio Recording** *(opsional)* | Rekam suara langsung saat teleprompter berjalan |
| 📤 **Export .txt** | Unduh naskah ke penyimpanan lokal |
| 🔄 **Version History** | Lacak perubahan naskah & kembalikan ke versi sebelumnya |
| 🌐 **Cloud Sync** | Sinkronisasi real-time antara Web dan Android |
| 📴 **Offline Mode** *(opsional)* | Akses naskah dari cache saat tidak ada koneksi |

---

## 🛠️ Tech Stack

```
Frontend   → Flutter (Android + Web)
Auth       → Firebase Authentication (Google SSO)
Database   → Cloud Firestore
Storage    → Firebase Storage (audio recordings)
AI Engine  → Google Gemini API via Firebase Cloud Functions
Hosting    → Firebase Hosting (Web)
```

---

## 📁 Struktur Proyek

```
scriptflow/
├── android/                    # Android-specific config
├── web/                        # Web-specific config
├── lib/
│   ├── core/
│   │   ├── constants/          # App-wide constants & theme
│   │   ├── utils/              # Helper functions
│   │   └── services/           # Firebase, Gemini service wrappers
│   ├── features/
│   │   ├── auth/               # Google SSO login & onboarding
│   │   ├── dashboard/          # Project & script list
│   │   ├── editor/             # Script editor + AI assistant
│   │   ├── teleprompter/       # Teleprompter + audio recording
│   │   └── settings/           # User preferences
│   ├── shared/
│   │   ├── widgets/            # Reusable UI components
│   │   └── models/             # Data models (Project, Script, etc.)
│   └── main.dart
├── functions/                  # Firebase Cloud Functions (Gemini integration)
├── firebase.json
├── firestore.rules
├── storage.rules
└── pubspec.yaml
```

---

## 🚀 Memulai

### Prasyarat

Pastikan kamu sudah menginstall:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- [Node.js](https://nodejs.org/) `>=18` (untuk Firebase Functions)
- [Firebase CLI](https://firebase.google.com/docs/cli): `npm install -g firebase-tools`
- Android Studio / VS Code dengan Flutter extension
- Akun Google Cloud dengan **Gemini API** enabled

### 1. Clone Repository

```bash
git clone https://github.com/your-username/scriptflow.git
cd scriptflow
```

### 2. Setup Firebase

```bash
# Login ke Firebase
firebase login

# Inisialisasi project (pilih: Firestore, Functions, Hosting, Storage)
firebase init

# Ganti dengan Firebase project ID kamu
firebase use --add
```

### 3. Konfigurasi Environment

Buat file `lib/core/constants/env.dart` berdasarkan template berikut:

```dart
// lib/core/constants/env.dart
class Env {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
}
```

> ⚠️ **Jangan commit file ini ke repository.** Tambahkan ke `.gitignore`.

Atau gunakan `.env` file dan package [flutter_dotenv](https://pub.dev/packages/flutter_dotenv).

### 4. Download `google-services.json` & `GoogleService-Info.plist`

- Dari **Firebase Console → Project Settings → Your Apps**
- Letakkan `google-services.json` di `android/app/`
- Letakkan `GoogleService-Info.plist` di `ios/Runner/` *(jika target iOS)*

### 5. Install Dependencies

```bash
# Flutter dependencies
flutter pub get

# Firebase Functions dependencies
cd functions
npm install
cd ..
```

### 6. Deploy Firebase Functions

```bash
cd functions
npm run build
firebase deploy --only functions
```

### 7. Jalankan Aplikasi

```bash
# Android
flutter run

# Web (Chrome)
flutter run -d chrome

# Web (build production)
flutter build web
firebase deploy --only hosting
```

---

## 🔥 Firestore Data Structure

```
users/{userId}
  └── profile: { name, email, photoUrl, createdAt }

projects/{projectId}
  ├── title: string
  ├── category: enum (youtube | tiktok | podcast | other)
  ├── ownerId: string
  ├── createdAt: timestamp
  └── scripts/{scriptId}
        ├── title: string
        ├── content: string
        ├── updatedAt: timestamp
        └── history: [{ content, savedAt }]
```

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

## 🗺️ Roadmap

- [x] Inisialisasi project & setup Firebase
- [ ] Google SSO Authentication
- [ ] Onboarding flow (3-4 slide)
- [ ] Dashboard — project & script management
- [ ] Script editor dengan auto-save
- [ ] Integrasi Gemini AI (generate & revisi naskah)
- [ ] Export .txt
- [ ] Version history
- [ ] Teleprompter mode
- [ ] Audio recording
- [ ] Offline mode (Hive/local cache)
- [ ] Web responsive layout (sidebar navigation)

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
  Built with ❤️ using Flutter & Firebase
</p>
