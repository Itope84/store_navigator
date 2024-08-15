import 'dart:math';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:store_navigator/utils/data/shelf.dart';
import 'package:xml/xml.dart';

Map<String, Shelf> mapIdToShelf(List<Shelf> shelves) {
  return {for (var shelf in shelves) shelf.mapNodeId: shelf};
}

class ShelfNode {
  final String id;
  final Path path;
  final Shelf shelf;

  ShelfNode(this.id, this.path, this.shelf);

  // override tostring to print the id and path offset
  @override
  String toString() {
    return 'ShelfNode{id: $id, path: ${path.getBounds().topLeft}}';
  }
}

Future<List<ShelfNode>> getShelfNodes(
    List<Shelf> shelves, String floorPlan) async {
  final svgString = await rootBundle.loadString(floorPlan);
  final document = XmlDocument.parse(svgString);

  final shelfMap = mapIdToShelf(shelves);

  final nodes = document
      .findAllElements('path')
      .where((element) =>
          element.getAttribute('id') != null &&
          element.getAttribute('d') != null &&
          shelfMap.containsKey(element.getAttribute('id')))
      .map((element) => ShelfNode(
          element.getAttribute('id')!,
          parseSvgPathData(element.getAttribute('d')!),
          shelfMap[element.getAttribute('id')]!))
      .toList();

  return nodes;
}
