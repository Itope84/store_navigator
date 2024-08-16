// import 'package:flutter/material.dart';

// class Graveyard {
//   late SvgToGridConverter converter;

//   Rect _getSectionRect(String sectionId) {
//     final section = converter.paths[sectionId];

//     return section?.getBounds() ?? Rect.zero;
//   }

//   Rect _getSectionRectWithPadding(String sectionId) {
//     final sectionRect = _getSectionRect(sectionId);

//     return sectionRect;
//     // return Rect.fromLTRB(sectionRect.left - 2, sectionRect.top - 2,
//     // sectionRect.right + 2, sectionRect.bottom + 2);
//   }

//   Offset _getSectionCenter(String sectionId) {
//     final sectionRect = _getSectionRect(sectionId);

//     return Offset(sectionRect.left + sectionRect.width / 2,
//         sectionRect.top + sectionRect.height / 2);
//   }

// // TODO: remove all these
//   Offset _getSectionAisleSideMidpoint(String sectionId) {
//     // The open midpoint of the open side of the section is the walkable point closest to the center of the section

//     final sectionRect = _getSectionRectWithPadding(sectionId);

//     final midpoint = Offset(sectionRect.left + sectionRect.width / 2,
//         sectionRect.top + sectionRect.height / 2);

//     // Check the four sides of the section, find the midpoint of each side (the side is the 5px padding around the section), if it is not walkable, skip it; otherwise, sort by distance to the midpoint and return the closest one
//     final sideMidpoints = [
//       Offset(sectionRect.left, sectionRect.top + sectionRect.height / 2),
//       Offset(sectionRect.right, sectionRect.top + sectionRect.height / 2),
//       Offset(sectionRect.left + sectionRect.width / 2, sectionRect.top),
//       Offset(sectionRect.left + sectionRect.width / 2, sectionRect.bottom)
//     ];

//     // TODO: scale
//     final walkableSideMidpoints = sideMidpoints
//         .where((point) => grid.isWalkable(point.dx.ceil(), point.dy.ceil()))
//         .toList();

//     walkableSideMidpoints.sort((a, b) => (a - midpoint)
//         .distanceSquared
//         .compareTo((b - midpoint).distanceSquared));

//     // TODO: remove
//     setState(() {
//       items.add(walkableSideMidpoints.first);
//     });

//     return walkableSideMidpoints.first;
//   }
// }
