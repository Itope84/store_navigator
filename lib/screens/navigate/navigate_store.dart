import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:store_navigator/screens/navigate/widgets/basket_icon.dart';
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

    final shelfNodes_ =
        await getShelfNodes(widget.shoppingList, widget.assetName);

    setState(() {
      shelfNodes = shelfNodes_;
      shoppingListShelfNodes =
          shelfNodes.where((s) => s.items.isNotEmpty).toList();
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

  Future<void> _onTapUp(TapUpDetails details) async {
    final Matrix4 inverseMatrix =
        Matrix4.inverted(_transformationController.value);
    final Offset untransformedOffset =
        MatrixUtils.transformPoint(inverseMatrix, details.localPosition);

    Offset position = Offset(
        untransformedOffset.dx * 1 / _getInitialPictureScale(),
        untransformedOffset.dy * 1 / _getInitialPictureScale());

    setState(() {
      items.add(position);
    });

    // var (start, end) = positions;

    // if (start == null) {
    //   start = position;
    // } else if (end == null) {
    //   end = position;
    // } else {
    //   start = Offset(end.dx, end.dy);
    //   end = position;
    // }

    // setState(() {
    //   positions = (start, end);
    //   // add positions to items
    //   if (start != null) {
    //     items.clear();
    //     items.add(start);
    //   }
    //   if (end != null) {
    //     items.add(end);
    //   }
    // });

    // if (end != null) {
    //   final data = await fetchRouteByPos(start, end);
    //   // TODO: errors when you tap beyond boundaries of map and there's no route returned (empty list). Handle this gracefully, by not registering the tap

    //   setState(() {
    //     route.clear();
    //     route =
    //         data.map<Offset>((r) => Offset(r[1] / 1.0, r[0] / 1.0)).toList();

    //     print(data[0]);
    //   });
    // }
  }

  // Future<void> _getRoute() async {
  //   final data = await fetchRouteBySectionId('section_entrance', 'section_12');

  //   setState(() {
  //     route = data.map<Offset>((r) => Offset(r[1] / 1.0, r[0] / 1.0)).toList();
  //   });
  // }

  Future<void> _getTravelingRoutes() async {
    final sectionIds =
        shoppingListShelfNodes.map((s) => s.shelf.mapNodeId).toList();

    final data = await fetchRoutesBySectionIds(sectionIds);

    final idToRoute = data.fold<Map<String, List<dynamic>>>(
        {}, (map, r) => map..putIfAbsent(r.pathId, () => r.route));

    // TODO: filter out nulls in case some sections still don't get route generated
    for (var node in shoppingListShelfNodes) {
      node.routeEnd = idToRoute.containsKey(node.shelf.mapNodeId)
          ? Offset(idToRoute[node.shelf.mapNodeId]?.last[1] / 1.0,
              idToRoute[node.shelf.mapNodeId]?.last[0] / 1.0)
          : node.path.getBounds().center;
    }

    // final sectionBasketLocations = shoppingListShelfNodes
    //     .map((s) => (idToRoute[s.shelf.mapNodeId] ?? []).lastOrNull)
    //     .toList();

    final expandedRoute = data.expand((r) => r.route).toList();

    // TODO: This contains multiple routes. The ending point each route is the aisle side midpoint of the section. We can use these to determine where to place the basket icon on the map (instead of what we currently do which is just placing it in the center of the section)

    setState(() {
      // items = sectionBasketLocations
      //     .map((r) => Offset(r[1] / 1.0, r[0] / 1.0))
      //     .toList();

      route = expandedRoute
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
    final initialScale = _getInitialPictureScale();

    return Scaffold(
        backgroundColor: const Color(0xFFE8EBF4),
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: const Color(0xFFE8EBF4),
        ),
        body: picture == null
            ? Container()
            : Stack(
                children: [
                  GestureDetector(
                    // TODO: this temporarily shows adding items to the map by tapping. We want to actually generate the items on the map. To do this, we need to have an icon toolbar from which the user can select a starting location and tap on the screen and we recompute the route
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
                              painter: ZoomableMapPainter(
                                  picture!,
                                  initialScale,
                                  offset,
                                  // items,
                                  route,
                                  shelfNodes),
                              child: OverflowBox(
                                alignment: Alignment.topLeft,
                                maxWidth: picture!.size.width * initialScale,
                                child: Stack(
                                  children: [
                                    ...shoppingListShelfNodes
                                        .map((node) => Positioned(
                                              // The -12 is a hack, for some reason, the item gets position slightly off, this is to place them directly within the route
                                              left: (node.routeEnd.dx *
                                                      initialScale) -
                                                  12,
                                              top: (node.routeEnd.dy *
                                                      initialScale) -
                                                  12,
                                              child: BasketIcon(
                                                itemCount: node.items.length,
                                              ),
                                            )),
                                  ],
                                ),
                              ))),
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
