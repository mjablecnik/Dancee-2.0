import 'package:flutter/material.dart';
import '../../../../core/colors.dart';

class BackgroundCircles extends StatelessWidget {
  final Animation<double> animation;

  const BackgroundCircles({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 80 + animation.value,
              left: 40,
              child: _buildCircle(128, appPrimary.withValues(alpha: 0.2)),
            ),
            Positioned(
              top: 240 - animation.value,
              right: 32,
              child: _buildCircle(96, appAccent.withValues(alpha: 0.2)),
            ),
            Positioned(
              bottom: 160 + animation.value * 0.5,
              left: 24,
              child: _buildCircle(80, appSuccess.withValues(alpha: 0.2)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 1.5,
            spreadRadius: size * 0.5,
          ),
        ],
      ),
    );
  }
}
