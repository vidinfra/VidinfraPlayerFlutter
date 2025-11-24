import 'package:flutter/material.dart';
import 'package:kvideo/kvideo.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/controls_overlay.dart';
import 'package:vidinfra_player/ui/gesture_handler.dart';

class VidinfraPlayerView extends StatelessWidget {
  final double aspectRatio;
  final VidinfraPlayerController controller;

  const VidinfraPlayerView({
    super.key,
    required this.controller,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF000000)),
          PlayerView(controller.kController),
          Align(
            child: ValueListenableBuilder(
              valueListenable: controller.loading,
              child: const CircularProgressIndicator(),
              builder: (_, loading, indicator) => AnimatedSwitcher(
                duration: Durations.medium3,
                child: loading ? indicator! : const SizedBox.shrink(),
              ),
            ),
          ),
          // TODO Subtitle View
          GestureHandler(
            controller: controller,
            controls: ControlsOverlay(controller: controller),
          ),
        ],
      ),
    );
  }
}
