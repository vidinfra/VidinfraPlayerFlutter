import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

class _VidinfraIcon {
  final String file;

  const _VidinfraIcon(this.file);

  Widget call({
    double? size,
    double? width,
    double? height,
    ColorFilter? colorFilter,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    Key? key,
  }) => VectorGraphic(
    key: key,
    loader: AssetBytesLoader(
      'assets/icons/$file',
      packageName: 'vidinfra_player',
    ),
    width: size ?? width,
    height: size ?? height,
    fit: fit,
    alignment: alignment,
    colorFilter: colorFilter,
  );
}

class VidinfraIcons {
  const VidinfraIcons._();

  static const tenbyte = _VidinfraIcon('Tenbyte.svg');
  static const tenbyteSmall = _VidinfraIcon('Tenbyte Small.svg');
  static const play = _VidinfraIcon('Play.svg');
  static const pause = _VidinfraIcon('Pause.svg');
  static const brightness = _VidinfraIcon('Brightness Icon.svg');
  static const fitScreen = _VidinfraIcon('Fit Screen.svg');
  static const pip = _VidinfraIcon('Picture in picture.svg');
  static const settings = _VidinfraIcon('Settings.svg');
  static const quality = _VidinfraIcon('Quality Icon.svg');
  static const subtitle = _VidinfraIcon('Subtitle Icon.svg');
  static const playbackSpeed = _VidinfraIcon('Playback Speed Icon.svg');

  static const forwardSmall = _VidinfraIcon('Forward Small.svg');
  static const backwardSmall = _VidinfraIcon('Backward Small.svg');
  static const forward10 = _VidinfraIcon('10 Seconds Forward.svg');
  static const backward10 = _VidinfraIcon('10 Seconds Back.svg');

  static const volumeHigh = _VidinfraIcon('Volume high.svg');
  static const volumeMid = _VidinfraIcon('Volume mid.svg');
  static const volumeLow = _VidinfraIcon('Volume low.svg');
  static const volumeNone = _VidinfraIcon('Volume none.svg');
}
