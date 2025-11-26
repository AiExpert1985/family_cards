// ============== widgets/animations/animated_progress_bar.dart ==============
import 'package:flutter/material.dart';

/// Animated progress bar with gradient support
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Gradient? gradient;
  final double height;
  final Duration duration;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.gradient,
    this.height = 4,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value / 100),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: animatedValue,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: gradient != null
                ? null
                : AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
            minHeight: height,
          ),
        );
      },
    );
  }
}

/// Circular progress indicator with percentage
class AnimatedCircularProgress extends StatelessWidget {
  final double percentage;
  final Color color;
  final Widget child;
  final double strokeWidth;
  final Duration duration;

  const AnimatedCircularProgress({
    super.key,
    required this.percentage,
    required this.color,
    required this.child,
    this.strokeWidth = 3,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: percentage / 100),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}
