// ============== widgets/common/modern_tab_indicator.dart ==============
import 'package:flutter/material.dart';

/// Modern pill-shaped tab indicator with gradient
class ModernTabIndicator extends Decoration {
  final Color color;
  final double height;
  final double radius;

  const ModernTabIndicator({
    required this.color,
    this.height = 4,
    this.radius = 2,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ModernTabIndicatorPainter(
      color: color,
      height: height,
      radius: radius,
      onChanged: onChanged,
    );
  }
}

class _ModernTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double height;
  final double radius;

  _ModernTabIndicatorPainter({
    required this.color,
    required this.height,
    required this.radius,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size size = configuration.size!;
    final Rect rect = Offset(
          offset.dx + (size.width - 40) / 2,
          offset.dy + size.height - height,
        ) &
        Size(40, height);

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }
}
