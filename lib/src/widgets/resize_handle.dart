import 'package:flutter/material.dart';
import 'package:mega_grid/src/controllers/column_controller.dart';

class ResizeHandle extends StatelessWidget {
  final int columnIndex;
  final ColumnController controller;
  final Function(void Function()) setState;

  const ResizeHandle({
    super.key,
    required this.columnIndex,
    required this.controller,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            controller.dragStartX = details.globalPosition.dx;
            controller.resizingColumnIndex = columnIndex;
          });
        },
        onHorizontalDragUpdate: (details) {
          if (controller.dragStartX != null && controller.resizingColumnIndex != null) {
            final delta = details.globalPosition.dx - controller.dragStartX!;
            setState(() {
              controller.updateColumnWidth(controller.resizingColumnIndex!, delta);
              controller.dragStartX = details.globalPosition.dx;
            });
          }
        },
        onHorizontalDragEnd: (details) {
          setState(() {
            controller.dragStartX = null;
            controller.resizingColumnIndex = null;
          });
        },
        child: Container(
          width: 25,
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: Icon(
              Icons.drag_handle,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
