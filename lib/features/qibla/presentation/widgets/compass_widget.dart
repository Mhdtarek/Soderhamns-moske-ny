import 'dart:math' as math;

import 'package:flutter/material.dart';

// basic compass just circle and rotating needle
// visual polish comes in segment 4
class CompassWidget extends StatelessWidget {
  const CompassWidget({
    super.key,
    required this.needleRotation,
  });

  final double needleRotation;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(250, 250),
      painter: _CompassPainter(needleRotation),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double needleRotation;

  _CompassPainter(this.needleRotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey;
    canvas.drawCircle(center, radius - 8, ringPaint);

    // needle line that rotates to qibla
    final needleAngle = (needleRotation - 90) * math.pi / 180;
    final needlePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final needleEnd = Offset(
      center.dx + math.cos(needleAngle) * (radius - 20),
      center.dy + math.sin(needleAngle) * (radius - 20),
    );
    canvas.drawLine(center, needleEnd, needlePaint);

    // center dot
    canvas.drawCircle(center, 5, Paint()..color = Colors.green);
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.needleRotation != needleRotation;
}