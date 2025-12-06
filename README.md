# Vidinfra Player for Flutter

Vidinfra Player is a lightweight Flutter SDK that provides an embeddable video player built on top of `kvideo`. It includes a `VidinfraPlayerView` widget for rendering video, a `VidinfraPlayerController` for playback control, downloading helpers via `VidinfraDownloader`, and simple authentication header helpers.

This repository contains the package source and an `example/` app demonstrating usage.

--

**Quick Links**

- **Package:** `vidinfra_player` (see `pubspec.yaml`)
- **Example app:** `example/` — run for a full demo

--

**Contents**

- Overview
- Installation
- Quick Start (basic usage)
- API Reference (main classes)
- Examples (simple snippets)
- Running the Example

--

## Installation

Add `vidinfra_player` to your `pubspec.yaml` dependencies (replace version as needed):

```yaml
dependencies:
	flutter:
		sdk: flutter
	vidinfra_player:
		path: ../  # or use hosted version
```

Then run:

```bash
flutter pub get
```

## Quick Start

The package exposes the main pieces via `package:vidinfra_player/vidinfra_player.dart`.

Minimal usage:

```dart
import 'package:flutter/material.dart';
import 'package:vidinfra_player/vidinfra_player.dart';

final controller = VidinfraPlayerController();

// Create a Media object describing the video
final media = Media(
	title: 'Sample',
	url: 'https://example.com/video.mpd',
	headers: {},
);

// Play media
await controller.play(media);

// In your widget tree:
Widget build(BuildContext context) {
	return VidinfraPlayerView(controller: controller);
}
```

## API Reference (summary)

This section covers the main public classes and their primary members. For full details, inspect the source in `lib/`.

- `VidinfraPlayerController` (in `lib/controller/vidinfra_player_controller.dart`)
	- Constructor: `VidinfraPlayerController({VidinfraConfiguration configuration})`
	- Properties:
		- `nowPlaying` — the currently loaded `Media?`
		- `progress` — media progress (0.0 - 1.0) or `null` when unknown
		- `buffer` — buffer progress (0.0 - 1.0)
		- `configuration` — `VidinfraConfiguration`
	- Methods:
		- `Future<void> play(Media media)` — loads and starts playback of the given `Media`.
		- `void seekTo(double value)` — seek to position (0.0 - 1.0)
		- `void dispose()` — release resources
	- Notes: The controller internally wraps a `k.PlayerController` from the `kvideo` package. It also mixes in `AESAuthMixin` which provides `aesAuthHeaders` used for authenticated requests.

- `VidinfraDownloader` (in `lib/controller/vidinfra_downloader.dart`)
	- Constructor: `VidinfraDownloader({DownloadEventListener? listener})`
	- Methods:
		- `Future<String?> startDownloading(Media media, {String? customIdentifier})` — starts a download and returns an id.
		- `Future<void> remove(String id)` — remove a single download
		- `Future<void> removeAll()` — remove all downloads
		- `Future<List<String>> getAllDownloadIds()` — list download ids
		- `Future<k.DownloadData?> getDownloadStatus(String id)` — get status

- `Media` (in `lib/controller/models.dart`)
	- Fields:
		- `title`, `description?`, `url` (required), `subtitles`, `startFromSecond`, `headers`, `spriteVttUrl`, `chaptersVttUrl`.

- `VidinfraConfiguration` and `FullscreenExitAppState` for configuration options.

## Simple Implementation Examples

- Basic playback (stateless):

```dart
final controller = VidinfraPlayerController();

// Start playing
controller.play(Media(title: 'Intro', url: 'https://example.com/intro.mpd'));

// In widget:
VidinfraPlayerView(controller: controller);
```

- With downloader:

```dart
final downloader = VidinfraDownloader();
final id = await downloader.startDownloading(media);
// monitor status via getDownloadStatus or an event listener
```

## Notes on Authentication

The package includes an `AESAuthMixin` (internal) used to produce request headers required by some Vidinfra services. When using `VidinfraDownloader` on Android, headers are applied to the platform download manager. If you need custom headers for a `Media` item, pass them in the `Media.headers` map — they are merged with auth headers.

### AES Auth (examples)

You can use the controller or downloader mixin helper to generate and attach auth headers before playing or downloading:

```dart
// Use the controller (or downloader) to setup headers used for subsequent requests
controller.setupAESAuth(secret: mySecret);
// or
downloader.setupAESAuth(secret: mySecret);

// The headers are merged when calling play/download:
controller.play(Media(title: 'x', url: 'https://...')); // uses aesAuthHeaders

// If you prefer to generate headers directly:
final headers = AESAuth.generateHeaders(secret: mySecret);
// You can pass these headers directly to a Media item too
controller.play(Media(title: 'x', url: 'https://...', headers: {...headers, 'X-Other': '1'}));
```

generateHeaders supports optional parameters for `method`, `referer`, and `options` (nonce/timestamp) so you can produce deterministic headers for testing:

```dart
final headers = AESAuth.generateHeaders(
	secret: mySecret,
	method: 'GET',
	referer: 'player.vidinfra.com',
	options: (nonceLength: 24, timestamp: 1670000000, nonce: 'fixednonce'),
);
```

These headers include `X-Auth-Signature`, `X-Auth-Timestamp`, `X-Auth-Nonce`, and `Platform`.

### Listening to Download & Player Events

Below are compact examples showing how to listen to download lifecycle events and basic player events.

Download listener example:

```dart
class MyDownloadListener implements DownloadEventListener {
	@override
	void onCompletion(String id, String location) {
		print('Download complete: $id -> $location');
	}

	@override
	void onError(String id, String error) {
		print('Download error: $id -> $error');
	}

	@override
	void onProgress(String id, int progress) {
		// progress is an integer percentage (0-100)
		print('Progress: $id -> $progress%');
	}

	@override
	void onRemoved(String id) {
		print('Removed: $id');
	}
}

// Usage
final listener = MyDownloadListener();
final downloader = VidinfraDownloader(listener: listener);
await downloader.startDownloading(Media(title: 'x', url: 'https://...'));
```

Player event examples

1) Using the controller's general listener (simple):

```dart
// React when controller notifies (e.g., nowPlaying/progress updated)
controller.addListener(() {
	final media = controller.nowPlaying;
	final progress = controller.progress; // 0.0 - 1.0 or null
	// update UI or state
});
```

2) Subscribe to lower-level `kvideo` notifiers exposed by the controller (more specific):

```dart
// Listen to playback status changes
controller.kController.state.status.addListener(() {
	final status = controller.kController.state.status.value;
	print('Player status changed: $status');
});

// Listen to progress updates (Duration)
controller.kController.state.progress.addListener(() {
	final pos = controller.kController.state.progress.value;
	print('Position: ${pos.inSeconds}s');
});
```

Notes:
- `controller.addListener` is the simplest cross-platform way to observe changes made by `VidinfraPlayerController` (it forwards internal updates). Use it for UI updates.
- Accessing `controller.kController.state` gives fine-grained ValueNotifiers (status, progress, buffer, duration, pipMode, etc.) when you need platform/player-specific events. Although the controller internally owns the `kController`, it exposes it for advanced use. Be defensive when using lower-level notifiers (check for nulls where appropriate).
- For downloads, `VidinfraDownloader` calls the listener setup internally; pass your listener to its constructor and it will receive callbacks.

## Example App

See the `example/` directory for a complete sample Flutter app showing how to wire up the controller, use `VidinfraPlayerView`, and the downloader. To run the example:

```bash
cd example
flutter pub get
flutter run -d <device-id>
```

## Contributing

Contributions are welcome. Please open issues or PRs and follow existing code style.

## License

See the `LICENSE` file in the repository.

