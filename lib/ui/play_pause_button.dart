import 'package:flutter/material.dart';
import 'package:kvideo/gen/pigeon.g.dart' as k;
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/components/assets.dart';

class PlayPauseButton extends StatelessWidget {
  final bool showWhileLoading;
  final double? size;

  const PlayPauseButton({
    super.key,
    this.showWhileLoading = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.read<VidinfraPlayerController>();

    return ValueListenableBuilder(
      valueListenable: controller.kState.status,
      builder: (_, status, _) {
        final loading = status == k.PlaybackStatus.preparing;
        final playing = status == k.PlaybackStatus.playing;
        if (loading && !showWhileLoading) return const SizedBox();
        return AnimatedSwitcher(
          duration: Durations.short4,
          transitionBuilder: (c, s) => ScaleTransition(scale: s, child: c),
          child: playing ? _pause(controller) : _resume(controller),
        );
      },
    );
  }

  Widget _resume(VidinfraPlayerController controller) {
    return IconButton(
      key: const ValueKey(true),
      onPressed: () {
        controller.kController.resume();
        controller.autoHideControls();
      },
      icon: VidinfraIcons.play(size: size),
    );
  }

  Widget _pause(VidinfraPlayerController controller) {
    return IconButton(
      key: const ValueKey(false),
      onPressed: () {
        controller.kController.pause();
        controller.autoHideControls();
      },
      icon: VidinfraIcons.pause(size: size),
    );
  }
}
