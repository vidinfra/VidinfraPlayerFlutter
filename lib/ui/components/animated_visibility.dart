import 'package:flutter/widgets.dart';

enum SlideDirection { none, up, down, left, right }

class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final SlideDirection slideInDirection;
  final Curve curve;

  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.slideInDirection = SlideDirection.none,
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: getBeginOffset(),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: ClipRect(
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          ),
        );
      },
      child: visible ? child : const SizedBox.shrink(key: ValueKey(null)),
    );
  }

  Offset getBeginOffset() {
    switch (slideInDirection) {
      case SlideDirection.up:
        return const Offset(0, 0.1);
      case SlideDirection.down:
        return const Offset(0, -0.1);
      case SlideDirection.left:
        return const Offset(0.1, 0);
      case SlideDirection.right:
        return const Offset(-0.1, 0);
      case SlideDirection.none:
        return Offset.zero;
    }
  }
}
