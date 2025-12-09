# Vidinfra Player for Flutter

Official Flutter SDK for **[Vidinfra](https://tenbyte.io/vidinfra)** by [Tenbyte](https://www.tenbyte.io).

Vidinfra is a secure video infrastructure platform with unlimited bandwidth, built-in security, and piracy protection. This Flutter SDK provides an embeddable video player widget (`VidinfraPlayerView`), a playback controller (`VidinfraPlayerController`), download helpers (`VidinfraDownloader`), and AES authentication helpers for secure video delivery.

Built on top of `kvideo`, this lightweight SDK enables seamless integration of Vidinfra's video hosting capabilities into Flutter applications.

**Learn more about Vidinfra:** [https://tenbyte.io/vidinfra](https://tenbyte.io/vidinfra)

## About Vidinfra

Vidinfra is an all-in-one video hosting platform that provides:

- **Unlimited CDN bandwidth** - Global edge network for fast video delivery
- **Built-in security** - Token authentication, geo-blocking, domain restrictions, and multi-DRM protection
- **Piracy protection** - Keep your content secure and prevent revenue leaks
- **Easy management** - Upload, organize, and manage your video library via API or dashboard
- **Customizable player** - Personalize with logos, subtitles, and thumbnails
- **Live streaming** - RTMP/SRT ingest with adaptive HLS delivery
- **Video analytics** - Track performance and viewer engagement metrics

This Flutter SDK enables you to integrate Vidinfra's video playback, downloading, and authentication features directly into your Flutter applications.

---

**Quick Links**

- **Product:** [Vidinfra](https://tenbyte.io/vidinfra) - Secure video infrastructure with unlimited CDN
- **Company:** [Tenbyte](https://www.tenbyte.io)
- **Package:** `vidinfra_player` (see `pubspec.yaml`)
- **Example app:** `example/`
- **License:** MIT (see `LICENSE`)

--

## Features

- Embeddable video widget (`VidinfraPlayerView`) with controller-driven playback API.
- AES authentication helpers to generate and merge request headers.
- Downloader with start/remove/list/status helpers and listener hooks.
- Media model includes subtitles, sprite thumbnails, and chapter VTT fields.
- Access to lower-level `kvideo` notifiers for advanced playback state.

## Requirements

- Dart >=3.8.1, Flutter >=1.17.0 (from `pubspec.yaml`).
- Standard Flutter Android/iOS setup with network access; ensure platform permissions for networking/downloading as required by your app.

## Installation

Add `vidinfra_player` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  vidinfra_player: ^0.0.4 # or use a local path/git ref
```

Then install:

```bash
flutter pub get
```

Import everything from the umbrella entrypoint:

```dart
import 'package:vidinfra_player/vidinfra_player.dart';
```

## Quick Start

A minimal stateful widget using the controller and view:

```dart
class PlayerExample extends StatefulWidget {
  const PlayerExample({super.key});

  @override
  State<PlayerExample> createState() => _PlayerExampleState();
}

class _PlayerExampleState extends State<PlayerExample> {
  final controller = VidinfraPlayerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await controller.play(Media(
      title: 'Sample',
      url: 'https://example.com/video.mpd',
      headers: {}, // merged with auth headers if configured
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: VidinfraPlayerView(controller: controller)),
        ElevatedButton(onPressed: _play, child: const Text('Play')),
      ],
    );
  }
}
```

## Downloads (overview)

- Create a downloader: `final downloader = VidinfraDownloader(listener: myListener);`
- Start: `final id = await downloader.startDownloading(media);`
- Manage: `remove(id)`, `removeAll()`, `getAllDownloadIds()`, `getDownloadStatus(id)`.
- Implement `DownloadEventListener` to react to completion, progress, errors, and removal.

## API Reference (summary)

For details, see the source under `lib/`.

- `VidinfraPlayerController` (`lib/controller/vidinfra_player_controller.dart`)
  - `play(Media)`, `seekTo(double)`, `dispose()`.
  - Properties: `nowPlaying`, `progress` (0.0–1.0 or null), `buffer`, `configuration`.
  - Wraps `k.PlayerController` and mixes in `AESAuthMixin` (`aesAuthHeaders`).
- `VidinfraDownloader` (`lib/controller/vidinfra_downloader.dart`)
  - `startDownloading`, `remove`, `removeAll`, `getAllDownloadIds`, `getDownloadStatus`.
- `Media` (`lib/controller/models.dart`)
  - Fields: `title`, `description?`, `url` (required), `subtitles`, `startFromSecond`, `headers`, `spriteVttUrl`, `chaptersVttUrl`.
- `VidinfraConfiguration` and `FullscreenExitAppState` for player configuration options.

## Authentication (AES)

Use the controller or downloader to set up auth headers for subsequent requests:

```dart
controller.setupAESAuth(secret: mySecret);
// or
downloader.setupAESAuth(secret: mySecret);
```

Headers are merged automatically when calling `play`/`startDownloading`. If you need deterministic headers (for testing), generate them directly:

```dart
final headers = AESAuth.generateHeaders(
  secret: mySecret,
  method: 'GET',
  referer: 'player.vidinfra.com',
  options: (nonceLength: 24, timestamp: 1670000000, nonce: 'fixednonce'),
);
controller.play(Media(title: 'x', url: 'https://...', headers: headers));
```

Generated headers include `X-Auth-Signature`, `X-Auth-Timestamp`, `X-Auth-Nonce`, and `Platform`.

## Listening to Events

- High-level: `controller.addListener(() { /* react to nowPlaying/progress */ });`
- Low-level: use `controller.kController.state.*` notifiers (status, progress, buffer, duration, pipMode, etc.) for platform-specific signals.
- Downloads: provide a `DownloadEventListener` to `VidinfraDownloader` for progress, error, completion, and removal callbacks.

## Running the Example

```bash
cd example
flutter pub get
flutter run -d <device-id>
```

## Contributing

Contributions are welcome! Please open issues or PRs and follow the existing code style.

For questions or support about Vidinfra, visit [https://tenbyte.io/vidinfra](https://tenbyte.io/vidinfra) or contact [Tenbyte](https://www.tenbyte.io).

## License

This project is licensed under the MIT License. See `LICENSE` for details.
