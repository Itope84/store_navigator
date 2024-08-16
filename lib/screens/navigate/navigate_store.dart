import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:store_navigator/screens/navigate/zoomable_map_painter.dart';
import 'package:store_navigator/utils/api/route.dart';
import 'package:store_navigator/utils/api/shopping_list.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/utils/floorplan_to_grid.dart';
import 'package:store_navigator/utils/icons.dart';
import 'package:store_navigator/utils/shelves.dart';

class NavigateStoreScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  final String assetName = 'assets/floor_plan.svg';

  const NavigateStoreScreen({super.key, required this.shoppingList});

  @override
  State<NavigateStoreScreen> createState() => _NavigateStoreScreenState();
}

class _NavigateStoreScreenState extends State<NavigateStoreScreen> {
  PictureInfo? picture;

  late SvgToGridConverter converter;

  final TransformationController _transformationController =
      TransformationController();

  late Grid grid;

  List<ShelfNode> shelfNodes = [];
  List<ShelfNode> shoppingListShelfNodes = [];

  double scale = 1.0;
  Offset offset = Offset.zero;
  List<Offset> items = [];
  List<Offset> route = [];

  (Offset?, Offset?) positions = (null, null);

  @override
  void initState() {
    super.initState();
    _loadSvg();

    _loadShelves();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  final MAP_SCREEN_RATIO = 1.0;

  void _loadShelves() async {
    // TODO: loading state

    // TODO: move this bit to a separate function
    final productIds =
        widget.shoppingList.items?.map((e) => e.productId).toList() ?? [];
    final productsWithShelf = await getShoppingListProductsWithShelves(
        widget.shoppingList.storeId, productIds);
    final productIdToShelf = productsWithShelf.fold<Map<String, String>>(
        {}, (map, p) => map..putIfAbsent(p.product.id!, () => p.sectionId));
    // go through shoppinglist items and update their sectionId with the sectionId of the product
    widget.shoppingList.items?.forEach((item) {
      item.sectionId = productIdToShelf[item.productId] ?? item.sectionId;
    });

    final _shelfNodes =
        await getShelfNodes(widget.shoppingList, widget.assetName);

    setState(() {
      shelfNodes = _shelfNodes;
      shoppingListShelfNodes =
          shelfNodes.where((s) => s.items.isNotEmpty).toList();

      // TODO: this also shouldn't be here but /it's an expt and I'm getting tired
      items =
          shoppingListShelfNodes.map((s) => s.path.getBounds().center).toList();
    });

    // TODO: handle more neatly maybe. Also loading state!
    _getTravelingRoutes();
  }

  double _getWidgetHeight() {
    return MediaQuery.of(context).size.height * MAP_SCREEN_RATIO;
  }

  double _getInitialPictureScale() {
    if (picture == null) {
      return 1.0;
    }
    const initialScale = 0.8;

    return _getWidgetHeight() * initialScale / picture!.size.height;
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

  // TODO: remove all these
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
    final Matrix4 inverseMatrix =
        Matrix4.inverted(_transformationController.value);
    final Offset untransformedOffset =
        MatrixUtils.transformPoint(inverseMatrix, details.localPosition);

    Offset position = Offset(
        untransformedOffset.dx * 1 / _getInitialPictureScale(),
        untransformedOffset.dy * 1 / _getInitialPictureScale());

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

    if (end != null) {
      final data = await fetchRouteByPos(start, end);
      // TODO: errors when you tap beyond boundaries of map and there's no route returned (empty list). Handle this gracefully, by not registering the tap

      setState(() {
        route.clear();
        route =
            data.map<Offset>((r) => Offset(r[1] / 1.0, r[0] / 1.0)).toList();

        print(data[0]);
      });
    }
  }

  Future<void> _getRoute() async {
    final data = await fetchRouteBySectionId('section_entrance', 'section_12');

    setState(() {
      route = data.map<Offset>((r) => Offset(r[1] / 1.0, r[0] / 1.0)).toList();
    });
  }

  Future<void> _getTravelingRoutes() async {
    final sectionIds =
        shoppingListShelfNodes.map((s) => s.shelf.mapNodeId).toList();

    final data = await fetchRoutesBySectionIds(sectionIds);

    setState(() {
      route = data
          .expand((i) => i)
          .map<Offset>((r) => Offset(r[1] / 1.0, r[0] / 1.0))
          .toList();
    });
  }

  EdgeInsets _getBoundaryMargin() {
    if (picture == null) {
      return EdgeInsets.zero;
    }

    double imageWidth = _getInitialPictureScale() * picture!.size.width;

    return EdgeInsets.only(
        left: 20, right: imageWidth - picture!.size.width, top: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFE8EBF4),
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: const Color(0xFFE8EBF4),
        ),
        body: Stack(
          children: [
            GestureDetector(
              // TODO: this temporarily shows adding items to the map by tapping. We want to actually generate the items on the map
              onTapUp: _onTapUp,
              child: SizedBox(
                // height should be screen height * 0.7
                height: _getWidgetHeight(),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 4.0,
                  boundaryMargin: _getBoundaryMargin(),
                  child: CustomPaint(
                    painter: picture == null
                        ? null
                        : ZoomableMapPainter(
                            picture!,
                            _getInitialPictureScale(),
                            offset,
                            items,
                            route,
                            shelfNodes),
                    child: Container(),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 2.0,
              // full width container
              margin: const EdgeInsets.all(16),
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CustomIcons.store(
                        size: 24, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      widget.shoppingList.store?.name ?? 'Store Map',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
