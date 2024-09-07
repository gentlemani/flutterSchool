import 'package:flutter/material.dart';

class SeasonalBackground extends StatelessWidget {
  final DateTime currentDate;

  SeasonalBackground({super.key, DateTime? date})
      : currentDate = date ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    String season = _getSeason(currentDate);

    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _SeasonalPainter(season: season),
    );
  }

  String _getSeason(DateTime date) {
    int month = date.month;
    if (month == 12 || month <= 2) {
      return 'winter';
    } else if (month >= 3 && month <= 5) {
      return 'spring';
    } else if (month >= 6 && month <= 8) {
      return 'summer';
    } else {
      return 'autumn';
    }
  }
}

class _SeasonalPainter extends CustomPainter {
  final String season;

  _SeasonalPainter({required this.season});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    switch (season) {
      case 'winter':
        _drawWinterBackground(canvas, size, paint);
        break;
      case 'spring':
        _drawSpringBackground(canvas, size, paint);
        break;
      case 'summer':
        _drawSummerBackground(canvas, size, paint);
        break;
      case 'autumn':
        _drawAutumnBackground(canvas, size, paint);
        break;
    }
  }

  void _drawWinterBackground(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.blueAccent.shade100;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 150, paint);
    paint.color = Colors.lightBlueAccent.shade200;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 120, paint);
  }

  void _drawSpringBackground(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.green.shade300;
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.4), 140, paint);
    paint.color = Colors.lightGreenAccent.shade100;
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.6), 110, paint);
  }

  void _drawSummerBackground(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.yellowAccent.shade100;
    canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.35), 160, paint);
    paint.color = Colors.orangeAccent.shade100;
    canvas.drawCircle(
        Offset(size.width * 0.75, size.height * 0.65), 130, paint);
  }

  void _drawAutumnBackground(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.orange.shade300;
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.2), 150, paint);
    paint.color = Colors.deepOrangeAccent.shade100;
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.8), 120, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
