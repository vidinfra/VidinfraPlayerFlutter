import 'package:flutter/material.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';

class TopControlsOverlay extends StatelessWidget {
  final VidinfraPlayerController controller;

  const TopControlsOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: () {}, child: Text("HIII"));
  }
}
