part of 'vidinfra_player_controller.dart';

mixin UiControllerMixin {
  /// Must be overridden -------------------------------------------------------

  k.PlayerController get kController;

  k.PlayerState get kState;

  VidinfraConfiguration get configuration;

  void notifyListeners();

  /// --------------------------------------------------------------------------

  /// This will be used and toggled by ui
  final ValueNotifier<bool> controlsVisible = ValueNotifier(true);
  Timer? _controlsHideTimer;

  /// Whether to show loading indicator
  final ValueNotifier<bool> loading = ValueNotifier(false);

  /// Player is in fullscreen mode or not
  bool inFullScreen = false;

  /// Should be called to reset controls hide trigger. e.g on button click
  void autoHideControls() {
    _controlsHideTimer?.cancel();
    if (!controlsVisible.value) return;
    _controlsHideTimer = Timer(
      const Duration(seconds: 3),
      () => controlsVisible.value = false,
    );
  }

  void _statusUpdater() {
    final status = kState.status.value;
    loading.value = status == k.PlaybackStatus.preparing;
  }

  void toggleBoxFit() {
    autoHideControls();
    kController.getFit().then((fit) {
      kController.setFit(
        fit == k.BoxFitMode.fit ? k.BoxFitMode.fill : k.BoxFitMode.fit,
      );
    });
  }

  void enterFullScreen() {
    inFullScreen = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    autoHideControls();
    notifyListeners();
  }

  void exitFullScreen() {
    inFullScreen = false;
    SystemChrome.setPreferredOrientations(
      configuration.fullscreenExitAppState.orientations,
    );
    SystemChrome.setEnabledSystemUIMode(
      configuration.fullscreenExitAppState.mode,
    );
    autoHideControls();
    notifyListeners();
  }

  late bool isMuted = false;

  void toggleMute() {}
}
