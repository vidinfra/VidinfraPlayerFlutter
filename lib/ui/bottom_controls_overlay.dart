import 'package:flutter/material.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/components/assets.dart';

class BottomControlsOverlay extends StatelessWidget {
  final VidinfraPlayerController controller;

  const BottomControlsOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black26, Colors.black54],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: () {}, child: Text("BYEE")),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  controller.kController.enterPiPMode();
                },
                icon: VidinfraIcons.pip(),
              ),
              const Spacer(),
              VidinfraIcons.tenbyte(),
            ],
          ),
        ],
      ),
    );
  }
}
