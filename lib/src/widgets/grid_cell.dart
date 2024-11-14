import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';
import 'package:mega_grid/src/controllers/column_controller.dart';

class GridCell extends StatelessWidget {
  final dynamic value;
  final MegaColumn column;
  final int columnIndex;
  final bool isAlternate;
  final MegaGridStyle? style;
  final ColumnController controller;

  const GridCell({
    super.key,
    required this.value,
    required this.column,
    required this.columnIndex,
    required this.isAlternate,
    required this.style,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = style?.cellTextStyle;
    if (isAlternate && style?.rowAlternateTextStyle != null) {
      textStyle = style?.rowAlternateTextStyle;
    } else if (style?.rowTextStyle != null) {
      textStyle = style?.rowTextStyle;
    }

    return Container(
      width: controller.columnWidths[columnIndex],
      decoration: BoxDecoration(
        color: isAlternate ? style?.rowAlternateBackgroundColor : style?.rowBackgroundColor,
        border: style?.borderColor != null
            ? Border(
                right: BorderSide(
                  color: style?.borderColor ?? Colors.black,
                  width: style?.borderWidth ?? 1.0,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value.toString(),
        style: textStyle,
        textAlign: column.cellTextAlign,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
