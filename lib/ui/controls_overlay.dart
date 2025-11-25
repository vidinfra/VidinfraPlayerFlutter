import 'package:flutter/material.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/bottom_controls_overlay.dart';
import 'package:vidinfra_player/ui/components/animated_visibility.dart';
import 'package:vidinfra_player/ui/play_pause_button.dart';
import 'package:vidinfra_player/ui/top_controls_overlay.dart';

class ControlsOverlay extends StatelessWidget {
  final VidinfraPlayerController controller;

  const ControlsOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ValueListenableBuilder(
            valueListenable: controller.controlsVisible,
            builder: (_, visible, child) => AnimatedVisibility(
              slideInDirection: SlideDirection.down,
              visible: visible,
              child: child!,
            ),
            child: TopControlsOverlay(controller: controller),
          ),
        ),
        Align(
          child: ValueListenableBuilder(
            valueListenable: controller.controlsVisible,
            builder: (_, visible, child) => AnimatedVisibility(
              visible: visible,
              child: child!,
            ),
            child: PlayPauseButton(controller: controller, size: 42),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: ValueListenableBuilder(
            valueListenable: controller.controlsVisible,
            builder: (_, visible, child) => AnimatedVisibility(
              slideInDirection: SlideDirection.up,
              visible: visible,
              child: child!,
            ),
            child: BottomControlsOverlay(controller: controller),
          ),
        ),
      ],
    );
  }
}

// ValueListenableBuilder(
// valueListenable: controller.controlsVisible,
// child: controls,
// builder: (_, visible, child) => AnimatedSwitcher(
// duration: Durations.medium3,
// // Without key, the fade out doesn't work
// child: visible ? child : SizedBox.shrink(key: ValueKey(null)),
// ),
// ),
