import 'package:flutter/material.dart';
import 'package:mega_grid/src/widgets/column_visibility_dialog.dart';
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

  final Set<int> frozenStartColumns = {};
  final Set<int> frozenEndColumns = {};
  final Set<int> hiddenColumns = {};

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

    if (sortColumnIndex == index1) {
      sortColumnIndex = index2;
    } else if (sortColumnIndex == index2) {
      sortColumnIndex = index1;
    }
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

  void freezeColumnAtStart(int columnIndex) {
    frozenStartColumns.add(columnIndex);
    frozenEndColumns.remove(columnIndex);
  }

  void freezeColumnAtEnd(int columnIndex) {
    frozenEndColumns.add(columnIndex);
    frozenStartColumns.remove(columnIndex);
  }

  void unfreezeColumn(int columnIndex) {
    frozenStartColumns.remove(columnIndex);
    frozenEndColumns.remove(columnIndex);
  }

  bool isColumnFrozen(int columnIndex) {
    return frozenStartColumns.contains(columnIndex) || frozenEndColumns.contains(columnIndex);
  }

  void adjustColumnWidth(int columnIndex, BuildContext context) {
    double maxWidth = 0;

    final TextPainter headerPainter = TextPainter(
      text: TextSpan(
        text: columns[columnIndex].title,
        style: DefaultTextStyle.of(context).style,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    maxWidth = headerPainter.width + 40;

    columnWidths[columnIndex] = maxWidth.clamp(minColumnWidth, maxColumnWidth);
  }

  void toggleColumnVisibility(int columnIndex) {
    if (hiddenColumns.contains(columnIndex)) {
      hiddenColumns.remove(columnIndex);
    } else {
      hiddenColumns.add(columnIndex);
    }
  }

  bool isColumnVisible(int columnIndex) {
    return !hiddenColumns.contains(columnIndex);
  }

  void setAllColumnsVisibility(bool visible) {
    if (visible) {
      hiddenColumns.clear();
    } else {
      hiddenColumns.addAll(
        columns.asMap().entries.where((e) => e.value.canHide).map((e) => e.key),
      );
    }
  }

  void showColumnsDialog(BuildContext context, VoidCallback onVisibilityChanged) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => ColumnVisibilityDialog(
            controller: this,
            onVisibilityChanged: onVisibilityChanged,
          ),
        );
      }
    });
  }
}
