import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/components/assets.dart';

class BottomControlsOverlay extends StatelessWidget {
  final VidinfraPlayerController controller;

  const BottomControlsOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black26, Colors.black54],
        ),
      ),
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
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
              IconButton(
                onPressed: () => controller.kController.enterPiPMode(),
                icon: VidinfraIcons.pip(),
              ),
              // IconButton(
              //   onPressed: () {
              //     controller.autoHideControls();
              //     controller.kController.getFit().then((fit) {
              //       controller.kController.setFit(
              //         fit == BoxFitMode.fit ? BoxFitMode.fill : BoxFitMode.fit,
              //       );
              //     });
              //   },
              //   icon: VidinfraIcons.fitScreen(),
              // ),
              const Spacer(),
              VidinfraIcons.tenbyte(),
            ],
          ),
        ],
      ),
    );
  }
}
