import 'package:flutter/material.dart';

class GridOverlay extends StatelessWidget {
  final double gridSize;
  final Color? color;
  final double strokeWidth;

  const GridOverlay({
    super.key,
    required this.gridSize,
    this.color,
    this.strokeWidth = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        Theme.of(context).colorScheme.onSurface.withOpacity(0.1);

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: GridPainter(
            gridSize: gridSize,
            color: effectiveColor,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;
  final double strokeWidth;

  GridPainter({
    required this.gridSize,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
