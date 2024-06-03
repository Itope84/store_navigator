import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

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
        ..color = Colors.blue
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
  final String assetName;

  ZoomableMap({Key? key, required this.assetName}) : super(key: key);

  @override
  _ZoomableMapState createState() => _ZoomableMapState();
}

class _ZoomableMapState extends State<ZoomableMap> {
  PictureInfo? picture;
  double scale = 1.0;
  Offset offset = Offset.zero;
  List<Offset> items = [];
  List<Offset> route = [];

  @override
  void initState() {
    super.initState();
    _loadSvg();
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
    setState(() {
      picture = pictureInfo;
    });
  }

  void _onTapUp(TapUpDetails details) {
    // The localPosition is skewed because where we tapped on the canvas is being scaled down and thus items are appearing in the wrong place. So we need to correct for that
    Offset position = Offset(
        details.localPosition.dx * 1 / _getInitialPictureScale(),
        details.localPosition.dy * 1 / _getInitialPictureScale());

    setState(() {
      items.add(position);
    });
  }

  void _onLongPress() {
    setState(() {
      if (items.isNotEmpty) {
        route = List.from(items); // Use items to create a sample route
      }
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
        title: Text('Zoomable Map'),
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
            onLongPress: _onLongPress,
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
