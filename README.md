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
