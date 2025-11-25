part of 'vidinfra_player_controller.dart';

mixin UiControllerMixin {
  k.PlayerState get kState;

  /// This will be used and toggled by ui
  final ValueNotifier<bool> controlsVisible = ValueNotifier(true);
  Timer? _controlsHideTimer;

  /// Whether to show loading indicator
  final ValueNotifier<bool> loading = ValueNotifier(false);

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
}
