import 'package:flutter/widgets.dart';

class SegmentedSlider extends StatefulWidget {
  final void Function(int progress) onChanged;
  final ValueNotifier<int> min, max;
  final ValueNotifier<int?>? secondary;

  const SegmentedSlider({
    super.key,
    required this.onChanged,
    required this.min,
    required this.max,
    this.secondary,
  });

  @override
  State<SegmentedSlider> createState() => _SegmentedSliderState();
}

class _SegmentedSliderState extends State<SegmentedSlider> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
