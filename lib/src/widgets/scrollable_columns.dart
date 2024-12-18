import 'package:flutter/material.dart';
import 'package:mega_grid/src/controllers/column_controller.dart';
import 'package:mega_grid/src/controllers/selection_controller.dart';
import 'package:mega_grid/src/widgets/grid_cell.dart';
import 'package:mega_grid/src/widgets/header_cell.dart';

import '../../mega_grid.dart';

class ScrollableColumns extends StatelessWidget {
  final List<MapEntry<int, MegaColumn>> columns;
  final List<TableItem> sortedItems;
  final ColumnController columnController;
  final SelectionController selectionController;
  final MegaGridStyle? style;
  final Widget Function(String text)? feedback;
  final bool? enableColorReceiverDrag;
  final Function(void Function()) setState;
  final ScrollController scrollController;

  const ScrollableColumns({
    super.key,
    required this.columns,
    required this.sortedItems,
    required this.columnController,
    required this.selectionController,
    required this.style,
    required this.feedback,
    required this.enableColorReceiverDrag,
    required this.setState,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: columns.map((entry) {
            return Column(
              children: [
                HeaderCell(
                  column: entry.value,
                  index: entry.key,
                  style: style,
                  controller: columnController,
                  enableColorReceiverDrag: enableColorReceiverDrag,
                  feedback: feedback,
                  setState: setState,
                ),
                Column(
                  children: sortedItems.asMap().entries.map((itemEntry) {
                    final rowIndex = itemEntry.key;
                    final item = itemEntry.value;
                    final isAlternate = rowIndex % 2 == 1;

                    return GridCell(
                      value: item[entry.value.field],
                      column: entry.value,
                      columnIndex: entry.key,
                      rowIndex: itemEntry.key,
                      isAlternate: isAlternate,
                      style: style,
                      controller: columnController,
                      selectionController: selectionController,
                      onCellTap: (rowIndex, columnIndex) {
                        setState(() {
                          selectionController.selectCell(rowIndex, columnIndex);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
