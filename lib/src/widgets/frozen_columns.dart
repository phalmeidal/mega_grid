// frozen_columns.dart
import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';
import '../controllers/column_controller.dart';
import '../controllers/selection_controller.dart';
import 'grid_cell.dart';
import 'header_cell.dart';

class FrozenColumns extends StatelessWidget {
  final List<MapEntry<int, MegaColumn>> columns;
  final List<TableItem> sortedItems;
  final ColumnController columnController;
  final SelectionController selectionController;
  final MegaGridStyle? style;
  final Widget Function(String text)? feedback;
  final bool? enableColorReceiverDrag;
  final Function(void Function()) setState;

  const FrozenColumns({
    super.key,
    required this.columns,
    required this.sortedItems,
    required this.columnController,
    required this.selectionController,
    required this.style,
    required this.feedback,
    required this.enableColorReceiverDrag,
    required this.setState,
  });

  @override
  Widget build(BuildContext context) {
    bool isFrozenEnd = columns.any((entry) => columnController.frozenEndColumns.contains(entry.key));

    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: !isFrozenEnd
              ? BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                )
              : BorderSide.none,
          left: isFrozenEnd
              ? BorderSide(
                  color: Colors.grey[300]!,
                  width: 2,
                )
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: columns
                .map((entry) => HeaderCell(
                      column: entry.value,
                      index: entry.key,
                      style: style,
                      controller: columnController,
                      enableColorReceiverDrag: enableColorReceiverDrag,
                      feedback: feedback,
                      setState: setState,
                    ))
                .toList(),
          ),
          Column(
            children: sortedItems.asMap().entries.map((itemEntry) {
              final rowIndex = itemEntry.key;
              final item = itemEntry.value;
              final isAlternate = rowIndex % 2 == 1;

              return Row(
                children: columns.map((entry) {
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
