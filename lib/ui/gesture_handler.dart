import 'package:flutter/material.dart';
import 'package:vidinfra_player/extensions.dart';
import 'package:vidinfra_player/ui/controls_overlay.dart';
import 'package:vidinfra_player/vidinfra_player.dart';

class GestureHandler extends StatelessWidget {
  final VidinfraPlayerController controller;
  final ControlsOverlay controls;

  const GestureHandler({
    super.key,
    required this.controller,
    required this.controls,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.controlsVisible.toggle,
      behavior: HitTestBehavior.translucent,
      child: controls,
    );
  }
}
