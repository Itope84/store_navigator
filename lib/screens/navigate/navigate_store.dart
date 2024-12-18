import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:store_navigator/screens/navigate/widgets/basket_icon.dart';
import 'package:store_navigator/screens/navigate/widgets/map_bottom_nav.dart';
import 'package:store_navigator/screens/navigate/widgets/map_gesture_handler.dart';
import 'package:store_navigator/screens/navigate/zoomable_map_painter.dart';
import 'package:store_navigator/utils/api/route.dart';
import 'package:store_navigator/utils/api/shopping_list.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:store_navigator/utils/floorplan_to_grid.dart';
import 'package:store_navigator/utils/icons.dart';
import 'package:store_navigator/utils/shelves.dart';

List<GlobalKey> getAllShelfNodeClickables(List<ShelfNode> shelfNodes) {
  return shelfNodes
      .expand((node) => [...node.itemKeys, node.locateButtonKey])
      .toList();
}

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

  Offset? customStartLocation;
  List<Offset> items = [];
  List<Offset> route = [];
  bool isLocating = false;
  ShelfNode? selectedShelfNode;

  List<GlobalKey> buttonKeys = [];

  final GlobalKey recalculateButtonKey = GlobalKey();

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

      for (var node in shoppingListShelfNodes) {
        node.setItemKeys();
      }

      buttonKeys = shoppingListShelfNodes.map((_) => GlobalKey()).toList();
    });

    // TODO: handle more neatly maybe. Also loading state!
    _getTravelingRoutes(null);
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

    setState(() {
      picture = pictureInfo;
    });
  }

  Future<void> _onTapUp(Offset position) async {
    if (!isLocating) return;

    setState(() {
      customStartLocation = position;
    });
  }

  Future<void> _getTravelingRoutes(Offset? startLocation) async {
    // Only fetch the route through shelves for which all items haven't been found
    final sectionIds = shoppingListShelfNodes
        .where((s) => s.allItemsFound == false)
        .map((s) => s.shelf.mapNodeId)
        .toList();

    final data = await fetchRoutesBySectionIds(sectionIds, startLocation);

    final idToRoute = data.fold<Map<String, List<dynamic>>>(
        {}, (map, r) => map..putIfAbsent(r.pathId, () => r.route));

    // TODO: filter out nulls in case some sections still don't get route generated
    for (var node in shoppingListShelfNodes) {
      node.routeEnd = idToRoute.containsKey(node.shelf.mapNodeId)
          ? Offset(idToRoute[node.shelf.mapNodeId]?.last[1] / 1.0,
              idToRoute[node.shelf.mapNodeId]?.last[0] / 1.0)
          : node.path.getBounds().center;
    }

    final expandedRoute = data.expand((r) => r.route).toList();

    setState(() {
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
                  SizedBox(
                    // height should be screen height * 0.7
                    height: _getWidgetHeight(),
                    child: MapGestureHandler(
                      keys: [
                        ...buttonKeys,
                        ...getAllShelfNodeClickables(shelfNodes),
                        recalculateButtonKey
                      ],
                      onTapUp: (position) => _onTapUp(position),
                      initialScale: _getInitialPictureScale(),
                      boundaryMargin: _getBoundaryMargin(),
                      child: CustomPaint(
                        painter: ZoomableMapPainter(
                            picture!, initialScale, route, shelfNodes),
                        child: OverflowBox(
                          alignment: Alignment.topLeft,
                          maxWidth: picture!.size.width * initialScale,
                          child: Stack(
                            children: [
                              if (customStartLocation != null)
                                Positioned(
                                  // We have to offset the location by widget width / 2 to allow the item to be centrally positioned
                                  top: customStartLocation!.dy * initialScale -
                                      12,
                                  left: customStartLocation!.dx * initialScale -
                                      (isLocating ? 90 / 2 : 15),
                                  child: Column(
                                    children: [
                                      CustomIcons.locationPin(
                                          color:
                                              Theme.of(context).primaryColor),
                                      if (isLocating)
                                        FilledButton(
                                            key: recalculateButtonKey,
                                            style: const ButtonStyle(
                                              fixedSize: WidgetStatePropertyAll(
                                                  Size.fromWidth(90)),
                                              padding: WidgetStatePropertyAll(
                                                EdgeInsets.symmetric(
                                                    horizontal: 4),
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              textStyle: WidgetStatePropertyAll(
                                                  TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14)),
                                            ),
                                            onPressed: () {
                                              isLocating = false;
                                              _getTravelingRoutes(
                                                  customStartLocation);
                                            },
                                            child: const Text('Recalculate'))
                                    ],
                                  ),
                                ),
                              ...shoppingListShelfNodes.mapIndexed(
                                (index, node) => BasketIcon(
                                  buttonKey: buttonKeys[index],
                                  shelfNode: node,
                                  initialScale: initialScale,
                                  showDetails: selectedShelfNode == node,
                                  onItemFound: (item) {
                                    setState(() {
                                      item.found = !item.found;
                                      widget.shoppingList.saveToDb();
                                    });
                                  },
                                  onTap: () {
                                    setState(() {
                                      selectedShelfNode =
                                          selectedShelfNode == node
                                              ? null
                                              : node;
                                    });
                                  },
                                  onLocateHere: (location) {
                                    _getTravelingRoutes(location);
                                  },
                                ),
                              ),
                            ],
                          ),
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
                  ),
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    bottom: 16,
                    child: MapBottomNav(
                      isLocating: isLocating,
                      shoppingList: widget.shoppingList,
                      onLocateClick: () {
                        setState(() {
                          isLocating = !isLocating;
                        });
                      },
                    ),
                  )
                ],
              ));
  }
}
