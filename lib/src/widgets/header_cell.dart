import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';
import 'package:mega_grid/src/controllers/column_controller.dart';
import 'resize_handle.dart';

class HeaderCell extends StatelessWidget {
  final MegaColumn column;
  final int index;
  final MegaGridStyle? style;
  final ColumnController controller;
  final Function(void Function()) setState;

  const HeaderCell({
    super.key,
    required this.column,
    required this.index,
    required this.style,
    required this.controller,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: controller.columnWidths[index],
      decoration: BoxDecoration(
        color: style?.headerBackgroundColor,
        border: style?.borderColor != null
            ? Border(
                right: BorderSide(
                  color: style!.borderColor!,
                  width: style!.borderWidth ?? 1.0,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Draggable<int>(
              data: index,
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    column.title,
                    style: style?.headerTextStyle?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              child: DragTarget<int>(
                onAcceptWithDetails: (draggedIndex) {
                  setState(() {
                    controller.swapColumns(draggedIndex.data, index);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return Text(
                    column.title,
                    style: style?.headerTextStyle,
                    textAlign: column.titleTextAlign,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ResizeHandle(
              columnIndex: index,
              controller: controller,
              setState: setState,
            ),
          ),
        ],
      ),
    );
  }
}