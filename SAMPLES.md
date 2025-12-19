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
controller.addListener(() => setState(() {}));
```

```
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