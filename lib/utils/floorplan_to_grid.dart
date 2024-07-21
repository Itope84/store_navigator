import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path_drawing/path_drawing.dart';

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
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return false;
    }
    return cells[y][x];
  }

  bool isWalkableOrTarget(int x, int y, Offset target) {
    return isWalkable(x, y) || (x == target.dx && y == target.dy);
  }

  List<Offset>? aStar(Offset start, Offset target) {
    print("target: $target, start: $start");

    final fScores = Map<Offset, double>.fromIterable(
      cells.expand((row) => row
          .asMap()
          .entries
          .map((e) => Offset(e.key.toDouble(), cells.indexOf(row).toDouble()))),
      value: (_) => double.infinity,
    );
    fScores[start] = heuristic(start, target);

    final openSet = <Offset>[];
    openSet.add(start);

    final cameFrom = <Offset, Offset>{};

    final gScores = Map<Offset, double>.fromIterable(
      cells.expand((row) => row
          .asMap()
          .entries
          .map((e) => Offset(e.key.toDouble(), cells.indexOf(row).toDouble()))),
      value: (_) => double.infinity,
    );
    gScores[start] = 0;

    while (openSet.isNotEmpty) {
      openSet.sort((a, b) => fScores[a]!.compareTo(fScores[b]!));
      final current = openSet.removeAt(0);

      if (current == target) {
        return reconstructPath(cameFrom, current);
      }

      for (final neighbor in getNeighbors(current, target)) {
        final tentativeGScore = gScores[current]! + 1;

        if (tentativeGScore < gScores[neighbor]!) {
          cameFrom[neighbor] = current;
          gScores[neighbor] = tentativeGScore;
          fScores[neighbor] = gScores[neighbor]! + heuristic(neighbor, target);

          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return null; // No path found
  }

  double heuristic(Offset a, Offset b) {
    // TODO: can we just do a - b?
    return (a.dx - b.dx).abs() + (a.dy - b.dy).abs();
  }

  List<Offset> getNeighbors(Offset node, target) {
    final x = node.dx.toInt();
    final y = node.dy.toInt();

    // TODO: iswalkable might be the problem here
    return [
      ...(x > 0 && isWalkableOrTarget(x - 1, y, target)
          ? [Offset((x - 1), y.toDouble())]
          : []),
      ...(x < width - 1 && isWalkableOrTarget(x + 1, y, target)
          ? [Offset((x + 1), y.toDouble())]
          : []),
      ...(y > 0 && isWalkableOrTarget(x, y - 1, target)
          ? [Offset(x.toDouble(), (y - 1))]
          : []),
      ...(y < height - 1 && isWalkableOrTarget(x, y + 1, target)
          ? [Offset(x.toDouble(), (y + 1))]
          : []),
    ];
  }

  List<Offset> reconstructPath(Map<Offset, Offset> cameFrom, Offset current) {
    final totalPath = <Offset>[current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      totalPath.add(current);
    }
    return totalPath.reversed.toList();
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

  Rect scaleToGridRect(Rect value) {
    return Rect.fromLTRB(
        value.left / gridWidth * svgWidth,
        value.top / gridHeight * svgHeight,
        value.right / gridWidth * svgWidth,
        value.bottom / gridHeight * svgHeight);
  }

  // TODO: isValidPoint, checks if the point is within the section_wall if that exists, or otherwise is within the bounds of the grid (it will probably be)

  bool isValidPoint(Offset point) {
    if (paths.containsKey('section_wall')) {
      return paths['section_wall']!.getBounds().contains(point);
    } else {
      return point.dx >= 0 &&
          point.dx < svgWidth &&
          point.dy >= 0 &&
          point.dy < svgHeight;
    }
  }

  /**
   * Marks obstacles on the grid by going through the pixels in the path bounding box and seeing if they are inside the path.
   * This accounts for non-rectangular paths.
   *
   */
  void _markObstacles(Path path, Grid grid, double svgWidth, double svgHeight) {
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
