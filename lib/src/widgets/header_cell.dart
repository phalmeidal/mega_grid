import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';
import 'package:mega_grid/src/controllers/column_controller.dart';

class HeaderCell extends StatelessWidget {
  final MegaColumn column;
  final int index;
  final MegaGridStyle? style;
  final ColumnController controller;
  final Function(void Function()) setState;
  final bool? enableColorReceiverDrag;
  final Widget Function(String text)? feedback;

  const HeaderCell({
    super.key,
    required this.column,
    required this.index,
    required this.style,
    required this.controller,
    required this.setState,
    this.enableColorReceiverDrag,
    required this.feedback,
  });

  Widget _buildSortIcon(context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            controller.dragStartX = details.globalPosition.dx;
            controller.resizingColumnIndex = index;
          });
        },
        onPanUpdate: (details) {
          if (controller.dragStartX != null && controller.resizingColumnIndex != null) {
            final delta = details.globalPosition.dx - controller.dragStartX!;
            final totalWidth = MediaQuery.of(context).size.width;
            setState(() {
              controller.updateColumnWidth(controller.resizingColumnIndex!, delta, totalWidth);
              controller.dragStartX = details.globalPosition.dx;
            });
          }
        },
        onPanEnd: (details) {
          setState(() {
            controller.dragStartX = null;
            controller.resizingColumnIndex = null;
          });
        },
        onTapUp: (details) {
          _showColumnMenu(context);
        },
        child: Icon(
          controller.sortColumnIndex == index ? (controller.isAscending ? Icons.arrow_downward : Icons.arrow_upward) : Icons.drag_handle,
          size: 16,
        ),
      ),
    );
  }

  void _showColumnMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.topRight(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    double totalWidth = MediaQuery.of(context).size.width;

    showMenu(
      context: context,
      position: position,
      color: Colors.white,
      items: [
        if (!controller.isColumnFrozen(index))
          PopupMenuItem(
            value: 'freezeStart',
            enabled: controller.canFreezeColumn(index, totalWidth),
            onTap: () {
              setState(() {
                controller.freezeColumnAtStart(index, totalWidth);
              });
            },
            child: const Text('Freeze at start'),
          ),
        if (!controller.isColumnFrozen(index))
          PopupMenuItem(
            value: 'freezeEnd',
            enabled: controller.canFreezeColumn(index, totalWidth),
            child: const Text('Freeze at end'),
            onTap: () {
              setState(() {
                controller.freezeColumnAtEnd(index, totalWidth);
              });
            },
          ),
        if (controller.isColumnFrozen(index))
          PopupMenuItem(
            value: 'unfreeze',
            child: const Text('Unfreeze'),
            onTap: () {
              setState(() {
                controller.unfreezeColumn(index);
              });
            },
          ),
        PopupMenuItem(
          value: 'adjust',
          child: const Text('Adjust'),
          onTap: () {
            setState(() {
              controller.adjustColumnWidth(index, context);
            });
          },
        ),
        PopupMenuItem(
          value: 'showColumns',
          child: const Text('Show columns'),
          onTap: () {
            controller.showColumnsDialog(context, () => setState(() {}));
          },
        ),
      ],
    );
  }

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
      child: GestureDetector(
        onTap: () {
          setState(() {
            (context.findAncestorStateOfType<MegaGridState>() as MegaGridState).handleSort(index);
          });
        },
        child: Stack(
          children: [
            Draggable<int>(
              data: index,
              feedback: feedback != null
                  ? feedback!(column.title)
                  : Material(
                      elevation: 4,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: style?.feedbackBgColor ?? Colors.white,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          column.title,
                          style: style?.headerTextStyle?.copyWith(
                            color: style?.feedbackTextColor ?? Colors.black,
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
                  bool isDraggingOver = candidateData.isNotEmpty && candidateData.first != index && enableColorReceiverDrag != false;

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDraggingOver ? style?.receiverDragColor ?? Colors.blue.withOpacity(0.15) : Colors.transparent,
                      borderRadius: style?.receiverDragBorder ?? BorderRadius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                      child: Text(
                        column.title,
                        style: style?.headerTextStyle,
                        textAlign: column.titleTextAlign,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _buildSortIcon(context),
            ),
          ],
        ),
      ),
    );
  }
}
