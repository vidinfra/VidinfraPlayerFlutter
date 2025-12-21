part of 'vidinfra_player_controller.dart';

mixin UiControllerMixin {
  /// Must be overridden -------------------------------------------------------

  k.PlayerController get kController;

  k.PlayerState get kState;

  Configuration get configuration;

  ValueNotifier<Media?> get _nowPlaying;

  bool get disposed;

  void notifyListeners();

  /// Must be Called -----------------------------------------------------------

  @visibleForOverriding
  Future<void> initializeUiControllerMixin() async {
    VolumeController.instance.showSystemUI = false;
    VolumeController.instance.isMuted().then((value) => _isMuted = value);
    VolumeController.instance.getVolume().then((value) => _volume = value);
    _nowPlaying.addListener(_prepareThumbnailPreviews);
  }

  @visibleForOverriding
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
      () => controlsVisible.value = false,
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

  /// The volume value should be a double between 0.0 (minimum volume) and 1.0 (maximum volume).
  void setVolume(double value) {
    _volume = value;
    VolumeController.instance.setVolume(_volume.clamp(0.0, 1.0));
    notifyListeners();
  }

  /// --------------------------------------------------------------------------

  /// Thumbnail Previews -------------------------------------------------------
  final previewThumbnailController = VideoPreviewThumbnailsController();

  Uint8List? _spriteVtt;
  ui.Image? _spriteImage;

  Uint8List? get spriteVtt => _spriteVtt;

  ui.Image? get spriteImage => _spriteImage;

  Future<void> _prepareThumbnailPreviews() async {
    final sprite = Uri.tryParse(_nowPlaying.value?.spriteVttUrl ?? "");

    if (sprite == null) {
      _spriteVtt = null;
      _spriteImage = null;
      return notifyListeners();
    }

    if (sprite.scheme == "file") {
      _spriteVtt = File(sprite.toFilePath()).readAsBytesSync();
    } else {
      http.Response response = await http.get(sprite);
      _spriteVtt = response.bodyBytes;
    }

    final String vttData = String.fromCharCodes(_spriteVtt!);

    final controller = VttDataController.string(vttData);
    if (disposed || controller.vttData.isEmpty) return;

    final Completer<ui.Image> loadUiImage = Completer<ui.Image>();
    final imagePathSegments = List.of(sprite.pathSegments);
    imagePathSegments.last = controller.vttData.first.imageUrl;

    if (disposed) return;
    if (sprite.scheme == "file") {
      final image = File(
        sprite.replace(pathSegments: imagePathSegments).toFilePath(),
      );
      ui.decodeImageFromList(image.readAsBytesSync(), loadUiImage.complete);
    } else {
      final image = await http.get(
        sprite.replace(pathSegments: imagePathSegments),
      );
      ui.decodeImageFromList(image.bodyBytes, loadUiImage.complete);
    }

    _spriteImage = await loadUiImage.future;
    previewThumbnailController.setCurrentTime(-1);
    if (!disposed) notifyListeners();
  }

  void showThumbnailPreview(double progress) {
    progress = progress.clamp(0.0, 1.0);
    final duration = kState.duration.value.inSeconds;
    if (duration <= 0) return;

    final target = Duration(seconds: (progress * duration).round());
    previewThumbnailController.setCurrentTime(target.inMilliseconds);
  }

  /// --------------------------------------------------------------------------
}
