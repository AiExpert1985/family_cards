// ============== widgets/common/app_card.dart ==============
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;

  const AppCard({super.key, required this.child, this.padding, this.color, this.elevation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );
  }
}
