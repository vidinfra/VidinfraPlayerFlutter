import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_preview_thumbnails/video_preview_thumbnails.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/extensions.dart';

/// Must be placed inside a Stack
class PositionedThumbnailPreview extends StatelessWidget {
  const PositionedThumbnailPreview({super.key});

  VidinfraPlayerController controller(BuildContext context) => context.read();

  VideoPreviewThumbnailsController thumbnailController(BuildContext context) {
    return controller(context).previewThumbnailController;
  }

  double maxWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

  double bottomMargin(BuildContext context) {
    return context.read<VidinfraPlayerController>().inFullScreen ? 98 : 78;
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: thumbnailController(context),
    builder: (_, value, child) {
      if (!shouldShow(context)) return const SizedBox.shrink();

      final total = controller(context).kState.duration.value.inMilliseconds;
      final current = value.currentTimeMilliseconds;

      final positionX = (maxWidth(context) - 156) / (total / current);

      return AnimatedPositioned(
        duration: Durations.short3,
        left: positionX.clamp(0, maxWidth(context)),
        bottom: bottomMargin(context),
        child: child!,
      );
    },

    child: Container(
      height: 87,
      width: 156,
      clipBehavior: Clip.antiAlias,
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Selector<VidinfraPlayerController, Uint8List?>(
              selector: (_, controller) => controller.spriteVtt,
              builder: (_, vtt, child) {
                if (vtt == null) return const SizedBox();
                return VideoPreviewThumbnails(
                  vtt: vtt,
                  controller: thumbnailController(context),
                  image: controller(context).spriteImage,
                );
              },
            ),
          ),
          Positioned(bottom: 8, right: 8, child: timestampText(context)),
        ],
      ),
    ),
  );

  Widget timestampText(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: const Color(0x66000000),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ValueListenableBuilder(
          valueListenable: thumbnailController(context),
          builder: (_, value, _) => Text(
            Duration(milliseconds: value.currentTimeMilliseconds).toHHMMSS(),
            style: TextTheme.of(context).bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  bool shouldShow(BuildContext context) {
    if (controller(context).spriteVtt == null) return false;
    if (controller(context).spriteImage == null) return false;
    if (thumbnailController(context).getCurrentTime().isNegative) return false;
    return true;
  }
}
