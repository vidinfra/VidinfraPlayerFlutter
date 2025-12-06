import 'package:flutter/material.dart';

class RotateIconButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Duration duration;
  final bool reverse;

  const RotateIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.duration = Durations.medium4,
    this.reverse = false,
  });

  @override
  State<RotateIconButton> createState() => _RotateIconButtonState();
}

class _RotateIconButtonState extends State<RotateIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPressed() async {
    Future.delayed(widget.duration, widget.onPressed);

    _controller.reset();

    if (widget.reverse) {
      await _controller.reverse(from: 1.0);
    } else {
      await _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller.drive(Tween(begin: 0.0, end: 1.0)),
      child: IconButton(
        icon: widget.icon,
        highlightColor: Colors.transparent,
        onPressed: _onPressed,
      ),
    );
  }
}
