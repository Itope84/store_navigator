import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:store_navigator/utils/shelves.dart';

class ZoomableMapPainter extends CustomPainter {
  final PictureInfo picture;
  final double initialScale;
  final Offset offset;
  final List<Offset> items;
  final List<Offset> route;
  final List<ShelfNode> shelfNodes;

  ZoomableMapPainter(this.picture, this.initialScale, this.offset, this.items,
      this.route, this.shelfNodes);

  void drawShelfName(Canvas canvas, ShelfNode shelfNode) {
    // get orientation of the shelf, if width > height, then it is horizontal
    // else it is vertical
    final isHorizontal =
        shelfNode.path.getBounds().width > shelfNode.path.getBounds().height;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 6.0 / initialScale,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
    );
    final textSpan = TextSpan(
      text: shelfNode.shelf.name,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      // TODO: see if we can set max height based on shelfNode height vs text height
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: isHorizontal
          ? shelfNode.path.getBounds().width
          : shelfNode.path.getBounds().height,
    );

    final xc = shelfNode.path.getBounds().center.dx;
    final yc = shelfNode.path.getBounds().center.dy;

    final offset =
        Offset(xc - textPainter.width / 2, yc - textPainter.height / 2);

    canvas.save();

    if (!isHorizontal) {
      final pivot = textPainter.size.center(offset);
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(1.57);
      canvas.translate(-pivot.dx, -pivot.dy);
    }

    textPainter.paint(canvas, offset);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.scale(initialScale);

    // Draw the SVG
    canvas.drawPicture(picture.picture);

    // Draw items
    Paint itemPaint = Paint()..color = Colors.deepOrange;
    for (var item in items) {
      canvas.drawCircle(item, 10.0 / initialScale, itemPaint);
    }

    for (var shelfNode in shelfNodes) {
      drawShelfName(canvas, shelfNode);
    }

    // TODO: Draw route. A possibly complex algorithm to draw the route between items
    if (route.isNotEmpty) {
      Paint routePaint = Paint()
        ..color = Colors.lightBlue
        ..strokeWidth = 5.0 / initialScale
        ..style = PaintingStyle.stroke;

      Path path = Path()..moveTo(route[0].dx, route[0].dy);
      for (var point in route.skip(1)) {
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
