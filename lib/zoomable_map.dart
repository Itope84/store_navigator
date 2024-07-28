import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:store_navigator/utils/api/route.dart';
import 'package:store_navigator/utils/floorplan_to_grid.dart';
import 'package:xml/xml.dart';

class ZoomableMapPainter extends CustomPainter {
  final PictureInfo picture;
  final double initialScale;
  final Offset offset;
  final List<Offset> items;
  final List<Offset> route;

  ZoomableMapPainter(
      this.picture, this.initialScale, this.offset, this.items, this.route);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    canvas.scale(initialScale);

    print(this.route);

    // Draw the SVG
    canvas.drawPicture(picture.picture);

    // Draw items
    Paint itemPaint = Paint()..color = Colors.red;
    for (var item in items) {
      canvas.drawCircle(item, 10.0 / initialScale, itemPaint);
    }

    // TODO: Draw route. A possibly complex algorithm to draw the route between items
    if (route.isNotEmpty) {
      Paint routePaint = Paint()
        ..color = Colors.red
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

class ZoomableMap extends StatefulWidget {
  final String assetName = 'assets/floor_plan.svg';

  ZoomableMap({Key? key}) : super(key: key);

  @override
  _ZoomableMapState createState() => _ZoomableMapState();
}

// define enum start | end
enum Position { start, end }

class _ZoomableMapState extends State<ZoomableMap> {
  PictureInfo? picture;

  late SvgToGridConverter converter;

  late Grid grid;

  double scale = 1.0;
  Offset offset = Offset.zero;
  List<Offset> items = [];
  List<Offset> route = [];

  // tuple (start, end) positions
  (Offset?, Offset?) positions = (null, null);

  // Position lastTapped = Position.start;

  @override
  void initState() {
    super.initState();
    _loadSvg();

    _getRoute();
  }

  final MAP_SCREEN_RATIO = 0.7;

  double _getWidgetHeight() {
    return MediaQuery.of(context).size.height * MAP_SCREEN_RATIO;
  }

  double _getInitialPictureScale() {
    if (picture == null) {
      return 1.0;
    }
    return _getWidgetHeight() / picture!.size.height;
  }

  Future<void> _loadSvg() async {
    final loader = DefaultAssetBundle.of(context);
    final svgString = await loader.loadString(widget.assetName);

    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    // final document = XmlDocument.parse(svgString);
    setState(() {
      picture = pictureInfo;
      // converter = SvgToGridConverter(document, (pictureInfo.size.width).ceil(),
      //     (pictureInfo.size.height).ceil());
      // grid = generateGrid(svgString);
    });

    // print(_getSectionAisleSideMidpoint('section_0'));
  }

  Rect _getSectionRect(String sectionId) {
    final section = converter.paths[sectionId];

    return section?.getBounds() ?? Rect.zero;
  }

  Rect _getSectionRectWithPadding(String sectionId) {
    final sectionRect = _getSectionRect(sectionId);

    return sectionRect;
    // return Rect.fromLTRB(sectionRect.left - 2, sectionRect.top - 2,
    // sectionRect.right + 2, sectionRect.bottom + 2);
  }

  Offset _getSectionCenter(String sectionId) {
    final sectionRect = _getSectionRect(sectionId);

    return Offset(sectionRect.left + sectionRect.width / 2,
        sectionRect.top + sectionRect.height / 2);
  }

  Offset _getSectionAisleSideMidpoint(String sectionId) {
    // The open midpoint of the open side of the section is the walkable point closest to the center of the section

    final sectionRect = _getSectionRectWithPadding(sectionId);

    final midpoint = Offset(sectionRect.left + sectionRect.width / 2,
        sectionRect.top + sectionRect.height / 2);

    // Check the four sides of the section, find the midpoint of each side (the side is the 5px padding around the section), if it is not walkable, skip it; otherwise, sort by distance to the midpoint and return the closest one
    final sideMidpoints = [
      Offset(sectionRect.left, sectionRect.top + sectionRect.height / 2),
      Offset(sectionRect.right, sectionRect.top + sectionRect.height / 2),
      Offset(sectionRect.left + sectionRect.width / 2, sectionRect.top),
      Offset(sectionRect.left + sectionRect.width / 2, sectionRect.bottom)
    ];

    // TODO: scale
    final walkableSideMidpoints = sideMidpoints
        .where((point) => grid.isWalkable(point.dx.ceil(), point.dy.ceil()))
        .toList();

    walkableSideMidpoints.sort((a, b) => (a - midpoint)
        .distanceSquared
        .compareTo((b - midpoint).distanceSquared));

    // TODO: remove
    setState(() {
      items.add(walkableSideMidpoints.first);
    });

    return walkableSideMidpoints.first;
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    // The localPosition is skewed because where we tapped on the canvas is being scaled down and thus items are appearing in the wrong place. So we need to correct for that
    Offset position = Offset(
        details.localPosition.dx * 1 / _getInitialPictureScale(),
        details.localPosition.dy * 1 / _getInitialPictureScale());

    print(position);

    var (start, end) = positions;

    if (start == null) {
      start = position;
    } else if (end == null) {
      end = position;
    } else {
      start = Offset(end.dx, end.dy);
      end = position;
    }

    setState(() {
      positions = (start, end);
      // add positions to items
      if (start != null) {
        items.clear();
        items.add(start);
      }
      if (end != null) {
        items.add(end);
      }
    });

    if (start != null && end != null) {
      final data = await fetchRouteByPos(start, end);

      setState(() {
        route.clear();
        route =
            data.map<Offset>((r) => Offset(r[1] / 1.0, r[0] / 1.0)).toList();

        print(data[0]);
      });
    }
  }

  Future<void> _getRoute() async {
    final data = await fetchRouteBySectionId('section_70', 'section_12');

    setState(() {
      route = data.map<Offset>((r) => Offset(r[1] / 1.0, r[0] / 1.0)).toList();
    });
  }

  EdgeInsets _getBoundaryMargin() {
    if (picture == null) {
      return EdgeInsets.zero;
    }

    double imageWidth = _getInitialPictureScale() * picture!.size.width;

    return EdgeInsets.only(
        right: imageWidth - MediaQuery.of(context).size.width);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Floor Plan'),
      ),
      body: Container(
        // height should be screen height * 0.7
        height: _getWidgetHeight(),
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          // constrained: false,
          boundaryMargin: _getBoundaryMargin(),

          child: GestureDetector(
            // TODO: this temporariluy shows adding items to the map by tapping. We want to actually generate the items on the map
            onTapUp: _onTapUp,
            child: CustomPaint(
              painter: picture == null
                  ? null
                  : ZoomableMapPainter(picture!, _getInitialPictureScale(),
                      offset, items, route),
              child: Container(),
            ),
          ),
        ),
      ),
    );
  }
}
