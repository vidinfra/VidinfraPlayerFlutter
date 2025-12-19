import 'package:flutter/material.dart';
import 'package:kvideo/gen/pigeon.g.dart' as k;
import 'package:provider/provider.dart';
import 'package:vidinfra_player/controller/vidinfra_player_controller.dart';
import 'package:vidinfra_player/ui/components/assets.dart';

import '../../extensions.dart';

enum _SelectedSubMenu { quality, speed }

typedef _QualityMenuState = ({List<k.TrackData> tracks, k.TrackData? selected});

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  VidinfraPlayerController get controller => context.read();

  final MenuStyle menuStyle = const MenuStyle(
    backgroundColor: WidgetStatePropertyAll(Color(0xE6222222)),
    padding: WidgetStatePropertyAll(EdgeInsets.all(8)),
    visualDensity: VisualDensity.compact,
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );

  late final ButtonStyle subMenuStyle = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
    ),
    textStyle: WidgetStatePropertyAll(TextTheme.of(context).bodyMedium),
    foregroundColor: const WidgetStatePropertyAll(Colors.white),
  );

  _SelectedSubMenu? selectedSubMenu;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(-48, 16),
      consumeOutsideTap: true,
      useRootOverlay: true,
      style: menuStyle,
      builder: (_, menu, _) => IconButton(
        icon: VidinfraIcons.settings(),
        onPressed: () {
          if (menu.isOpen) return menu.close();
          menu.open();
          controller.cancelControlAutoHide();
        },
      ),
      onClose: () {
        setState(() => selectedSubMenu = null);
        controller.autoHideControls();
      },
      menuChildren: [
        switch (selectedSubMenu) {
          null => Column(
            mainAxisSize: MainAxisSize.min,
            children: mainMenu(),
          ),
          _SelectedSubMenu.quality => qualitySubMenu(),
          _SelectedSubMenu.speed => speedSubMenu(),
        },
      ],
    );
  }

  List<Widget> mainMenu() {
    return [
      MenuItemButton(
        closeOnActivate: false,
        style: subMenuStyle,
        leadingIcon: VidinfraIcons.quality(),
        trailingIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 32),
            Selector<VidinfraPlayerController, k.TrackData?>(
              selector: (_, controller) => controller.videoTrack,
              builder: (_, value, child) {
                if (value == null) return child!;
                return Text("${value.height}p");
              },
              child: const Text("Auto"),
            ),
            VidinfraIcons.forwardSmall(size: 18),
          ],
        ),
        child: const Text("Quality"),
        onPressed: () => setState(
          () => selectedSubMenu = _SelectedSubMenu.quality,
        ),
      ),

      MenuItemButton(
        closeOnActivate: false,
        style: subMenuStyle,
        leadingIcon: VidinfraIcons.playbackSpeed(),
        trailingIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 32),
            Selector<VidinfraPlayerController, double>(
              selector: (_, controller) => controller.playbackSpeed,
              builder: (_, value, _) => Text("${value.withoutZeroDecimal}x"),
            ),
            VidinfraIcons.forwardSmall(size: 18),
          ],
        ),
        child: const Text("Playback Speed"),
        onPressed: () => setState(
          () => selectedSubMenu = _SelectedSubMenu.speed,
        ),
      ),
    ];
  }

  Widget qualitySubMenu() {
    return Selector<VidinfraPlayerController, _QualityMenuState>(
      selector: (_, controller) => (
        tracks: controller.videoTracks,
        selected: controller.videoTrack,
      ),
      child: TextButton.icon(
        onPressed: () => setState(() => selectedSubMenu = null),
        style: subMenuStyle,
        icon: VidinfraIcons.back(size: 18),
        label: const Text("Video Quality"),
      ),
      builder: (_, data, header) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?header,
            MenuItemButton(
              closeOnActivate: true,
              leadingIcon: _activeIndicator(data.selected, null),
              child: const Padding(
                padding: EdgeInsets.only(right: 100),
                child: Text("Auto"),
              ),
              onPressed: () => controller.selectVideoTrack(null),
            ),
            for (final track in data.tracks)
              MenuItemButton(
                closeOnActivate: true,
                leadingIcon: _activeIndicator(data.selected, track),
                child: Text("${track.height}p"),
                onPressed: () => controller.selectVideoTrack(track),
              ),
          ],
        ),
      ),
    );
  }

  Widget speedSubMenu() {
    return Selector<VidinfraPlayerController, double>(
      selector: (_, controller) => controller.playbackSpeed,
      child: TextButton.icon(
        onPressed: () => setState(() => selectedSubMenu = null),
        style: subMenuStyle,
        icon: VidinfraIcons.back(size: 18),
        label: const Text("Playback Speed"),
      ),
      builder: (_, activeSpeed, header) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?header,
            for (final speed in controller.configuration.playbackSpeeds) ...{
              MenuItemButton(
                closeOnActivate: true,
                leadingIcon: _activeIndicator(activeSpeed, speed),
                child: Text("${speed.withoutZeroDecimal}x"),
                onPressed: () => controller.setPlaybackSpeed(speed),
              ),
            },
          ],
        ),
      ),
    );
  }

  Widget? _activeIndicator<T>(T a, T b) {
    return a == b
        ? VidinfraIcons.checkmark(size: 18)
        : const SizedBox(width: 18);
  }
}
