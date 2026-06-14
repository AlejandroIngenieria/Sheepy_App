import 'package:flutter/material.dart';

class AnimatedSheepy extends StatefulWidget {
  const AnimatedSheepy({
    super.key,
    required this.progress,
    required this.woolColor,
    this.size = 200,
  });

  final double progress;
  final Color woolColor;
  final double size;

  @override
  State<AnimatedSheepy> createState() => _AnimatedSheepyState();
}

class _AnimatedSheepyState extends State<AnimatedSheepy> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: SheepPainter(
            progress: widget.progress,
            woolColor: widget.woolColor,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}

class SheepPainter extends CustomPainter {
  final double progress;
  final Color woolColor;
  final double animationValue;

  SheepPainter({
    required this.progress,
    required this.woolColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 180.0;
    canvas.save();
    canvas.scale(scale, scale);

    final cx = 90.0;
    final cy = 90.0 + (animationValue * 8 - 4); 

    // Sombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(Rect.fromCenter(center: const Offset(90, 165), width: 90, height: 15), shadowPaint);

    // Patas
    final legPaint = Paint()..color = const Color(0xFF2D3748)..style = PaintingStyle.fill;
    final hoofPaint = Paint()..color = const Color(0xFF1A202C)..style = PaintingStyle.fill;
    
    void drawLeg(double x) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, cy + 20, 10, 40), const Radius.circular(5)), legPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x - 2, cy + 55, 14, 8), const Radius.circular(4)), hoofPaint);
    }
    drawLeg(cx - 15);
    drawLeg(cx + 5);

    // --- LANA DUAL (Base + Crecimiento por progreso) ---
    final isDarkWool = woolColor.computeLuminance() < 0.5;
    final outlineColor = isDarkWool ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08);
    final woolPaint = Paint()..color = woolColor;
    final woolOutline = Paint()..color = outlineColor..style = PaintingStyle.stroke..strokeWidth = 3;

    void drawCloud(double x, double y, double r) {
      canvas.drawCircle(Offset(x, y), r, woolPaint);
      canvas.drawCircle(Offset(x, y), r, woolOutline);
    }

    // 1. Lana base (oveja rapada/inicial)
    drawCloud(cx, cy, 35); 
    drawCloud(cx - 20, cy + 10, 20);
    drawCloud(cx + 20, cy + 10, 20);

    // 2. Capas extra de lana que aparecen según el progreso
    canvas.save();
    double woolScale = 1.0 + (progress * 0.5); // Se infla ligeramente
    canvas.translate(cx, cy);
    canvas.scale(woolScale, woolScale);
    canvas.translate(-cx, -cy);

    if (progress > 0.1) drawCloud(cx - 25, cy - 15, 25);
    if (progress > 0.3) drawCloud(cx + 25, cy - 15, 25);
    if (progress > 0.5) drawCloud(cx, cy - 30, 30);
    if (progress > 0.7) drawCloud(cx - 35, cy + 10, 22);
    if (progress > 0.9) drawCloud(cx + 35, cy + 10, 22);

    canvas.restore();

    // --- CARA ---
    final facePaint = Paint()..color = const Color(0xFF2D3748);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 5), width: 40, height: 32), facePaint);
    
    // Orejas
    canvas.save();
    canvas.translate(cx - 20, cy - 8);
    canvas.rotate(-0.3 - (animationValue * 0.3));
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 14, height: 8), facePaint);
    canvas.restore();

    canvas.save();
    canvas.translate(cx + 20, cy - 8);
    canvas.rotate(0.3 + (animationValue * 0.3));
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 14, height: 8), facePaint);
    canvas.restore();

    // Copete
    drawCloud(cx, cy - 22, 10);
    drawCloud(cx - 8, cy - 20, 8);
    drawCloud(cx + 8, cy - 20, 8);

    // Rostro (Ojos y sonrojo)
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final blushPaint = Paint()..color = Colors.pinkAccent.withValues(alpha: 0.5);

    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 10, cy + 2), width: 6, height: 3), blushPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 10, cy + 2), width: 6, height: 3), blushPaint);

    if (animationValue < 0.90) {
      canvas.drawCircle(Offset(cx - 8, cy - 5), 4, eyePaint);
      canvas.drawCircle(Offset(cx + 8, cy - 5), 4, eyePaint);
      canvas.drawCircle(Offset(cx - 8, cy - 5), 2, pupilPaint);
      canvas.drawCircle(Offset(cx + 8, cy - 5), 2, pupilPaint);
      canvas.drawCircle(Offset(cx - 9, cy - 6), 1, eyePaint); 
      canvas.drawCircle(Offset(cx + 7, cy - 6), 1, eyePaint);
    } else {
      final closedEyePaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2..strokeCap = StrokeCap.round;
      canvas.drawPath(Path()..moveTo(cx - 11, cy - 4)..quadraticBezierTo(cx - 8, cy - 7, cx - 5, cy - 4), closedEyePaint);
      canvas.drawPath(Path()..moveTo(cx + 5, cy - 4)..quadraticBezierTo(cx + 8, cy - 7, cx + 11, cy - 4), closedEyePaint);
    }

    // Boca
    final mouthPaint = Paint()..color = Colors.white.withValues(alpha: 0.7)..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 1), Offset(cx, cy + 1), mouthPaint);
    canvas.drawPath(Path()..moveTo(cx - 3, cy + 1)..quadraticBezierTo(cx - 1.5, cy + 3, cx, cy + 1)..quadraticBezierTo(cx + 1.5, cy + 3, cx + 3, cy + 1), mouthPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SheepPainter oldDelegate) => 
      oldDelegate.progress != progress || 
      oldDelegate.woolColor != woolColor || 
      oldDelegate.animationValue != animationValue;
}