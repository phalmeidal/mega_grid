import 'dart:convert';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:mega_grid/src/widgets/frozen_columns.dart';
import 'package:mega_grid/src/widgets/scrollable_columns.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mega_grid/src/controllers/selection_controller.dart';
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

  final bool showExportButton;

  final IconData? downloadIcon;

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
    this.showExportButton = true,
    this.downloadIcon,
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

  void _exportCsv() {
    List<List<dynamic>> rows = [];

    rows.add(columnController.columns.asMap().entries.where((entry) => columnController.isColumnVisible(entry.key)).map((entry) => entry.value.title).toList());

    for (var item in _sortedItems.take(_visibleRows)) {
      List<dynamic> row = [];
      for (var entry in columnController.columns.asMap().entries) {
        int index = entry.key;
        var column = entry.value;
        if (columnController.isColumnVisible(index)) {
          row.add(item[column.field]);
        }
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    (html.document.createElement('a') as html.AnchorElement)
      ..href = url
      ..download = 'tabela.csv'
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  void _exportXlsx() {
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet()];

    if (sheet == null) {
      throw Exception('Nenhuma planilha padrão foi criada.');
    }

    var headerRow = columnController.columns.asMap().entries.where((entry) => columnController.isColumnVisible(entry.key)).map((entry) => entry.value.title).toList();
    CellStyle headerStyle = CellStyle(bold: true);

    for (var colIndex = 0; colIndex < headerRow.length; colIndex++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: colIndex,
        rowIndex: 0,
      ));
      cell.value = TextCellValue(headerRow[colIndex]);
      cell.cellStyle = headerStyle;
    }

    for (var rowIndex = 0; rowIndex < _visibleRows && rowIndex < _sortedItems.length; rowIndex++) {
      var item = _sortedItems[rowIndex];
      var colCounter = 0;

      for (var entry in columnController.columns.asMap().entries) {
        int index = entry.key;
        var column = entry.value;

        if (columnController.isColumnVisible(index)) {
          var value = item[column.field] ?? '';
          sheet
              .cell(CellIndex.indexByColumnRow(
                columnIndex: colCounter,
                rowIndex: rowIndex + 1,
              ))
              .value = TextCellValue(value.toString());
          colCounter++;
        }
      }
    }

    // Gerar os bytes do arquivo Excel
    final bytes = excel.encode();

    if (bytes != null) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement()
        ..href = url
        ..download = 'table.xlsx'
        ..click();

      html.Url.revokeObjectUrl(url);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.showExportButton)
              SizedBox(
                height: 30,
                width: width,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton(
                    tooltip: 'Export',
                    icon: Icon(widget.downloadIcon ?? Icons.file_download_outlined),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        onTap: _exportCsv,
                        child: const Text('Export to CSV'),
                      ),
                      PopupMenuItem(
                        onTap: _exportXlsx,
                        child: const Text('Export to XLSX'),
                      ),
                    ],
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      iconSize: WidgetStateProperty.all(18.0),
                    ),
                  ),
                ),
              ),
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
      debugShowCheckedModeBanner: false,
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
