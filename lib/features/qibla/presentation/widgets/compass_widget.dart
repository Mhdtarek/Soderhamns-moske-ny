import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soderhamns_moske_app/core/theme/app_colors.dart';

// fixed arrow at top rotating dial underneath kaaba marker on dial
// haptic buzz when kaaba aligns with arrow
// an animation controller interpolates between heading samples for
// buttery-smooth rotation regardless of stream emit rate.
class CompassWidget extends StatefulWidget {
  const CompassWidget({
    super.key,
    required this.heading,
    required this.bearing,
    this.size = 260,
  });

  final double heading;
  final double bearing;
  final double size;

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _displayedHeading = 0;
  double _startHeading = 0;
  double _endHeading = 0;
  bool _hapticArmed = true;

  static const _alignThreshold = 5.0;
  static const _resetThreshold = 15.0;
  static const _animDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _displayedHeading = widget.heading;
    _startHeading = widget.heading;
    _endHeading = widget.heading;
    _ctrl = AnimationController(vsync: this, duration: _animDuration)
      ..addListener(() {
        final t = _ctrl.value;
        final diff = ((_endHeading - _startHeading + 540) % 360) - 180;
        setState(() {
          _displayedHeading = (_startHeading + diff * t + 360) % 360;
        });
      });
  }

  @override
  void didUpdateWidget(CompassWidget old) {
    super.didUpdateWidget(old);
    if (widget.heading != old.heading) {
      _startHeading = _displayedHeading;
      _endHeading = widget.heading;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _maybeHaptic() {
    final angle = (widget.bearing - _displayedHeading + 360) % 360;
    final fromZero = angle > 180 ? 360 - angle : angle;

    if (fromZero < _alignThreshold && _hapticArmed) {
      _hapticArmed = false;
      HapticFeedback.mediumImpact();
    } else if (fromZero > _resetThreshold) {
      _hapticArmed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _maybeHaptic();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _CompassPainter(
        dialRotation: -_displayedHeading,
        bearing: widget.bearing,
        isDark: isDark,
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double dialRotation;
  final double bearing;
  final bool isDark;

  _CompassPainter({
    required this.dialRotation,
    required this.bearing,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final gold = isDark ? AppColors.goldLight : AppColors.gold;
    final bg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final green = isDark ? AppColors.accentGreenLight : AppColors.accentGreen;
    final muted = isDark
        ? AppColors.darkText.withValues(alpha: 0.4)
        : AppColors.lightTextMuted;
    final tickColor = isDark
        ? AppColors.darkText.withValues(alpha: 0.3)
        : AppColors.lightTextMuted;

    // bezel outer ring fixed
    final bezelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = gold.withValues(alpha: 0.25);
    canvas.drawCircle(center, radius - 4, bezelPaint);

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = gold.withValues(alpha: 0.7);
    canvas.drawCircle(center, radius - 14, rimPaint);

    // face background fixed
    canvas.drawCircle(center, radius - 14, Paint()..color = bg);

    // rotating dial
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(dialRotation * math.pi / 180);

    // tick marks every 15 degrees
    final tickCount = 24;
    for (var i = 0; i < tickCount; i++) {
      final angle = i * 15 * math.pi / 180;
      final isMajor = i % 6 == 0;
      final isMid = i % 3 == 0;
      final len = isMajor ? 14.0 : (isMid ? 10.0 : 6.0);
      final sw = isMajor ? 2.5 : (isMid ? 1.8 : 1.0);

      final outer = radius - 16;
      final inner = outer - len;

      canvas.drawLine(
        Offset(math.sin(angle) * inner, -math.cos(angle) * inner),
        Offset(math.sin(angle) * outer, -math.cos(angle) * outer),
        Paint()
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round
          ..color = tickColor,
      );
    }

    // cardinal labels on rotating dial
    final dirs = [('N', 0), ('O', 90), ('S', 180), ('V', 270)];
    for (final (label, deg) in dirs) {
      final angle = deg * math.pi / 180;
      final labelRadius = radius - 38;
      final pos = Offset(
        math.sin(angle) * labelRadius,
        -math.cos(angle) * labelRadius,
      );

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: label == 'N' ? gold : muted,
            fontFamily: 'AtkinsonHyperlegible',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2),
      );
    }

    // kaaba marker on the dial at bearing angle
    final kaabaAngle = bearing * math.pi / 180;
    final kaabaRadius = radius - 38;
    final kaabaPos = Offset(
      math.sin(kaabaAngle) * kaabaRadius,
      -math.cos(kaabaAngle) * kaabaRadius,
    );

    // gold circle behind kaaba emoji
    canvas.drawCircle(
      kaabaPos,
      16,
      Paint()..color = gold.withValues(alpha: 0.2),
    );
    canvas.drawCircle(
      kaabaPos,
      16,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = gold,
    );

    // emoji is rotated so its top points radially outward (toward
    // the Kaaba direction), not locked to the dial's "north".
    final kaabaTp = TextPainter(
      text: TextSpan(
        text: '🕋',
        style: const TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(kaabaPos.dx, kaabaPos.dy);
    canvas.rotate(kaabaAngle);
    kaabaTp.paint(
      canvas,
      Offset(-kaabaTp.width / 2, -kaabaTp.height / 2),
    );
    canvas.restore();

    canvas.restore();

    // fixed arrow at top pointing up always
    final arrowLen = radius - 34;
    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - arrowLen)
      ..lineTo(center.dx + 9, center.dy - arrowLen + 20)
      ..lineTo(center.dx + 4, center.dy - arrowLen + 16)
      ..lineTo(center.dx + 4, center.dy - 20)
      ..lineTo(center.dx - 4, center.dy - 20)
      ..lineTo(center.dx - 4, center.dy - arrowLen + 16)
      ..lineTo(center.dx - 9, center.dy - arrowLen + 20)
      ..close();

    canvas.drawShadow(arrowPath, green.withValues(alpha: 0.3), 4, true);
    canvas.drawPath(arrowPath, Paint()..color = green);

    // center hub
    canvas.drawCircle(center, 8, Paint()..color = green);
    canvas.drawCircle(center, 5, Paint()..color = bg);
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.dialRotation != dialRotation ||
      old.bearing != bearing ||
      old.isDark != isDark;
}