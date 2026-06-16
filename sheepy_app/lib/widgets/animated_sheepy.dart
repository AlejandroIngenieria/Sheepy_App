import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedSheepy extends StatefulWidget {
  const AnimatedSheepy({
    super.key,
    required this.progress,
    required this.woolColor,
    this.size = 200,
    this.mood = SheepyMood.happy,
  });

  final double progress;
  final Color woolColor;
  final double size;
  final SheepyMood mood;

  @override
  State<AnimatedSheepy> createState() => _AnimatedSheepyState();
}

enum SheepyMood { happy, excited, sleepy, sad }

class _AnimatedSheepyState extends State<AnimatedSheepy> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _blinkController;
  late AnimationController _tailController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scheduleBlink();

    _tailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  void _scheduleBlink() {
    Future.delayed(Duration(milliseconds: 2500 + (math.Random().nextInt(3000))), () {
      if (!mounted) return;
      _blinkController.forward().then((_) {
        if (!mounted) return;
        _blinkController.reverse().then((_) => _scheduleBlink());
      });
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _blinkController.dispose();
    _tailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _blinkController, _tailController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _KawaiiSheepPainter(
            progress: widget.progress,
            woolColor: widget.woolColor,
            bounceValue: _bounceController.value,
            blinkValue: _blinkController.value,
            tailValue: _tailController.value,
            mood: widget.mood,
          ),
        );
      },
    );
  }
}

class _KawaiiSheepPainter extends CustomPainter {
  final double progress;
  final Color woolColor;
  final double bounceValue;
  final double blinkValue;
  final double tailValue;
  final SheepyMood mood;

  _KawaiiSheepPainter({
    required this.progress,
    required this.woolColor,
    required this.bounceValue,
    required this.blinkValue,
    required this.tailValue,
    required this.mood,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200.0;
    canvas.save();
    canvas.scale(scale, scale);

    final cx = 100.0;
    final cy = 95.0 + (bounceValue * 6 - 3);

    // ── Shadow ──
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 178), width: 100, height: 16),
      shadowPaint,
    );

    // ── Legs (short, stubby, adorable) ──
    final legPaint = Paint()..color = const Color(0xFFFAD0C0);
    final hoofPaint = Paint()..color = const Color(0xFFF5B8A0);

    void drawLeg(double x, double extraBounce) {
      final legY = cy + 28 + (extraBounce * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, legY, 14, 28),
          const Radius.circular(7),
        ),
        legPaint,
      );
      // Tiny hoof
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 1, legY + 22, 16, 10),
          const Radius.circular(5),
        ),
        hoofPaint,
      );
    }

    drawLeg(cx - 28, bounceValue * 0.5);
    drawLeg(cx - 12, -bounceValue * 0.3);
    drawLeg(cx + 8, bounceValue * 0.3);
    drawLeg(cx + 24, -bounceValue * 0.5);

    // ── Tail (pompom) ──
    final tailX = cx + 42 + (tailValue * 4 - 2);
    final tailY = cy + 8;
    _drawWoolCluster(canvas, tailX, tailY, 12, woolColor);

    // ── Body (big fluffy wool ball) ──
    final woolPaint = Paint()..color = woolColor;
    final woolHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.25);

    // Main body shape
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 100, height: 75),
      woolPaint,
    );

    // Fluffy wool clusters around the body
    final woolScale = 1.0 + (progress * 0.3);
    canvas.save();
    canvas.translate(cx, cy + 10);
    canvas.scale(woolScale, woolScale);
    canvas.translate(-cx, -(cy + 10));

    _drawWoolCluster(canvas, cx - 35, cy - 5, 22, woolColor);
    _drawWoolCluster(canvas, cx + 35, cy - 5, 22, woolColor);
    _drawWoolCluster(canvas, cx - 25, cy - 18, 20, woolColor);
    _drawWoolCluster(canvas, cx + 25, cy - 18, 20, woolColor);
    _drawWoolCluster(canvas, cx, cy - 25, 24, woolColor);
    _drawWoolCluster(canvas, cx - 40, cy + 12, 18, woolColor);
    _drawWoolCluster(canvas, cx + 40, cy + 12, 18, woolColor);
    _drawWoolCluster(canvas, cx, cy + 25, 20, woolColor);

    // Extra fluff based on progress
    if (progress > 0.2) _drawWoolCluster(canvas, cx - 45, cy + 5, 16, woolColor);
    if (progress > 0.4) _drawWoolCluster(canvas, cx + 45, cy + 5, 16, woolColor);
    if (progress > 0.6) _drawWoolCluster(canvas, cx, cy - 32, 18, woolColor);
    if (progress > 0.8) {
      _drawWoolCluster(canvas, cx - 30, cy - 25, 14, woolColor);
      _drawWoolCluster(canvas, cx + 30, cy - 25, 14, woolColor);
    }

    canvas.restore();

    // Body highlight
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 12, cy - 2), width: 30, height: 20),
      woolHighlight,
    );

    // ── Head ──
    final headCy = cy - 22;
    final facePaint = Paint()..color = const Color(0xFFFFF5EE); // Cream white face
    final faceOutline = Paint()
      ..color = const Color(0xFFE8D5C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Head shape (round, kawaii)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headCy), width: 56, height: 48),
      facePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headCy), width: 56, height: 48),
      faceOutline,
    );

    // ── Ears ──
    final earPaint = Paint()..color = const Color(0xFFFFF5EE);
    final innerEarPaint = Paint()..color = const Color(0xFFFFB6C1);

    // Left ear
    canvas.save();
    canvas.translate(cx - 26, headCy - 8);
    canvas.rotate(-0.5 - (bounceValue * 0.15));
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 20, height: 12), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 7), innerEarPaint);
    canvas.restore();

    // Right ear
    canvas.save();
    canvas.translate(cx + 26, headCy - 8);
    canvas.rotate(0.5 + (bounceValue * 0.15));
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 20, height: 12), earPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 12, height: 7), innerEarPaint);
    canvas.restore();

    // ── Wool tuft on head ──
    _drawWoolCluster(canvas, cx, headCy - 22, 14, woolColor);
    _drawWoolCluster(canvas, cx - 10, headCy - 18, 10, woolColor);
    _drawWoolCluster(canvas, cx + 10, headCy - 18, 10, woolColor);
    _drawWoolCluster(canvas, cx - 6, headCy - 22, 8, woolColor);
    _drawWoolCluster(canvas, cx + 6, headCy - 22, 8, woolColor);

    // ── Blush (cheeks) ──
    final blushPaint = Paint()
      ..color = const Color(0xFFFF9EAA).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(cx - 18, headCy + 6), 7, blushPaint);
    canvas.drawCircle(Offset(cx + 18, headCy + 6), 7, blushPaint);

    // ── Eyes (big, kawaii style) ──
    final isBlinking = blinkValue > 0.3;

    if (!isBlinking) {
      // Eye whites
      final eyeWhite = Paint()..color = Colors.white;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx - 11, headCy - 2), width: 16, height: 18),
        eyeWhite,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 11, headCy - 2), width: 16, height: 18),
        eyeWhite,
      );

      // Iris
      final irisPaint = Paint()..color = const Color(0xFF3D2B1F);
      canvas.drawCircle(Offset(cx - 11, headCy - 1), 6.5, irisPaint);
      canvas.drawCircle(Offset(cx + 11, headCy - 1), 6.5, irisPaint);

      // Pupil
      final pupilPaint = Paint()..color = const Color(0xFF1A0E08);
      canvas.drawCircle(Offset(cx - 11, headCy), 4, pupilPaint);
      canvas.drawCircle(Offset(cx + 11, headCy), 4, pupilPaint);

      // Eye sparkle (big)
      final sparklePaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(cx - 13, headCy - 3), 2.5, sparklePaint);
      canvas.drawCircle(Offset(cx + 9, headCy - 3), 2.5, sparklePaint);

      // Eye sparkle (small)
      canvas.drawCircle(Offset(cx - 9, headCy + 1), 1.2, sparklePaint);
      canvas.drawCircle(Offset(cx + 13, headCy + 1), 1.2, sparklePaint);
    } else {
      // Blinking - happy curved lines
      final closedPaint = Paint()
        ..color = const Color(0xFF3D2B1F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - 11, headCy - 1), width: 12, height: 8),
        0, math.pi, false, closedPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 11, headCy - 1), width: 12, height: 8),
        0, math.pi, false, closedPaint,
      );
    }

    // ── Nose ──
    final nosePaint = Paint()..color = const Color(0xFFD4A59A);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, headCy + 8), width: 8, height: 5),
      nosePaint,
    );

    // ── Mouth ──
    final mouthPaint = Paint()
      ..color = const Color(0xFFD4A59A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    if (mood == SheepyMood.happy || mood == SheepyMood.excited) {
      // Happy smile
      final smilePath = Path()
        ..moveTo(cx - 5, headCy + 11)
        ..quadraticBezierTo(cx, headCy + 15, cx + 5, headCy + 11);
      canvas.drawPath(smilePath, mouthPaint);
    } else {
      // Neutral line
      canvas.drawLine(
        Offset(cx - 4, headCy + 12),
        Offset(cx + 4, headCy + 12),
        mouthPaint,
      );
    }

    canvas.restore();
  }

  void _drawWoolCluster(Canvas canvas, double x, double y, double r, Color color) {
    final paint = Paint()..color = color;
    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.15);
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.04);

    canvas.drawCircle(Offset(x, y), r, paint);
    canvas.drawCircle(Offset(x - r * 0.2, y - r * 0.2), r * 0.5, highlight);
    canvas.drawCircle(Offset(x + r * 0.15, y + r * 0.25), r * 0.3, shadow);
  }

  @override
  bool shouldRepaint(covariant _KawaiiSheepPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.woolColor != woolColor ||
      oldDelegate.bounceValue != bounceValue ||
      oldDelegate.blinkValue != blinkValue ||
      oldDelegate.tailValue != tailValue ||
      oldDelegate.mood != mood;
}