import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:store_navigator/utils/data/shelf.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';
import 'package:xml/xml.dart';

Map<String, Shelf> mapIdToShelf(List<Shelf> shelves) {
  return {for (var shelf in shelves) shelf.mapNodeId: shelf};
}

class ShelfNode {
  final String id;
  final Path path;
  final Shelf shelf;
  final List<ShoppingListItem> items;

  final List<GlobalKey> _itemKeys = [];
  final GlobalKey locateButtonKey = GlobalKey();

  List<GlobalKey> get itemKeys => _itemKeys;

  GlobalKey getItemKey(ShoppingListItem item) {
    return _itemKeys[items.indexOf(item)];
  }

  void setItemKeys() {
    _itemKeys.clear();
    for (var i = 0; i < items.length; i++) {
      _itemKeys.add(GlobalKey());
    }
  }

  Offset? _routeEnd;

  set routeEnd(Offset offset) {
    _routeEnd = offset;
  }

  Offset get routeEnd =>
      _routeEnd != null ? _routeEnd! : path.getBounds().center;

  bool get allItemsFound => items.every((item) => item.found);

  ShelfNode(this.id, this.path, this.shelf, {this.items = const []});

  // override tostring to print the id and path offset
  @override
  String toString() {
    return 'ShelfNode{id: $id, Name: ${shelf.name} items: ${items.length}}';
  }
}

Future<List<ShelfNode>> getShelfNodes(
    ShoppingList shoppingList, String floorPlan) async {
  final svgString = await rootBundle.loadString(floorPlan);
  final document = XmlDocument.parse(svgString);

  final shelves = shoppingList.store?.shelves ?? [];

  final shelfItems = (shoppingList.items ?? [])
      .fold<Map<String, List<ShoppingListItem>>>({},
          (map, item) => map..putIfAbsent(item.sectionId!, () => []).add(item));

  final shelfMap = mapIdToShelf(shelves);

  print(shelves);

  final nodes = document
      .findAllElements('path')
      .where((element) =>
          element.getAttribute('id') != null &&
          element.getAttribute('d') != null &&
          shelfMap.containsKey(element.getAttribute('id')))
      .map(
        (element) => ShelfNode(
            element.getAttribute('id')!,
            parseSvgPathData(element.getAttribute('d')!),
            shelfMap[element.getAttribute('id')]!,
            items: shelfItems[element.getAttribute('id')] ?? []),
      )
      .toList();

  return nodes;
}
