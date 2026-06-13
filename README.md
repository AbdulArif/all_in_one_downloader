# all_in_one_downloader

## Facebook downloads

Facebook media URLs must be resolved by a private Cobalt API instance. Start the
included local instance:

```powershell
docker compose -f docker-compose.cobalt.yml up -d
```

Chrome and Windows automatically use `http://localhost:9000/`, so run the app
normally after starting Cobalt:

```powershell
flutter run -d chrome
```

For an Android emulator, host Cobalt at an address reachable by the emulator
and pass that URL through `COBALT_API_URL`. An optional protected instance key
can be supplied with `--dart-define=COBALT_API_TOKEN=your-key`.

Only public Facebook videos are supported. Download content only when you have
permission from the rights holder.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
