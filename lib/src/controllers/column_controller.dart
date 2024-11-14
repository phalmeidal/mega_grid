import 'package:flutter/material.dart';
import '../../mega_grid.dart';

class ColumnController {
  final Map<int, double> columnWidths = {};
  final double minColumnWidth;
  final double maxColumnWidth;
  List<MegaColumn> columns;

  double? dragStartX;
  int? resizingColumnIndex;

  int? sortColumnIndex;
  bool isAscending = true;
  List<TableItem> originalItems = [];

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

  List<TableItem> sortItems(List<TableItem> items, int columnIndex) {
    if (originalItems.isEmpty) {
      originalItems = List.from(items);
    }

    if (sortColumnIndex == columnIndex) {
      if (isAscending) {
        isAscending = false;
      } else {
        sortColumnIndex = null;
        isAscending = true;
        return List.from(originalItems);
      }
    } else {
      sortColumnIndex = columnIndex;
      isAscending = true;
    }

    final field = columns[columnIndex].field;
    final sortedItems = List.from(items);

    final dateRegex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

    sortedItems.sort((a, b) {
      final aValue = a[field];
      final bValue = b[field];

      if (aValue == null || bValue == null) {
        return 0;
      }

      int comparison;

      if (aValue is String && bValue is String && dateRegex.hasMatch(aValue) && dateRegex.hasMatch(bValue)) {
        final aDate = _parseDate(aValue);
        final bDate = _parseDate(bValue);

        if (aDate != null && bDate != null) {
          comparison = aDate.compareTo(bDate);
        } else {
          comparison = aValue.toString().compareTo(bValue.toString());
        }
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return isAscending ? comparison : -comparison;
    });

    return sortedItems.cast<TableItem>();
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
