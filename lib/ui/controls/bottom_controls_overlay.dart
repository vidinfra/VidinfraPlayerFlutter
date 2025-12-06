import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/extensions.dart';
import 'package:vidinfra_player/ui/components/assets.dart';
import 'package:vidinfra_player/ui/components/segmented_seekbar.dart';
import 'package:vidinfra_player/ui/controls/play_pause_button.dart';
import 'package:vidinfra_player/ui/settings_menu/settings_menu.dart';

typedef _SelectorState = ({
  bool inFullScreen,
  double? progress,
  double buffer,
});

class BottomControlsOverlay extends StatelessWidget {
  const BottomControlsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<VidinfraPlayerController>();

    return Selector<VidinfraPlayerController, _SelectorState>(
      selector: (_, controller) => (
        inFullScreen: controller.inFullScreen,
        progress: controller.progress,
        buffer: controller.buffer,
      ),
      builder: (_, state, _) => Column(
        mainAxisSize: MainAxisSize.min,
        spacing: state.inFullScreen ? 16 : 10,
        children: [
          /// Progress Indicator / SeekBar
          if (state.progress != null) ...{
            if (state.inFullScreen) ...{
              Row(
                spacing: 12,
                children: [
                  _progressTextBuilder(context, controller.kState.progress),
                  Expanded(child: _seekBar(controller, state)),
                  _progressTextBuilder(context, controller.kState.duration),
                ],
              ),
            } else ...{
              _seekBar(controller, state),
            },
          },

          /// Control Buttons
          Row(
            spacing: 12,
            children: [
              const PlayPauseButton(showWhileLoading: true),

              if (state.inFullScreen) ...[
                _muteIcon(controller),
                const Spacer(),
              ] else ...[
                if (state.progress != null) ...{
                  _progressTextBuilder(context, controller.kState.progress),
                  ?_chaptersButton(context, controller),
                },

                const Spacer(),
                _muteIcon(controller),
              ],

              const SettingsMenu(),

              IconButton(
                onPressed: () {
                  if (state.inFullScreen) controller.exitFullScreen();
                  controller.kController.enterPiPMode();
                },
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

  Widget _muteIcon(VidinfraPlayerController controller) {
    return Selector<VidinfraPlayerController, bool>(
      selector: (_, controller) => controller.isMuted,
      child: VidinfraIcons.volumeNone(key: const ValueKey(false)),
      builder: (_, muted, child) {
        return IconButton(
          onPressed: controller.toggleMute,
          icon: AnimatedSwitcher(
            duration: Durations.short4,
            transitionBuilder: (c, s) => ScaleTransition(scale: s, child: c),
            child: muted ? child! : VidinfraIcons.volumeHigh(),
          ),
        );
      },
    );
  }

  Widget _seekBar(VidinfraPlayerController controller, _SelectorState state) {
    return SegmentedSeekBar(
      // segmentSizes: [16, 21, 70], TODO
      progress: state.progress!,
      buffer: state.buffer,
      onChangeStart: (_) {
        controller.kController.pause();
        controller.cancelControlAutoHide();
      },
      onChanged: (progress) {
        controller.cancelControlAutoHide();
        controller.showThumbnailPreview(progress);
      },
      onChangeEnd: (progress) {
        controller.seekTo(progress);
        controller.autoHideControls();
        controller.kController.resume();
      },
    );
  }

  Widget _progressTextBuilder(
    BuildContext context,
    ValueNotifier<Duration> value,
  ) {
    return ValueListenableBuilder(
      valueListenable: value,
      builder: (_, value, _) => Text(
        value.toHHMMSS(),
        style: TextTheme.of(context).bodySmall?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget? _chaptersButton(
    BuildContext context,
    VidinfraPlayerController controller,
  ) {
    return null; // TODO
    return TextButton(
      style: TextButton.styleFrom(
        textStyle: TextTheme.of(context).bodySmall,
        padding: const EdgeInsets.symmetric(vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        iconAlignment: IconAlignment.end,
      ),
      onPressed: () {},
      child: Row(
        spacing: 4,
        children: [
          const Text(
            "\u2022   Chapters",
            style: TextStyle(color: Colors.white),
          ),
          VidinfraIcons.forward(size: 16),
        ],
      ),
    );
  }
}
