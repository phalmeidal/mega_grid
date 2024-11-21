import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_grid/src/controllers/selection_controller.dart';
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
  final bool? enableColorReceiverDrag;

  const MegaGrid({
    super.key,
    required this.items,
    required this.columns,
    this.style,
    this.width,
    this.height,
    this.minColumnWidth = 70.0,
    this.feedback,
    this.enableColorReceiverDrag,
  });

  @override
  MegaGridState createState() => MegaGridState();
}

class MegaGridState extends State<MegaGrid> {
  late ColumnController columnController;
  late SelectionController selectionController;
  late ScrollController _horizontalScrollController;
  late List<TableItem> _sortedItems;
  late FocusNode _gridFocusNode;

  @override
  void initState() {
    super.initState();
    columnController = ColumnController(
      columns: List.from(widget.columns),
      minColumnWidth: widget.minColumnWidth,
    );
    selectionController = SelectionController();
    _horizontalScrollController = ScrollController();
    _sortedItems = List.from(widget.items);
    _gridFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _gridFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    columnController.initializeColumnWidths(context, widget.width);
  }

  void handleSort(int columnIndex) {
    setState(() {
      selectionController.clearSelection();
      _sortedItems = columnController.sortItems(_sortedItems, columnIndex);
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyC) {
        _copySelectedCell();
      }
    }
  }

  void _copySelectedCell() {
    if (selectionController.selectedRowIndex != null && selectionController.selectedColumnIndex != null) {
      final item = _sortedItems[selectionController.selectedRowIndex!];
      final column = columnController.columns[selectionController.selectedColumnIndex!];
      final value = item[column.field].toString();
      Clipboard.setData(ClipboardData(text: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.width ?? MediaQuery.of(context).size.width;

    final frozenStartColumns = columnController.columns.asMap().entries.where((e) => columnController.frozenStartColumns.contains(e.key) && columnController.isColumnVisible(e.key)).toList();
    final frozenEndColumns = columnController.columns.asMap().entries.where((e) => columnController.frozenEndColumns.contains(e.key) && columnController.isColumnVisible(e.key)).toList();
    final scrollableColumns = columnController.columns.asMap().entries.where((e) => !columnController.isColumnFrozen(e.key) && columnController.isColumnVisible(e.key)).toList();

    Widget content = KeyboardListener(
      focusNode: _gridFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTapDown: (details) {
          if (!_gridFocusNode.hasFocus) {
            _gridFocusNode.requestFocus();
          }
        },
        child: SizedBox(
          width: width,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (frozenStartColumns.isNotEmpty)
                  FrozenColumns(
                    columns: frozenStartColumns,
                    sortedItems: _sortedItems,
                    columnController: columnController,
                    selectionController: selectionController,
                    style: widget.style,
                    feedback: widget.feedback,
                    enableColorReceiverDrag: widget.enableColorReceiverDrag,
                    setState: setState,
                  ),
                Expanded(
                  child: ScrollableColumns(
                    columns: scrollableColumns,
                    sortedItems: _sortedItems,
                    columnController: columnController,
                    selectionController: selectionController,
                    style: widget.style,
                    feedback: widget.feedback,
                    enableColorReceiverDrag: widget.enableColorReceiverDrag,
                    setState: setState,
                  ),
                ),
                if (frozenEndColumns.isNotEmpty)
                  FrozenColumns(
                    columns: frozenEndColumns,
                    sortedItems: _sortedItems,
                    columnController: columnController,
                    selectionController: selectionController,
                    style: widget.style,
                    feedback: widget.feedback,
                    enableColorReceiverDrag: widget.enableColorReceiverDrag,
                    setState: setState,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return widget.height != null ? SizedBox(height: widget.height, child: content) : content;
  }
}

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
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey[300]!,
            width: 2,
          ),
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

class ScrollableColumns extends StatelessWidget {
  final List<MapEntry<int, MegaColumn>> columns;
  final List<TableItem> sortedItems;
  final ColumnController columnController;
  final SelectionController selectionController;
  final MegaGridStyle? style;
  final Widget Function(String text)? feedback;
  final bool? enableColorReceiverDrag;
  final Function(void Function()) setState;

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
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
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
