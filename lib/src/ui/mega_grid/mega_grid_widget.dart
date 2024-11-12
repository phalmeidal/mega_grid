import 'package:flutter/material.dart';
import '../../models/table_items.dart';
import 'mega_column.dart';
import 'mega_grid_style.dart';

class MegaGrid extends StatefulWidget {
  final List<TableItem> items;
  final MegaGridStyle? style;
  final List<MegaColumn> columns;
  final double? width;
  final double? height;
  final double minColumnWidth;

  const MegaGrid({
    super.key,
    required this.items,
    required this.columns,
    this.style,
    this.width,
    this.height,
    this.minColumnWidth = 70.0,
  });

  @override
  MegaGridState createState() => MegaGridState();
}

class MegaGridState extends State<MegaGrid> {
  late List<MegaColumn> _columns;
  final Map<int, double> _columnWidths = {};
  double? _dragStartX;
  int? _resizingColumnIndex;
  late ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _columns = widget.columns;
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeColumnWidths();
  }

  void _initializeColumnWidths() {
    double totalWidth = widget.width ?? MediaQuery.of(context).size.width;
    double defaultColumnWidth = totalWidth / _columns.length;

    for (var i = 0; i < _columns.length; i++) {
      _columnWidths[i] = _columns[i].minWidth ?? defaultColumnWidth * 0.995;
    }
  }

  void _swapColumns(int index1, int index2) {
    setState(() {
      final tempColumn = _columns[index1];
      _columns[index1] = _columns[index2];
      _columns[index2] = tempColumn;

      final tempWidth = _columnWidths[index1] ?? 100.0;
      _columnWidths[index1] = _columnWidths[index2] ?? 100.0;
      _columnWidths[index2] = tempWidth;
    });
  }

  Widget _buildResizeHandle(int columnIndex) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            _dragStartX = details.globalPosition.dx;
            _resizingColumnIndex = columnIndex;
          });
        },
        onHorizontalDragUpdate: (details) {
          if (_dragStartX != null && _resizingColumnIndex != null) {
            final delta = details.globalPosition.dx - _dragStartX!;
            setState(() {
              final newWidth = (_columnWidths[_resizingColumnIndex] ?? 100.0) + delta;
              _columnWidths[_resizingColumnIndex!] = newWidth.clamp(widget.minColumnWidth, 500.0);
              _dragStartX = details.globalPosition.dx;
            });
          }
        },
        onHorizontalDragEnd: (details) {
          setState(() {
            _dragStartX = null;
            _resizingColumnIndex = null;
          });
        },
        child: Container(
          width: 25,
          height: double.infinity,
          color: Colors.transparent,
          child: Center(
            child: Icon(
              Icons.drag_handle,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(MegaColumn column, int index) {
    return Container(
      width: _columnWidths[index],
      decoration: BoxDecoration(
        color: widget.style?.headerBackgroundColor,
        border: widget.style?.borderColor != null
            ? Border(
                right: BorderSide(
                  color: widget.style!.borderColor!,
                  width: widget.style!.borderWidth ?? 1.0,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Draggable<int>(
              data: index,
              feedback: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    column.title,
                    style: widget.style?.headerTextStyle?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              child: DragTarget<int>(
                onAcceptWithDetails: (draggedIndex) {
                  _swapColumns(draggedIndex.data, index);
                },
                builder: (context, candidateData, rejectedData) {
                  return Text(
                    column.title,
                    style: widget.style?.headerTextStyle,
                    textAlign: column.titleTextAlign,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: _buildResizeHandle(index),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(dynamic value, MegaColumn column, int columnIndex, bool isAlternate) {
    TextStyle? textStyle = widget.style?.cellTextStyle;
    if (isAlternate && widget.style?.rowAlternateTextStyle != null) {
      textStyle = widget.style?.rowAlternateTextStyle;
    } else if (widget.style?.rowTextStyle != null) {
      textStyle = widget.style?.rowTextStyle;
    }

    return Container(
      width: _columnWidths[columnIndex],
      decoration: BoxDecoration(
        color: isAlternate ? widget.style?.rowAlternateBackgroundColor : widget.style?.rowBackgroundColor,
        border: widget.style?.borderColor != null
            ? Border(
                right: BorderSide(
                  color: widget.style?.borderColor ?? Colors.black,
                  width: widget.style?.borderWidth ?? 1.0,
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
                      children: _columns.asMap().entries.map((entry) {
                        return _buildHeaderCell(entry.value, entry.key);
                      }).toList(),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.asMap().entries.map((itemEntry) {
                        final rowIndex = itemEntry.key;
                        final item = itemEntry.value;
                        final isAlternate = rowIndex % 2 == 1;

                        return Row(
                          children: _columns.asMap().entries.map((columnEntry) {
                            final columnIndex = columnEntry.key;
                            final column = columnEntry.value;
                            final value = item[column.field] ?? '';

                            return _buildCell(value, column, columnIndex, isAlternate);
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
