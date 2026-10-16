# NoteCare

A personal inbox for notes, links, and images, with per-user cloud sync. Built with Flutter for Android and Supabase for authentication, cloud data storage, and database-level access control.

## What it does

- Save three kinds of items: **notes**, **links**, and **images**
- Full CRUD: create, view, edit, delete
- **Archive** and restore items without permanently deleting them
- **Search** by title/content, and **filter by tag**
- Light/dark theme toggle
- **Email/password accounts** — sign up, sign in, sign out
- **Cloud sync** — items are stored remotely and available across devices once signed in
- **Per-user data access is enforced by PostgreSQL Row Level Security**, using `auth.uid() = owner_id`, not just the app's UI.
- Basic profile screen: view account email/created date, change email
- Loading and error states on network operations (spinners, retry on failure)

## Architecture & Security

```
┌──────────────────────────────┐
│       Flutter Android App    │
│                              │
│  UI / Screens / Widgets      │
│  Auth + Item management      │
└──────────────┬───────────────┘
               │
               │ supabase_flutter
               ▼
┌──────────────────────────────┐
│         Supabase             │
│                              │
│  ┌────────────────────────┐  │
│  │ Authentication         │  │
│  │ Email / Password       │  │
│  └───────────┬────────────┘  │
│              │               │
│              ▼               │
│  ┌────────────────────────┐  │
│  │ PostgreSQL             │  │
│  │ items                  │  │
│  │ owner_id               │  │
│  |                        |  │
│  │ Row Level Security     │  │
│  │ auth.uid() = owner_id  │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

## Tech stack

- **Flutter** (Dart) — targeting Android application, with Web support in the project
- **Supabase** — Postgres database, Auth, and Row Level Security
- **supabase_flutter** — Supabase client for Flutter
- **image_picker** — picking images from the gallery
- **intl** — date formatting
- **uuid** — unique item IDs

## Project structure

```
lib/
  main.dart                      # App entry point, Supabase initialization, auth/theme state
  theme/
    app_theme.dart               # light/dark ColorScheme definitions
  models/
    item.dart                    # Item data model (id, type, title, content, tags, dates, archived)
  services/
    supabase_service.dart        # Supabase CRUD + filtered queries
  screens/
    auth_screen.dart             # sign up / sign in form
    home_screen.dart             # inbox: list, search, tag filter, loading/error states
    edit_screen.dart             # create/edit form, loading/error states
    archive_screen.dart          # archived items, restore/delete, loading/error states
    profile_screen.dart          # profile screen: email, member-since date, change email, logout
  widgets/
    app_drawer.dart              # hamburger menu (Home, Archive, theme toggle, exit)
    profile_menu.dart            # profile/logout menu  
```

## Data flow

1. The user signs in through Supabase Auth.
2. Supabase provides an authenticated session to the Flutter app.
3. The app uses `supabase_flutter` to read and modify items.
4. Each item contains an `owner_id` identifying its owner.
5. PostgreSQL Row Level Security checks `auth.uid() = owner_id`.
6. Only rows authorized by the RLS policies can be read, inserted, updated, or deleted.

## Running it

In the terminal run:

```bash
flutter pub get
flutter run
```

To build an installable APK:
```bash
flutter build apk
```

## Known limitations

- Image items store a local file path, not the uploaded image itself — an image picked on one device won't appear on another, even though the item record syncs. Real cross-device image support would need Supabase Storage, not just the Postgres table.
- Tag filtering matches exact tags, case-sensitive
- No tag autocomplete when typing new tags
- Exit button only works on Android; it's a no-op on Web (browsers don't allow self-closing tabs)
- Visual design is functional but unpolished.
- Tested primarily on an Android emulator.

## Possible future improvements

- Visual/UX overhaul 
- Cross-user note sharing (would warrant revisiting the privacy model and possibly the project's name)
- Cloud image storage via Supabase Storage
- Tag autocomplete
