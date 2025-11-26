// ============== widgets/animations/animated_counter.dart ==============
import 'package:flutter/material.dart';

/// Number counter with smooth count-up animation
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return Text(
          '$animatedValue',
          style: style,
        );
      },
    );
  }
}

/// Percentage counter with smooth animation
class AnimatedPercentage extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final int decimals;

  const AnimatedPercentage({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return Text(
          '${animatedValue.toStringAsFixed(decimals)}%',
          style: style,
        );
      },
    );
  }
}
