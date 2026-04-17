import 'package:flutter/material.dart';

class BottomCurvePainter extends CustomPainter {
  final Color color;
  BottomCurvePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start lower on left
    path.moveTo(0, 60);

    // Smooth left curve
    path.quadraticBezierTo(
        size.width * 0.25, 10,
        size.width * 0.40, 30);

    // Wide smooth center bump
    path.quadraticBezierTo(
        size.width * 0.50, 80,
        size.width * 0.60, 30);

    // Smooth right curve
    path.quadraticBezierTo(
        size.width * 0.75, 10,
        size.width, 60);

    // Close shape
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black26, 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}