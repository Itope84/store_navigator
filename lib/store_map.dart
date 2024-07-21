import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:store_navigator/utils/api/route.dart';
import 'package:store_navigator/utils/floorplan_to_grid.dart';
import 'package:store_navigator/widgets/map_painter.dart';
import 'package:xml/xml.dart';

class StoreMap extends StatefulWidget {
  const StoreMap({super.key});

  @override
  State<StoreMap> createState() => _StoreMapState();
}

class _StoreMapState extends State<StoreMap> {
  final String assetName = 'assets/floor_plan.svg';
  final MAP_SCREEN_RATIO = 0.7;

  // State variables
  PictureInfo? picture;
  bool isGeneratingRoute = false;
  Grid? grid;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await loadSvg();

    await fetchGrid();
  }

  Future<void> loadSvg() async {
    final data = await DefaultAssetBundle.of(context).loadString(assetName);

    final pictureInfo = await vg.loadPicture(SvgStringLoader(data), null);

    setState(() {
      picture = pictureInfo;
    });
  }

  // TODO: these can all be moved out and simply take picture as a param
  double _getWidgetHeight() {
    return MediaQuery.of(context).size.height * MAP_SCREEN_RATIO;
  }

  double _getInitialScale() {
    return (picture == null) ? 1.0 : _getWidgetHeight() / picture!.size.height;
  }

  EdgeInsets _getBoundaryMargin() {
    if (picture == null) {
      return EdgeInsets.zero;
    }

    double imageWidth = _getInitialScale() * picture!.size.width;

    return EdgeInsets.only(
        right: imageWidth - MediaQuery.of(context).size.width);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Map')),
      body: Stack(
        children: [
          Container(
              child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            boundaryMargin: _getBoundaryMargin(),
            child: CustomPaint(
              painter: picture == null
                  ? null
                  : MapPainter(
                      picture: picture!, initialScale: _getInitialScale()),
              child: Container(),
            ),
          )),
          if (isGeneratingRoute)
            Positioned(child: CircularProgressIndicator(), top: 16, right: 16)
        ],
      ),
    );
  }
}
