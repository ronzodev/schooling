import 'package:flutter/material.dart';

class LinedPaperPainter extends CustomPainter {
  final double lineHeight;
  final Color lineColor;
  final Color midlineColor;
  final Color redLineColor;

  LinedPaperPainter({
    this.lineHeight = 30.0,
    this.lineColor = const Color(0xFF2196F3), // Blue
    this.midlineColor = const Color(0xFF90CAF9), // Light Blue / Dashed
    this.redLineColor = const Color(0xFFEF5350), // Red
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Background color (off-white paper)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFFFFDE7), // Light cream
    );

    double y = lineHeight;

    while (y < size.height) {
      // Top Blue Line
      paint.color = lineColor;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

      // Middle Dashed Line
      if (y + lineHeight / 2 < size.height) {
        paint.color = midlineColor;
        _drawDashedLine(
            canvas, Offset(0, y + lineHeight / 2), size.width, paint);
      }

      // Bottom Red Line (Baseline)
      if (y + lineHeight < size.height) {
        paint.color = redLineColor;
        canvas.drawLine(Offset(0, y + lineHeight),
            Offset(size.width, y + lineHeight), paint);
      }

      y += lineHeight * 2; // Move to next set
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, double width, Paint paint) {
    double dashWidth = 5;
    double dashSpace = 5;
    double currentX = 0;

    while (currentX < width) {
      canvas.drawLine(
        Offset(start.dx + currentX, start.dy),
        Offset(start.dx + currentX + dashWidth, start.dy),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
