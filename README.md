# all_in_one_downloader

## Facebook downloads

Facebook media URLs require the included local resolver. Start it once before
running the app:

```powershell
.\start_downloader.ps1
```

Chrome and Windows automatically use `http://localhost:9000/`, so then run the
app normally:

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
