import 'package:flutter/material.dart';
import 'package:mega_grid/src/widgets/grid_cell.dart';
import 'package:mega_grid/src/widgets/header_cell.dart';
import '../../models/table_items.dart';
import 'mega_column.dart';
import 'mega_grid_style.dart';
import '../../controllers/column_controller.dart';

class MegaGrid extends StatefulWidget {
  final List<TableItem> items;
  final MegaGridStyle? style;
  final List<MegaColumn> columns;
  final double? width;
  final double? height;
  final double minColumnWidth;
  final Widget Function(String text)? feedback;

  const MegaGrid({
    super.key,
    required this.items,
    required this.columns,
    this.style,
    this.width,
    this.height,
    this.minColumnWidth = 70.0,
    this.feedback,
  });

  @override
  MegaGridState createState() => MegaGridState();
}

class MegaGridState extends State<MegaGrid> {
  late ColumnController columnController;
  late ScrollController _horizontalScrollController;
  late List<TableItem> _sortedItems;

  @override
  void initState() {
    super.initState();
    columnController = ColumnController(
      columns: List.from(widget.columns),
      minColumnWidth: widget.minColumnWidth,
    );
    _horizontalScrollController = ScrollController();
    _sortedItems = List.from(widget.items);
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    columnController.initializeColumnWidths(context, widget.width);
  }

  void handleSort(int columnIndex) {
    setState(() {
      _sortedItems = columnController.sortItems(_sortedItems, columnIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width ?? MediaQuery.of(context).size.width;

    Widget content = SizedBox(
      width: width,
      child: Scrollbar(
        controller: _horizontalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalScrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: width),
            child: Container(
              decoration: BoxDecoration(
                border: widget.style?.borderColor != null
                    ? Border.all(
                        color: widget.style?.borderColor ?? Colors.black,
                        width: widget.style?.borderWidth ?? 1.0,
                      )
                    : null,
                borderRadius: widget.style?.borderRadius ?? BorderRadius.zero,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: columnController.columns.asMap().entries.map((entry) {
                        return HeaderCell(
                          column: entry.value,
                          index: entry.key,
                          style: widget.style,
                          controller: columnController,
                          feedback: widget.feedback,
                          setState: setState,
                        );
                      }).toList(),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _sortedItems.asMap().entries.map((itemEntry) {
                        final rowIndex = itemEntry.key;
                        final item = itemEntry.value;
                        final isAlternate = rowIndex % 2 == 1;

                        return Row(
                          children: columnController.columns.asMap().entries.map((columnEntry) {
                            final columnIndex = columnEntry.key;
                            final column = columnEntry.value;
                            final value = item[column.field] ?? '';

                            return GridCell(
                              value: value,
                              column: column,
                              columnIndex: columnIndex,
                              isAlternate: isAlternate,
                              style: widget.style,
                              controller: columnController,
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return widget.height != null ? SizedBox(height: widget.height, child: content) : content;
  }
}
