import 'package:flutter/material.dart';
import 'package:kvideo/kvideo.dart';
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/controls_overlay.dart';
import 'package:vidinfra_player/ui/gesture_handler.dart';

import 'components/assets.dart';

class VidinfraPlayerView extends StatelessWidget {
  final double aspectRatio;
  final bool handleFullScreenBack;
  final VidinfraPlayerController controller;

  /// Will be shown while status is preparing. Defaults to `CircularProgressIndicator`
  final Widget? placeholder;

  const VidinfraPlayerView({
    super.key,
    required this.controller,
    this.aspectRatio = 16 / 9,
    this.handleFullScreenBack = true,
    this.placeholder,
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
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: controller.kState.pipMode,
                  builder: (_, pip, child) {
                    if (!pip) return const SizedBox.shrink();
                    return ColoredBox(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          VidinfraIcons.pip(size: 48),
                          const Text(
                            "Playing in Picture in Picture Mode",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Align(
                child: ValueListenableBuilder(
                  valueListenable: controller.loading,
                  child: placeholder ?? const CircularProgressIndicator(),
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
