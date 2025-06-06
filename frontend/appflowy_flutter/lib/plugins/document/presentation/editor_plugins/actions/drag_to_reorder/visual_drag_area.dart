import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

import 'util.dart';

class VisualDragArea extends StatelessWidget {
  const VisualDragArea({
    super.key,
    required this.data,
    required this.dragNode,
    required this.editorState,
  });

  final DragAreaBuilderData data;
  final Node dragNode;
  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    final targetNode = data.targetNode;

    final ignore = shouldIgnoreDragTarget(
      editorState: editorState,
      dragNode: dragNode,
      targetPath: targetNode.path,
    );
    if (ignore) {
      return const SizedBox.shrink();
    }

    final selectable = targetNode.selectable;
    final renderBox = selectable?.context.findRenderObject() as RenderBox?;
    if (selectable == null || renderBox == null) {
      return const SizedBox.shrink();
    }

    final position = getDragAreaPosition(
      context,
      targetNode,
      data.dragOffset,
    );

    if (position == null) {
      return const SizedBox.shrink();
    }

    final (verticalPosition, horizontalPosition, globalBlockRect) = position;

    // 44 is the width of the drag indicator
    const indicatorWidth = 44.0;
    final width = globalBlockRect.width - indicatorWidth;

    Widget child = Container(
      height: 2,
      width: max(width, 0.0),
      color: Theme.of(context).colorScheme.primary,
    );

    // if the horizontal position is right, we need to show the indicator on the right side of the target node
    //  which represent moving the target node and drag node inside the column block.
    if (horizontalPosition == HorizontalPosition.left &&
        verticalPosition == VerticalPosition.middle) {
      return Positioned(
        top: globalBlockRect.top,
        height: globalBlockRect.height,
        left: globalBlockRect.left + indicatorWidth,
        child: Container(
          width: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (horizontalPosition == HorizontalPosition.right) {
      return Positioned(
        top: globalBlockRect.top,
        height: globalBlockRect.height,
        left: globalBlockRect.right - 2,
        child: Container(
          width: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // If the horizontal position is center, we need to show two indicators
    //which represent moving the block as the child of the target node.
    if (horizontalPosition == HorizontalPosition.center) {
      const breakWidth = 22.0;
      const padding = 8.0;
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            width: breakWidth,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: padding),
          Container(
            height: 2,
            width: width - breakWidth - padding,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      );
    }

    return Positioned(
      top: verticalPosition == VerticalPosition.top
          ? globalBlockRect.top
          : globalBlockRect.bottom,
      // 44 is the width of the drag indicator
      left: globalBlockRect.left + 44,
      child: child,
    );
  }
}
