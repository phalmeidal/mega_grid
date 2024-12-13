import 'dart:math';
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
  ///
  /// Note: When used with infinite scrolling via `isInfinityLoading`,
  /// `initialRowLimit` will be ignored if its value is less than the number
  /// of rows required to fill the entire element size. In such cases, the
  /// value will automatically be set to the minimum required to enable scrolling.
  final int? initialRowLimit;

  /// The number of additional rows to display when the "Load More" action is triggered.
  final int? increaseRowLimit;
  final IconData? loadMoreIcon;

  /// Customizable widget that displays a button or control to increase visible rows.
  final Widget Function(VoidCallback)? customIncreaseRow;

  /// Determines the type of loading mechanism for adding more items to the table.
  ///
  /// - If `true`, enables infinite scrolling, where more items are added to the list
  ///   dynamically as the user reaches the end of the current content.
  /// - If `false`, additional items are loaded only when the user clicks a button
  ///   to manually add more.
  /// - If not set, the table will load all rows upfront.
  ///
  /// Note: If `initialRowLimit` is set, all elements will not be loaded, as the
  /// number of rows will be restricted by the value of `initialRowLimit`, and
  /// the default loading type will be manual.
  final bool isInfinityLoading;

  /// Determines the custom loading widget to be displayed during loading operations.
  ///
  /// - If set, this widget will take priority and be used as the loading indicator,
  ///   overriding any value provided by `circularProgress`.
  /// - If both `customLoader` and `circularProgress` are not set, a default loading
  ///   indicator will be rendered.
  final Widget? customLoader;

  /// Determines the circular progress indicator to be displayed during loading operations.
  ///
  /// - If set, this instance of `CircularProgressIndicator` will be used as the
  ///   loading indicator unless a `customLoader` is also set.
  /// - If both `circularProgress` and `customLoader` are not set, a default loading
  ///   indicator will be rendered.
  ///
  /// Note: The `customLoader` takes priority if both are set.
  final CircularProgressIndicator? circularProgress;

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
    this.isInfinityLoading = false,
    this.customLoader,
    this.circularProgress,
  });

  @override
  MegaGridState createState() => MegaGridState();
}

class MegaGridState extends State<MegaGrid> {
  late ColumnController columnController;
  late SelectionController selectionController;
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;
  late List<TableItem> _sortedItems;
  late FocusNode _gridFocusNode;
  int _visibleRows = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    columnController = ColumnController(
      columns: List.from(widget.columns),
      minColumnWidth: widget.minColumnWidth,
    );
    selectionController = SelectionController();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
    _sortedItems = List.from(widget.items);
    _gridFocusNode = FocusNode();
    _visibleRows = widget.initialRowLimit ?? _sortedItems.length;

    if (widget.isInfinityLoading) {
      if (widget.initialRowLimit == null) _visibleRows = 0;

      _verticalScrollController.addListener(() {
        if (_verticalScrollController.position.pixels >= _verticalScrollController.position.maxScrollExtent - 10 && _visibleRows < widget.items.length) {
          _loadMoreItems();
        }
      });
      _checkAndLoadMoreItems();
    }
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
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

      if (_visibleRows > _sortedItems.length) _visibleRows = _sortedItems.length;

      _sortedItems = columnController.sortItems(_sortedItems, columnIndex, _visibleRows, false);
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

  void _checkAndLoadMoreItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verticalScrollController.position.maxScrollExtent == 0 && _visibleRows < widget.items.length) {
        _loadMoreItems(true);
        _checkAndLoadMoreItems();
      }
    });
  }

  void _loadMoreItems([bool isChecking = false]) {
    final increment = widget.increaseRowLimit ?? 10;
    final remainingItems = widget.items.length - _visibleRows;

    if (columnController.sortColumnIndex != null) {
      _sortedItems = columnController.sortItems(widget.items, columnController.sortColumnIndex!, _visibleRows, true);
    }

    if (remainingItems > 0) {
      setState(() {
        _isLoading = true;
      });

      isChecking
          ? (
              _visibleRows += min(increment, remainingItems),
              _isLoading = false,
            )
          : (Future.delayed(
              const Duration(seconds: 1),
              () {
                setState(() {
                  _visibleRows += min(increment, remainingItems);
                  _isLoading = false;
                });
              },
            ));
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: width,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (frozenStartColumns.isNotEmpty)
                      FrozenColumns(
                        columns: frozenStartColumns,
                        sortedItems: _sortedItems.sublist(0, min(_visibleRows, _sortedItems.length)),
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
                        sortedItems: _sortedItems.sublist(0, min(_visibleRows, _sortedItems.length)),
                        columnController: columnController,
                        selectionController: selectionController,
                        style: widget.style,
                        feedback: widget.feedback,
                        enableColorReceiverDrag: widget.enableColorReceiverDrag,
                        setState: setState,
                        scrollController: _horizontalScrollController,
                      ),
                    ),
                    if (frozenEndColumns.isNotEmpty)
                      FrozenColumns(
                        columns: frozenEndColumns,
                        sortedItems: _sortedItems.sublist(0, min(_visibleRows, _sortedItems.length)),
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
          ],
        ),
      ),
    );

    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: widget.height,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: widget.isInfinityLoading ? _verticalScrollController : null,
                    scrollDirection: Axis.vertical,
                    child: tableContent,
                  ),
                ),
              ),
              if (_isLoading)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: widget.customLoader ?? widget.circularProgress ?? const CircularProgressIndicator(),
                ),
              const SizedBox(height: 3),
              SizedBox(
                child: Center(
                  child: (!widget.isInfinityLoading && _visibleRows < _sortedItems.length)
                      ? (widget.customIncreaseRow != null
                          ? widget.customIncreaseRow!(() {
                              _loadMoreItems();
                            })
                          : IconButton(
                              iconSize: 30,
                              onPressed: _loadMoreItems,
                              icon: Icon(
                                widget.loadMoreIcon ?? Icons.add_circle_sharp,
                                color: Colors.black,
                              ),
                            ))
                      : null,
                ),
              ),
              const SizedBox(height: 3),
            ],
          ),
        ),
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
