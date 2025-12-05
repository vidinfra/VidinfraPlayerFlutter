part of 'vidinfra_player_controller.dart';

mixin UiControllerMixin {
  /// Must be overridden -------------------------------------------------------

  k.PlayerController get kController;

  k.PlayerState get kState;

  VidinfraConfiguration get configuration;

  ValueNotifier<Media?> get _nowPlaying;

  void notifyListeners();

  /// Must be Called -----------------------------------------------------------

  Future<void> initializeUiControllerMixin() async {
    VolumeController.instance.showSystemUI = false;
    VolumeController.instance.isMuted().then((value) => _isMuted = value);
    VolumeController.instance.getVolume().then((value) => _volume = value);
    _nowPlaying.addListener(_prepareThumbnailPreviews);
  }

  void disposeUiControllerMixin() {
    VolumeController.instance.removeListener();
    _nowPlaying.removeListener(_prepareThumbnailPreviews);
  }

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
      () => controlsVisible.value = true ?? false, // TODO Debug Only
    );
  }

  void cancelControlAutoHide() => _controlsHideTimer?.cancel();

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

  /// Volume Controls ----------------------------------------------------------

  double _volume = 0.0;

  double get volume => _volume;

  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> toggleMute() async {
    _isMuted = await VolumeController.instance.isMuted();
    await VolumeController.instance.setMute(!_isMuted);
    _isMuted = await VolumeController.instance.isMuted();
    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    VolumeController.instance.setVolume(_volume);
    notifyListeners();
  }

  /// --------------------------------------------------------------------------

  /// Thumbnail Previews (TODO) -------------------------------------------------------

  Future<void> _prepareThumbnailPreviews() async {
    final media = _nowPlaying.value;
  }

  /// --------------------------------------------------------------------------
}
