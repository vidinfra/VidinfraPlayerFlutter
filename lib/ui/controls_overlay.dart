import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/components/animated_visibility.dart';
import 'package:vidinfra_player/ui/components/assets.dart';
import 'package:vidinfra_player/ui/controls/bottom_controls_overlay.dart';
import 'package:vidinfra_player/ui/controls/play_pause_button.dart';
import 'package:vidinfra_player/ui/controls/top_controls_overlay.dart';

import 'components/rotate_icon_button.dart';
import 'components/thumbnail_preview.dart';

class ControlsOverlay extends StatelessWidget {
  const ControlsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<VidinfraPlayerController>();
    final inFullScreen = context.select<VidinfraPlayerController, bool>(
      (value) => value.inFullScreen,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ValueListenableBuilder(
            valueListenable: controller.controlsVisible,
            builder: (_, visible, child) => AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: Durations.medium1,
              child: child,
            ),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x99000000),
                    Color(0x40000000),
                    Color(0x40000000),
                    Color(0x99000000),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: inFullScreen ? 24 : 16,
          left: inFullScreen ? 48 : 16,
          right: inFullScreen ? 48 : 16,
          child: ValueListenableBuilder(
            valueListenable: controller.controlsVisible,
            builder: (_, visible, child) => AnimatedVisibility(
              slideInDirection: SlideDirection.down,
              visible: visible,
              child: child!,
            ),
            child: const TopControlsOverlay(),
          ),
        ),
        Positioned(
          bottom: inFullScreen ? 24 : 16,
          left: inFullScreen ? 48 : 16,
          right: inFullScreen ? 48 : 16,
          child: ValueListenableBuilder(
            valueListenable: controller.controlsVisible,
            builder: (_, visible, child) => AnimatedVisibility(
              slideInDirection: SlideDirection.up,
              visible: visible,
              child: child!,
            ),
            child: const BottomControlsOverlay(),
          ),
        ),
        Align(
          child: ValueListenableBuilder(
            valueListenable: controller.controlsVisible,
            builder: (_, visible, child) => AnimatedVisibility(
              visible: visible,
              child: child!,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 48,
              children: [
                if (controller.configuration.controls.backward)
                  RotateIconButton(
                    onPressed: () {
                      controller.kController.seekBack();
                      controller.autoHideControls();
                    },
                    icon: VidinfraIcons.backward10(size: 28),
                    reverse: true,
                  )
                else
                  const SizedBox.shrink(),

                if (controller.configuration.controls.bigPlayButton)
                  const SizedBox.square(
                    dimension: 48,
                    child: PlayPauseButton(size: 42),
                  )
                else
                  const SizedBox.shrink(),

                if (controller.configuration.controls.backward)
                  RotateIconButton(
                    onPressed: () {
                      controller.kController.seekForward();
                      controller.autoHideControls();
                    },
                    icon: VidinfraIcons.forward10(size: 28),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),

        const PositionedThumbnailPreview(),
      ],
    );
  }
}
