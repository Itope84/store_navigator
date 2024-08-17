import 'package:flutter/material.dart';

Offset transformOffset(
    Matrix4 inverseMatrix, Offset offset, double initialScale) {
  final Offset untransformedOffset =
      MatrixUtils.transformPoint(inverseMatrix, offset);

  return Offset(untransformedOffset.dx * 1 / initialScale,
      untransformedOffset.dy * 1 / initialScale);
}

class MapGestureHandler extends StatefulWidget {
  final Widget child;
  final List<GlobalKey> keys;
  final double initialScale;
  final EdgeInsets boundaryMargin;
  final void Function(Offset position) onTapUp;

  const MapGestureHandler(
      {super.key,
      required this.child,
      required this.keys,
      required this.initialScale,
      required this.boundaryMargin,
      required this.onTapUp});

  @override
  State<MapGestureHandler> createState() => _MapGestureHandlerState();
}

class _MapGestureHandlerState extends State<MapGestureHandler> {
  final TransformationController _transformationController =
      TransformationController();

  Future<void> _onTapUp(TapUpDetails details) async {
    final Matrix4 inverseMatrix =
        Matrix4.inverted(_transformationController.value);

    Offset position = transformOffset(
        inverseMatrix, details.localPosition, widget.initialScale);

    void Function()? onTap;

    for (final key in widget.keys) {
      final RenderBox? box =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) {
        continue;
      }

      final buttonPosition = box.localToGlobal(Offset.zero);

      final buttonSize = box.size;
      final buttonRect = Rect.fromLTWH(buttonPosition.dx, buttonPosition.dy,
          buttonSize.width, buttonSize.height);

      if (buttonRect.contains(details.globalPosition)) {
        onTap = key.currentWidget is InkWell
            ? (key.currentWidget as InkWell).onTap
            : key.currentWidget is ButtonStyleButton
                ? (key.currentWidget as ButtonStyleButton).onPressed
                : null;
        break;
      }
    }

    if (onTap != null) {
      onTap!();
    } else {
      widget.onTapUp(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: _onTapUp,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        boundaryMargin: widget.boundaryMargin,
        child: widget.child,
      ),
    );
  }
}
