import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/models.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/components/assets.dart';

typedef _State = ({Media? nowPlaying, bool inFullscreen});

class TopControlsOverlay extends StatelessWidget {
  const TopControlsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<VidinfraPlayerController, _State>(
      selector: (_, controller) => (
        nowPlaying: controller.nowPlaying,
        inFullscreen: controller.inFullScreen,
      ),
      child: IconButton(
        onPressed: context.read<VidinfraPlayerController>().exitFullScreen,
        icon: VidinfraIcons.back(),
      ),
      builder: (_, state, exitFullScreenIcon) => Row(
        spacing: 12,
        children: [
          if (state.inFullscreen) ?exitFullScreenIcon,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.nowPlaying?.title != null)
                  Text(
                    state.nowPlaying!.title,
                    style: TextTheme.of(context).bodyLarge?.copyWith(
                      fontSize: state.inFullscreen ? 18 : 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (state.nowPlaying?.description != null)
                  Text(
                    state.nowPlaying!.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextTheme.of(context).bodySmall?.copyWith(
                      fontSize: state.inFullscreen ? 14 : 10,
                      color: Colors.white.withAlpha(225),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
