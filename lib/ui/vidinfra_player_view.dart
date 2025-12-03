import 'package:flutter/material.dart';
import 'package:kvideo/kvideo.dart';
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/controls_overlay.dart';
import 'package:vidinfra_player/ui/gesture_handler.dart';

class VidinfraPlayerView extends StatelessWidget {
  final double aspectRatio;
  final bool handleFullScreenBack;
  final VidinfraPlayerController controller;

  const VidinfraPlayerView({
    super.key,
    required this.controller,
    this.aspectRatio = 16 / 9,
    this.handleFullScreenBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      builder: (context, child) => Selector<VidinfraPlayerController, bool>(
        selector: (_, controller) => controller.inFullScreen,
        builder: (_, fullscreen, child) {
          if (!fullscreen) return child!;
          final widget = SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: child,
          );

          if (!handleFullScreenBack) return widget;
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (_, _) => controller.exitFullScreen(),
            child: widget,
          );
        },
        child: AspectRatio(
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
              const GestureHandler(
                controls: ControlsOverlay(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
