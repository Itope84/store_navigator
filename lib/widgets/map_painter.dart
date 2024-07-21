import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class MapPainter extends CustomPainter {
  final PictureInfo picture;
  final double initialScale;
  final List<Offset>? items;
  final List<Offset>? route;

  MapPainter(
      {required this.picture,
      required this.initialScale,
      this.items,
      this.route});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.scale(initialScale);

    // Draw the SVG
    canvas.drawPicture(picture.picture);

    // Draw items
    Paint itemPaint = Paint()..color = Colors.red;
    for (var item in items ?? []) {
      canvas.drawCircle(item, 10.0 / initialScale, itemPaint);
    }

    if (route != null && route!.isNotEmpty) {
      Paint routePaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 3.0 / initialScale
        ..style = PaintingStyle.stroke;

      Path path = Path()..moveTo(route![0].dx, route![0].dy);
      for (var point in route!.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, routePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
