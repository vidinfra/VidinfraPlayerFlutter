## Important Note

For any further clarification about something, feel free to reach out to us
via [email](mailto:contact@tenbyte.io)

### Import Vidinfra Player SDK

```dart
import 'package:vidinfra_player/vidinfra_player.dart';
```

### Theming

VidinfraPlayer inherits your application theme. So please set your primary color, icon styles etc in
your `ThemeData` properly.

```
 MaterialApp(
      // ...
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00FFDD),
          brightness: Brightness.dark,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          strokeWidth: 2,
          color: Color(0xFF00FFDD),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            highlightColor: Color(0xFF00FFDD).withAlpha(69),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
    )
```

## VidinfraPlayerController

The controller instance for managing everything.

Passing config is optional. See available configuration options below.

The `VidinfraPlayerController` extends `ChangeNotifier` so it can be listened on via `addListener`
or `Selector` from provider

```
// Regular setState
controller.addListener(() => setState(() {}));
```

```
// Using Provider
Selector<VidinfraPlayerController, bool>(
  selector: (_, controller) => controller.inFullScreen,
  builder: (_, fullscreen, child) {
    // ...
});
```

```dart

final controller = VidinfraPlayerController(configuration: config);
```

#### Configuration

These parameters are final and thus not changeable later. Keep that in mind

```dart
Configuration({
  FullscreenExitAppState fullscreenExitAppState = const FullscreenExitAppState(),
  List<double> playbackSpeeds = const [0.5, 1.0, 1.5, 2],
  Controls controls = const Controls(),
});
```

#### Fullscreen Exit App State

Used to restore your app back to how it was before entering fullscreen

```dart
FullscreenExitAppState({
  List<DeviceOrientation> orientations = const [DeviceOrientation.portraitUp],
  SystemUiMode mode = SystemUiMode.edgeToEdge,
});
```

#### Ui Customization

You may show/hide any element of the Ui by changing these parameters.

```dart
Controls({
  bool backward = true,
  bool forward = true,
  bool bigPlayButton = true,
  bool currentTime = true,
  bool fullscreen = true,
  bool mute = true,
  bool pictureInPicture = true,
  bool playPause = true,
  bool seekBar = true,
  bool settings = true,
  bool branding = true,
});
```

## VidinfraPlayerView

The frontend for your video view. It needs a controller instance to function.

It is recommended to only use a single view per controller, otherwise unintended things may occur.

#### Parameters

- **controller:** required VidinfraPlayerController instance
- **aspectRatio:** desired video aspect ratio. ( 16 / 9 is landscape)
- **handleFullScreenBack** adds a `PopScope` to automatically handle the exit behavior from
  fullscreen upon system back press.

```dart
@override
Widget build(BuildContext context) =>
    Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          VidinfraPlayerView(
              controller: controller,
              aspectRatio: 16 / 9,
              handleFullScreenBack: true,
              placeholder: const CircularProgressIndicator()
          ),
          // ...
        ],
      ),
    );
```

### Fullscreen Usage

It is recommended to adapt your layout to allow `VidinfraPlayerView` to grow to entire screen size.

See the [example](./example/lib/main.dart) app for further guidance.

#### Available fullscreen related apis:

- `controller.enterFullScreen()` Enter fullscreen mode.
- `controller.exitFullScreen()` Go back to normal view
- `controller.inFullScreen` Can be used to listen to fullscreen changes and adapt Ui accordingly.

### Customizing Placeholder

It is possible to change the default CircularProgressIndication while your video is loading.
To do that, pass `placeholder` to the `VidinfraPlayerView` widget.

It will only show when the playback status is `preparing`.

```
VidinfraPlayerView(
  controller: controller,
 placeholder: MyCustomPosterPlaceholder()
);

```

### Controls API

If you wish you can make the controls behave manually by using the provided api's;

Trigger auto hide timer of controls

```
controller.autoHideControls();
```

Cancel auto hide

```
controller.cancelControlAutoHide();
```

Check if controls are visible.

```dart
controller.controlsVisible; // ValueNotifier<bool>
```

Show hide manually

```
controller.controlsVisible.toggle();
// Or, set the desired value directly
controller.controlsVisible.value = true;
```

### Playing a Media

Construct your media object.

```dart
 Media Media({
  required String title,
  String? description,
  required String url,
  List<SubtitleData> subtitles = const [],
  int startFromSecond = 0,
  Map<String, String> headers = const {},
  String? spriteVttUrl,
  String? chaptersVttUrl,
});

// here's an example
final media = Media(
  title: "Vidinfra Demo",
  url: "https://.../playlist.m3u8",
);
```

Begin playing the media by calling

```
controller.play(media);
```

#### Seek to any point in the video

```
// value must be in between 0.0 to 1.0
controller.seekTo(value);
```

#### Set playback speed

```
controller.setPlaybackSpeed(speed);
```

#### Set device volume

```
// value must be in between 0.0 to 1.0
controller.setVolume(value);
```

#### Toggle between video fit & fill mode

```
controller.toggleBoxFit();
```

#### Toggle audio mute / unmute

```
controller.toggleMute();
```

### Changing tracks manually

> [kVideo](https://pub.dev/packages/kvideo) is what powers VidinfraPlayerSDK behind the scene. You do not need to interact with it 99% of the usecase. But it is available for advance usecase.

#### Obtain currently available video / audio tracks by calling

```
controller.kController.getTracks(); // List<k.TrackData>
```

#### Choose a track

```
controller.selectVideoTrack(track);
```

#### Don't forget to dispose the controller once you're done using it by calling.

```

controller.dispose();

```

## Security & DRM

AES 128 based fragment encryption is available and ready to use.
You need to setup AES with your secret before calling `play();`

```
controller.setupAESAuth(secret: "<your vidinfra secret>");
```

## Downloading

You may wish to download a video for offline playback. We provide simple api to manage and track downloads.

#### Start by creating a `VidinfraDownloader` instance.

```
final downloader = VidinfraDownloader();
```

#### Register listener if you need to show progress

```dart
class MyDownloadListener implements DownloadEventListener {
  @override
  void onCompletion(String id, String location) {
    print("COMPLETE: $id $location");
  }

  @override
  void onError(String id, String error) {
    print("ERROR: $id $error");
  }

  @override
  void onProgress(String id, int progress) {
    print("PROGRESS: $id $progress");
  }

  @override
  void onRemoved(String id) {
    print("REMOVED: $id");
  }
}
```

#### Register the listener. Don't forget to remove it once you're done.

```dart
// Create an instance of DownloadListener
final listener = MyDownloadListener();
// Add listener
downloader.addListener(listener);
// Remove listener
downloader.removeListener(listener);

```

#### Start downloading

```
/// Call this once if your video has AES Encryption.
downloader.setupAESAuth(secret: "<my-secret>");

// Add download to queue
final identifier = await downloader.startDownloading(
  Media(title: url, url: url, spriteVttUrl: sprite),
  customIdentifier: url.hashCode.toString(), // optional.
);
```

### Querying download status

#### Get all download id's

```
downloader.getAllDownloadIds(); // List<String>
```

#### Retrive status for a particular download.

```
final data = downloader.getDownloadStatus(id); // DownloadData
```

You'll get the following informations from the database.

```dart
DownloadData({
  String? id, // Unique identifier. Generated if not provided ahead of time
  int? progress, // Progress between 0 to 100
  DownloadStatus? status, // Any of downloading, waiting, error, finished,
  String? originUri, // Source url.
  String? localUri, // Destination.
  String? error, // Error message if status is error
});
```

#### Removing downloads

```dart
downloader.remove(id); // Remove a single download
downloader.removeAll(); // Remove all finished & running downloads
```

#### Playing a downloaded media

#### Download must be finished before playing.

```dart
controller.play(
  Media(
    title: data.localUri!,
    url: data.localUri!,
    spriteVttUrl: downloader.localSpritePath(data.id!),
  ),
);
```
