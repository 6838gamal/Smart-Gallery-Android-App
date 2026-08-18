# Smart Gallery — Android Gallery App (Flutter)

A professional, modular Android gallery app inspired by Samsung Gallery, built with **Flutter + Dart** and **Riverpod**.

## Features

- **Gallery** — reads photos & videos via Android MediaStore, fast grid, sort by name/date/size/type/album, lazy loading, thumbnail caching, incremental indexing.
- **Albums** — device folders + user-created albums. Create, rename, delete, hide/unhide.
- **Media Viewer** — full-screen zoom/swipe, video playback, metadata, share, favorite, delete.
- **Search** — traditional keyword search over name/album/type.
- **AI Search** — MVP local semantic search with provider abstraction (`AIProvider` → `LocalAIProvider` / `CloudAIProvider`). Works offline; swappable for embeddings/cloud later.
- **Favorites & Trash** — favorite/unfavorite, move to trash, restore, permanent delete.
- **Security** — hide albums, app lock with password, biometric unlock. Passwords hashed, stored in secure storage.
- **Editor** — crop, rotate, flip, brightness, contrast, saturation, basic filters, save as new image. Processing decoupled from UI.
- **Sharing** — Android Share Intent for single/multiple photos and videos.
- **Languages & Theme** — Arabic (default) + English, full RTL support, light/dark/system theme.
- **Offline** — all core features work without internet. AI runs locally.
- **Backup** — `BackupProvider` abstraction ready for Google Drive / Supabase / S3.

## Architecture

```
lib/
├── main.dart
├── app/          # theme, localization, routing
├── core/         # constants, errors, utils, permissions, logging
├── data/         # database, datasources, models
├── services/     # media, thumbnails, sharing, biometric
├── shared/       # reusable widgets
└── features/     # gallery, albums, viewer, scanner, search, ai_search,
                  # favorites, trash, security, editor, settings, backup
```

Each feature is self-contained with its own `models/`, `services/`, `controllers/`, `providers/`, `views/`, `widgets/`.

**State management:** Riverpod (Notifier / AsyncNotifier / StateProvider).
**Routing:** GoRouter with a shell route (bottom nav) and redirect-based app lock.
**Database:** sqflite for metadata only (never stores media blobs).

## How to run

This project requires the Flutter SDK and an Android device/emulator.

```bash
flutter pub get
flutter run
```

On first launch, grant storage permissions when prompted. The app scans your device media and builds a local metadata index incrementally.

## Notes

- The app targets Android (minSdk 23, targetSdk 34). iOS is not configured.
- AI search is a local MVP (token-overlap matching with synonyms + filename fallback). The `AIProvider` abstraction lets you plug in a cloud/embeddings backend later without touching the UI.
- Backup ships as a `NoopBackupProvider` — the interface is ready for implementation.
# Smart-Gallery-Android-App
