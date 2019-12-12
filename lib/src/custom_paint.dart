import 'package:flutter/material.dart';

class ShapePainter extends CustomPainter {
  Rect rect;
  final ShapeBorder shapeBorder;
  final Color color;
  final EdgeInsets overlayPadding;

  ShapePainter({
    @required this.rect,
    this.color,
    this.shapeBorder,
    this.overlayPadding = EdgeInsets.zero
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    RRect outer =
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(0));

    double radius = (shapeBorder is CircleBorder) ? 50 : 3;

    RRect inner = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        rect.left - overlayPadding.left,
        rect.top - overlayPadding.top, 
        rect.right + overlayPadding.right,
        rect.bottom + overlayPadding.bottom 
      ),
      Radius.circular(radius)
    );
    canvas.drawDRRect(outer, inner, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
