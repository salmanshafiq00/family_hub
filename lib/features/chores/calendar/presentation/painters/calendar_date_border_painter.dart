import 'package:flutter/material.dart';

enum CalendarDateBorderState { none, overdue, completed }

class CalendarDateBorderPainter extends CustomPainter {
  const CalendarDateBorderPainter({
    required this.state,
    required this.stateColor,
    required this.isToday,
    required this.todayColor,
    required this.isSelected,
    required this.selectedColor,
    required this.radius,
  });

  final CalendarDateBorderState state;
  final Color stateColor;
  final bool isToday;
  final Color todayColor;
  final bool isSelected;
  final Color selectedColor;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final outer = bounds.deflate(1);
    if (state == CalendarDateBorderState.overdue) {
      _drawDashed(canvas, outer, stateColor);
    } else if (state == CalendarDateBorderState.completed) {
      _drawOutline(canvas, outer.deflate(1), stateColor);
      _drawOutline(canvas, outer.deflate(4), stateColor);
    }

    final statusInset = state == CalendarDateBorderState.none ? 1.0 : 7.0;
    if (isToday) {
      _drawOutline(canvas, outer.deflate(statusInset), todayColor, width: 2);
    }
    if (isSelected) {
      _drawOutline(
        canvas,
        outer.deflate(isToday ? 10 : statusInset),
        selectedColor,
        width: 2,
      );
    }
  }

  void _drawDashed(Canvas canvas, Rect rect, Color color) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect,
          Radius.circular((radius - 1).clamp(0, radius).toDouble()),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 5).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 3;
      }
    }
  }

  void _drawOutline(
    Canvas canvas,
    Rect rect,
    Color color, {
    double width = 1.5,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(radius.clamp(0, rect.shortestSide / 2).toDouble()),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CalendarDateBorderPainter oldDelegate) =>
      oldDelegate.state != state ||
      oldDelegate.stateColor != stateColor ||
      oldDelegate.isToday != isToday ||
      oldDelegate.todayColor != todayColor ||
      oldDelegate.isSelected != isSelected ||
      oldDelegate.selectedColor != selectedColor ||
      oldDelegate.radius != radius;
}
