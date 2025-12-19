part of 'vidinfra_player_controller.dart';

mixin PlaybackSettingsMixin {
  /// Must be overridden -------------------------------------------------------

  k.PlayerController get kController;

  k.PlayerState get kState;

  Configuration get configuration;

  ValueNotifier<Media?> get _nowPlaying;

  void notifyListeners();

  /// Must be Called -----------------------------------------------------------

  Future<void> initializePlaybackSettingsMixin() async {
    kState.tracks.addListener(_prepareTracks);
    _nowPlaying.addListener(_reApplySelections);
  }

  void disposePlaybackSettingsMixin() {
    kState.tracks.removeListener(_prepareTracks);
    _nowPlaying.removeListener(_reApplySelections);
  }

  /// --------------------------------------------------------------------------

  List<k.TrackData> _tracks = List.of([]);

  List<k.TrackData> get videoTracks => List.of(
    _tracks.where((track) => track.type == k.TrackType.video),
  );

  k.TrackData? _currentTrack;

  k.TrackData? get videoTrack => _currentTrack;

  double _speed = 1.0;

  double get playbackSpeed => _speed;

  void _prepareTracks() {
    _tracks = List.of(kState.tracks.value);
    notifyListeners();
  }

  void selectVideoTrack(k.TrackData? track) {
    _currentTrack = track;
    kController.setTrackPreference(track);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _speed = speed;
    kController.setPlaybackSpeed(speed);
    notifyListeners();
  }

  void _reApplySelections() {
    kController.setTrackPreference(_currentTrack);
    kController.setPlaybackSpeed(_speed);
  }
}
