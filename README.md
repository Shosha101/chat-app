# Chatify — Realtime Chat App

A realtime chat application built with **Flutter + Firebase**.

## Features

- 🔐 **Authentication** — register & login with Firebase Auth
- 💬 **Realtime messaging** — chats stored and synced live via Cloud Firestore
- 🖼️ **Media messages** — send images via Firebase Storage (file picker + upload)
- 👥 **User discovery** — browse users and start conversations
- 🕓 Relative timestamps (`timeago`), keyboard-visibility-aware UI, splash screen

## Architecture

**Provider**-based MVVM with a dedicated services layer:

```
lib/
├── models/       # chat, message, user
├── pages/        # splash, login, register, home, chats, chat, users
├── providers/    # authentication, chats list, single chat, users
├── services/     # database (Firestore), cloud storage, media, navigation
└── widgets/      # message bubbles, list tiles, inputs, top bar
```

- **get_it** for service location
- Firebase config via `flutter_dotenv` (secrets kept out of source)

## Getting Started

```bash
flutter pub get
# add your own Firebase project (google-services.json / firebase_options.dart)
flutter run
```

## 📦 Packages

| Package | Version |
|---|---|
| `firebase_core` | ^3.13.0 |
| `firebase_analytics` | ^11.3.6 |
| `firebase_storage` | ^12.3.6 |
| `firebase_auth` | ^5.3.3 |
| `cloud_firestore` | ^5.5.0 |
| `provider` | ^6.1.2 |
| `get_it` | ^8.0.2 |
| `file_picker` | ^8.1.4 |
| `flutter_spinkit` | ^5.2.1 |
| `get_time_ago` | ^2.1.1 |
| `flutter_keyboard_visibility` | ^6.0.0 |
| `flutter_dotenv` | ^5.2.1 |
| `timeago` | ^3.7.0 |
| `cupertino_icons` | ^1.0.8 |
| `http` | ^1.3.0 |
| `mime` | ^2.0.0 |
| `http_parser` | ^4.0.2 |

