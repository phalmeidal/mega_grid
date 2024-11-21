import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';
import 'package:mega_grid/src/controllers/column_controller.dart';
import 'package:mega_grid/src/controllers/selection_controller.dart';

class GridCell extends StatelessWidget {
  final dynamic value;
  final MegaColumn column;
  final int columnIndex;
  final int rowIndex;
  final bool isAlternate;
  final MegaGridStyle? style;
  final ColumnController controller;
  final SelectionController selectionController;
  final Function(int, int) onCellTap;

  const GridCell({
    super.key,
    required this.value,
    required this.column,
    required this.columnIndex,
    required this.rowIndex,
    required this.isAlternate,
    required this.style,
    required this.controller,
    required this.selectionController,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = style?.cellTextStyle;
    if (isAlternate && style?.rowTextStyle != null) {
      textStyle = style?.rowAlternateTextStyle;
    } else if (style?.rowTextStyle != null) {
      textStyle = style?.rowTextStyle;
    }

    final bool isSelected = selectionController.isCellSelected(rowIndex, columnIndex);
    final bool isRowSelected = selectionController.isRowSelected(rowIndex);

    return GestureDetector(
      onTap: () => onCellTap(rowIndex, columnIndex),
      child: Container(
        width: controller.columnWidths[columnIndex],
        decoration: BoxDecoration(
          color: isRowSelected ? (style?.selectedRowColor ?? Colors.lightBlue.withOpacity(0.1)) : (isAlternate ? style?.rowAlternateBackgroundColor : style?.rowBackgroundColor),
          border: Border.all(
            color: isSelected ? (style?.selectedCellBorderColor ?? Colors.lightBlue) : (style?.borderColor ?? Colors.transparent),
            width: isSelected ? 1.0 : (style?.borderWidth ?? 0.0),
          ),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Text(
          value.toString(),
          style: textStyle,
          textAlign: column.cellTextAlign,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
