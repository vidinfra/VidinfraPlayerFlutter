import 'package:flutter/material.dart';

class SegmentedSeekBar extends StatefulWidget {
  final List<double> segmentSizes;
  final double progress;
  final double buffer;

  final double barHeight;
  final double barRadius;
  final double thumbRadius;
  final double gap;

  final Color activeColor;
  final Color bufferColor;
  final Color inactiveColor;

  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  const SegmentedSeekBar({
    super.key,
    required this.segmentSizes,
    required this.progress,
    required this.buffer,

    this.onChangeStart,
    this.onChanged,
    this.onChangeEnd,

    this.barHeight = 2,
    this.barRadius = 2,
    this.thumbRadius = 7,
    this.gap = 3,

    this.activeColor = const Color(0xFF00FFDD),
    this.bufferColor = const Color(0x99FFFFFF),
    this.inactiveColor = const Color(0x66FFFFFF),
  });

  @override
  State<SegmentedSeekBar> createState() => _SegmentedSeekBarState();
}

class _SegmentedSeekBarState extends State<SegmentedSeekBar> {
  late List<double> _segmentFractions;
  late double _total;

  double _localProgress = 0;

  @override
  void initState() {
    super.initState();
    _localProgress = widget.progress;
    _computeSegments();
  }

  @override
  void didUpdateWidget(covariant SegmentedSeekBar old) {
    super.didUpdateWidget(old);
    if (old.segmentSizes != widget.segmentSizes) {
      _computeSegments();
    }
    _localProgress = widget.progress;
  }

  void _computeSegments() {
    _total = widget.segmentSizes.fold(0.0, (a, b) => a + b);
    _segmentFractions = widget.segmentSizes.map((s) => s / _total).toList();
  }

  double _posToProgress(double x, double width) {
    return (x / width).clamp(0.0, 1.0);
  }

  void _setProgress(double v) {
    setState(() => _localProgress = v);
    widget.onChanged?.call(v); // fires while changing
  }

  double get totalHeight => widget.barHeight + widget.thumbRadius * 2;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final width = constraints.maxWidth;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,

        onHorizontalDragStart: (d) {
          final v = _posToProgress(d.localPosition.dx, width);
          widget.onChangeStart?.call(v);
          _setProgress(v);
        },

        onHorizontalDragUpdate: (d) {
          _setProgress(_posToProgress(d.localPosition.dx, width));
        },

        onHorizontalDragEnd: (_) {
          widget.onChangeEnd?.call(_localProgress);
        },

        onTapDown: (d) {
          final v = _posToProgress(d.localPosition.dx, width);
          widget.onChangeStart?.call(v);
          _setProgress(v);
        },

        onTapUp: (_) {
          widget.onChangeEnd?.call(_localProgress);
        },

        child: SizedBox(
          height: totalHeight,
          child: CustomPaint(
            size: Size(double.infinity, totalHeight),
            painter: _SegmentedPainter(
              progress: _localProgress,
              buffer: widget.buffer,
              segmentFractions: _segmentFractions,
              gap: widget.gap,
              barHeight: widget.barHeight,
              barRadius: widget.barRadius,
              thumbRadius: widget.thumbRadius,
              activeColor: widget.activeColor,
              bufferColor: widget.bufferColor,
              inactiveColor: widget.inactiveColor,
            ),
          ),
        ),
      );
    },
  );
}

class _SegmentedPainter extends CustomPainter {
  final double progress;
  final double buffer;
  final List<double> segmentFractions;

  final double gap;
  final double barHeight;
  final double barRadius;
  final double thumbRadius;

  final Color activeColor;
  final Color bufferColor;
  final Color inactiveColor;

  late final Paint inactivePaint;
  late final Paint bufferPaint;
  late final Paint activePaint;
  late final Paint thumbPaint;

  _SegmentedPainter({
    required this.progress,
    required this.buffer,
    required this.segmentFractions,
    required this.gap,
    required this.barHeight,
    required this.barRadius,
    required this.thumbRadius,
    required this.activeColor,
    required this.bufferColor,
    required this.inactiveColor,
  }) {
    inactivePaint = Paint()..color = inactiveColor;
    bufferPaint = Paint()..color = bufferColor;
    activePaint = Paint()..color = activeColor;
    thumbPaint = Paint()..color = activeColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final barWidth = size.width - thumbRadius * 2;
    final gapWidth = gap * (segmentFractions.length - 1);

    // Convert progress to absolute X
    final progressX = startX + progress * barWidth;
    final bufferX = startX + gapWidth + buffer * barWidth;

    for (int i = 0; i < segmentFractions.length; i++) {
      final segW = segmentFractions[i] * barWidth;

      final isFirst = i == 0;
      final isLast = i == segmentFractions.length - 1;

      final double left = startX;
      final double right = startX + segW;

      // background fill
      final rectBG = _rounded(
        left,
        right,
        size,
        isFirst,
        isLast,
        barRadius,
      );
      canvas.drawRRect(rectBG, inactivePaint);

      // buffer fill
      if (bufferX > left) {
        final fillRight = bufferX.clamp(left, right);
        final rectBuffer = _rounded(
          left,
          fillRight,
          size,
          isFirst,
          isLast && fillRight == right,
          barRadius,
        );
        canvas.drawRRect(rectBuffer, bufferPaint);
      }

      // progress fill
      if (progressX > left) {
        final fillRight = progressX.clamp(left, right);
        final rectProg = _rounded(
          left,
          fillRight,
          size,
          isFirst,
          isLast && fillRight == right,
          barRadius,
        );
        canvas.drawRRect(rectProg, activePaint);
      }

      startX = right + gap;
    }

    // draw thumb
    canvas.drawCircle(
      Offset(progressX + thumbRadius, size.height / 2),
      thumbRadius,
      thumbPaint,
    );
  }

  RRect _rounded(
    double left,
    double right,
    Size size,
    bool isFirst,
    bool isLast,
    double radius,
  ) {
    return RRect.fromRectAndCorners(
      Rect.fromLTRB(
        left,
        (size.height - barHeight) / 2,
        right,
        (size.height + barHeight) / 2,
      ),
      topLeft: isFirst ? Radius.circular(radius) : Radius.zero,
      bottomLeft: isFirst ? Radius.circular(radius) : Radius.zero,
      topRight: isLast ? Radius.circular(radius) : Radius.zero,
      bottomRight: isLast ? Radius.circular(radius) : Radius.zero,
    );
  }

  @override
  bool shouldRepaint(covariant _SegmentedPainter old) =>
      old.progress != progress ||
      old.buffer != buffer ||
      old.segmentFractions != segmentFractions;
}
