// ============== widgets/animations/animated_trophy.dart ==============
import 'package:flutter/material.dart';

/// Trophy icon with scale pop-in animation
class AnimatedTrophy extends StatefulWidget {
  final int index;
  final bool isShared;
  final DateTime date;
  final int delayMilliseconds;

  const AnimatedTrophy({
    super.key,
    required this.index,
    required this.isShared,
    required this.date,
    this.delayMilliseconds = 100,
  });

  @override
  State<AnimatedTrophy> createState() => _AnimatedTrophyState();
}

class _AnimatedTrophyState extends State<AnimatedTrophy>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Stagger animation based on index
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delayMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: widget.isShared ? Colors.brown : Colors.amber,
            size: 20,
          ),
          Text(
            '${widget.date.day}/${widget.date.month}',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${widget.date.year}',
            style: const TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
