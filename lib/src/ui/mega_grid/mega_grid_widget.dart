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

  /// Customizable widget that provides visual feedback during the drag of a column to a receiver.
  final Widget Function(String text)? feedback;

  /// Enables a background color on the receiver element to provide visual confirmation when dragging a column and placing it over the receiver.
  final bool? enableColorReceiverDrag;

  /// The initial number of rows to display in the table.
  final int? initialRowLimit;

  /// The number of additional rows to display when the "Load More" action is triggered.
  final int? increaseRowLimit;
  final IconData? loadMoreIcon;

  /// Customizable widget that displays a button or control to increase visible rows.
  final Widget Function(VoidCallback)? customIncreaseRow;

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
    this.initialRowLimit,
    this.increaseRowLimit,
    this.loadMoreIcon,
    this.customIncreaseRow,
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
  int _visibleRows = 0;

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
    _visibleRows = widget.initialRowLimit ?? _sortedItems.length;
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
    setState(
      () {
        selectionController.clearSelection();

        if (_visibleRows > _sortedItems.length) {
          _visibleRows = _sortedItems.length;
        }
        
        _sortedItems = columnController.sortItems(_sortedItems, columnIndex, _visibleRows, false);
      },
    );
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

    Widget tableContent = KeyboardListener(
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
                    sortedItems: _sortedItems.take(_visibleRows).toList(),
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
                    sortedItems: _sortedItems.take(_visibleRows).toList(),
                    columnController: columnController,
                    selectionController: selectionController,
                    style: widget.style,
                    feedback: widget.feedback,
                    enableColorReceiverDrag: widget.enableColorReceiverDrag,
                    setState: setState,
                    scrollController: _horizontalScrollController, // Add this line
                  ),
                ),
                if (frozenEndColumns.isNotEmpty)
                  FrozenColumns(
                    columns: frozenEndColumns,
                    sortedItems: _sortedItems.take(_visibleRows).toList(),
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          tableContent,
          if (_visibleRows < _sortedItems.length)
            widget.customIncreaseRow != null
                ? widget.customIncreaseRow!(
                    () {
                      setState(
                        () {
                          _visibleRows += widget.increaseRowLimit ?? 3;

                          if (_visibleRows > _sortedItems.length) {
                            _visibleRows = _sortedItems.length;
                          }

                          if (columnController.sortColumnIndex != null) {
                            _sortedItems = columnController.sortItems(widget.items, columnController.sortColumnIndex!, _visibleRows, true);
                          }
                        },
                      );
                    },
                  )
                : IconButton(
                    iconSize: 30,
                    onPressed: () {
                      setState(
                        () {
                          _visibleRows += widget.increaseRowLimit ?? 3;

                          if (_visibleRows > _sortedItems.length) {
                            _visibleRows = _sortedItems.length;
                          }

                          if (columnController.sortColumnIndex != null) {
                            _sortedItems = columnController.sortItems(widget.items, columnController.sortColumnIndex!, _visibleRows, true);
                          }
                        },
                      );
                    },
                    icon: Icon(
                      widget.loadMoreIcon ?? Icons.add_circle_sharp,
                      color: Colors.black,
                    ),
                  ),
        ],
      ),
    );
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
    // Check if any of the columns are frozen at the end
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
