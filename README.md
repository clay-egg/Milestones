# Milestones

A minimalist personal milestone and progress tracking app built with Flutter.

![App Icon](assets/app_icon.png)

## Features

- 📅 **Timeline** — Log daily entries across focus areas (Learning, Goals, Achievements, and more)
- ✅ **Tasks** — Simple task checklist linked to your focus areas
- 🗂 **Projects** — Track multi-step projects with completion checklists
- 🧠 **Skills** — Monitor skill development with evidence tracking
- 🎯 **Goals** — Stage-based goal progression (Idea → Research → Prototype → Launch)
- 📖 **Monthly Recap** — Reflect on achievements, challenges, and next month's plans
- 🔔 **Daily Reminder** — OS-level local notifications scheduled at your chosen time
- 🌙 **Dark / Light Mode** — Warm, minimalist design with a copper accent palette
- 💾 **Local-first** — All data stored on-device via SQLite (Drift). No account, no cloud.
- 📤 **Backup & Restore** — Full JSON export/import for your data

## Screenshots

<!-- Add screenshots here -->

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Database | Drift (SQLite) |
| Fonts | Google Fonts |
| Notifications | flutter_local_notifications |

## Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- Xcode (for iOS)
- An Apple Developer account (for device deployment)

### Run locally

```bash
git clone https://github.com/yourusername/milestones.git
cd milestones
flutter pub get
flutter run
```

### Generate database code (if modifying schema)

```bash
dart run build_runner build
```

## Data & Privacy

All data is stored **100% locally** on your device in a SQLite database. Nothing is sent to any external server. You can export a full JSON backup at any time from Settings.

## License

MIT — see [LICENSE](LICENSE)
