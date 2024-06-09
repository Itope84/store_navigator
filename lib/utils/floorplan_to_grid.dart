import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';
import 'dart:ui' as ui;

class Grid {
  final int width;
  final int height;
  List<List<bool>> cells;

  Grid(this.width, this.height)
      : cells = List.generate(height, (_) => List.generate(width, (_) => true));

  void addObstacle(int x, int y) {
    cells[y][x] = false;
  }

  bool isWalkable(int x, int y) {
    return cells[y][x];
  }
}

class SvgToGridConverter {
  final xml.XmlDocument document;
  final int gridWidth;
  final int gridHeight;

  double svgWidth = 0;
  double svgHeight = 0;

  HashMap<String, Path> paths = HashMap<String, Path>();

  SvgToGridConverter(this.document, this.gridWidth, this.gridHeight) {
    final svgElement = document.findElements('svg').first;

    svgWidth = double.parse(svgElement.getAttribute('width')!);
    svgHeight = double.parse(svgElement.getAttribute('height')!);
  }

  Grid parseSvg() {
    final grid = Grid(gridWidth, gridHeight);

    // TODO: handle wall, everything outside wall should be obstacle
    for (var element in document.findAllElements('path')) {
      final pathData = element.getAttribute('d');
      if (pathData != null) {
        final path = parseSvgPathData(pathData);
        // add path to paths by id attribute
        if (element.getAttribute('id') != null)
          paths.putIfAbsent(element.getAttribute('id')!, () => path);

        _markObstacles(path, grid, svgWidth, svgHeight);
      }
    }

    return grid;
  }

  Offset scaleToGrid(Offset value) {
    return Offset(
        value.dx / gridWidth * svgWidth, value.dy / gridHeight * svgHeight);
  }

  // TODO: scaling is unnecessary as we treat this in the scle of the SVG. Let the canvas zooming and panning deal with that. That;s the point!
  Rect scaleToGridRect(Rect value) {
    return Rect.fromLTRB(
        value.left / gridWidth * svgWidth,
        value.top / gridHeight * svgHeight,
        value.right / gridWidth * svgWidth,
        value.bottom / gridHeight * svgHeight);
  }

  // TODO: isValidPoint, checks if the point is within the section_wall if that exists, or otherwise is within the bounds of the grid (it will probably be)

  /**
   * Marks obstacles on the grid by going through the pixels in the path bounding box and seeing if they are inside the path.
   * This accounts for non-rectangular paths.
   *
  //  * TODO: figure out why items to the top of the svg are squished while the bottom is elongated. Could it be a factor of the rounding, or the viewbox?
   */
  void _markObstacles(
      ui.Path path, Grid grid, double svgWidth, double svgHeight) {
    final bbox = path.getBounds();
    for (int y = bbox.top.floor(); y < bbox.bottom.ceil(); y++) {
      for (int x = bbox.left.floor(); x < bbox.right.ceil(); x++) {
        final point = Offset(
          x / grid.width * svgWidth,
          y / grid.height * svgHeight,
        );

        if (path.contains(point)) {
          grid.addObstacle(x, y);
        }
      }
    }
  }
}
