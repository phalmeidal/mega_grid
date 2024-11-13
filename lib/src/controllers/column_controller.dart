import 'package:flutter/material.dart';
import '../ui/mega_grid/mega_column.dart';

class ColumnController {
  final Map<int, double> columnWidths = {};
  final double minColumnWidth;
  final double maxColumnWidth;
  List<MegaColumn> columns;

  double? dragStartX;
  int? resizingColumnIndex;

  ColumnController({
    required this.columns,
    this.minColumnWidth = 70.0,
    this.maxColumnWidth = 500.0,
  });

  void initializeColumnWidths(BuildContext context, double? definedWidth) {
    double totalWidth = definedWidth ?? MediaQuery.of(context).size.width;
    double defaultColumnWidth = totalWidth / columns.length;

    for (var i = 0; i < columns.length; i++) {
      columnWidths[i] = columns[i].minWidth ?? defaultColumnWidth * 0.995;
    }
  }

  void swapColumns(int index1, int index2) {
    final tempColumn = columns[index1];
    columns[index1] = columns[index2];
    columns[index2] = tempColumn;

    final tempWidth = columnWidths[index1] ?? 100.0;
    columnWidths[index1] = columnWidths[index2] ?? 100.0;
    columnWidths[index2] = tempWidth;
  }

  void updateColumnWidth(int columnIndex, double delta) {
    final newWidth = (columnWidths[columnIndex] ?? 100.0) + delta;
    columnWidths[columnIndex] = newWidth.clamp(minColumnWidth, maxColumnWidth);
  }
}
