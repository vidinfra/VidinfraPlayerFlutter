import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/components/assets.dart';
import 'package:vidinfra_player/ui/play_pause_button.dart';

typedef _SelectorState = ({bool inFullScreen});

class BottomControlsOverlay extends StatelessWidget {
  const BottomControlsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<VidinfraPlayerController>();

    return Selector<VidinfraPlayerController, _SelectorState>(
      selector: (_, controller) => (
        inFullScreen: controller.inFullScreen,
      ),
      builder: (_, state, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder(
            valueListenable: controller.kState.progress,
            builder: (context, value, child) {
              final duration = controller.kState.duration.value.inSeconds;
              return Slider(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                max: duration.toDouble(),
                value: math.min(value.inSeconds, duration).toDouble(),
                // TODO Use onChangeEnd
                onChanged: (value) => controller.kController.seekTo(
                  Duration(seconds: value.toInt()),
                ),
              );
            },
          ),
          Row(
            children: [
              const PlayPauseButton(),

              if (state.inFullScreen) ...[
                IconButton(
                  onPressed: controller.toggleMute,
                  icon: VidinfraIcons.volumeNone(),
                ),
                const Spacer(),
              ] else ...[
                const Spacer(),
                IconButton(
                  onPressed: controller.toggleMute,
                  icon: VidinfraIcons.volumeNone(),
                ),
              ],

              IconButton(
                onPressed: () {},
                icon: VidinfraIcons.settings(),
              ),

              IconButton(
                onPressed: controller.kController.enterPiPMode,
                icon: VidinfraIcons.pip(),
              ),

              if (!state.inFullScreen) ...[
                IconButton(
                  onPressed: controller.enterFullScreen,
                  icon: VidinfraIcons.fitScreen(),
                ),
                VidinfraIcons.tenbyteSmall(),
              ] else ...[
                IconButton(
                  onPressed: controller.toggleBoxFit,
                  icon: VidinfraIcons.fitScreen(),
                ),
                VidinfraIcons.tenbyte(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
