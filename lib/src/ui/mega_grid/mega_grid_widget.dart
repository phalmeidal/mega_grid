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

  const MegaGrid({
    super.key,
    required this.items,
    required this.columns,
    this.style,
    this.width,
    this.height,
  });

  @override
  MegaGridState createState() => MegaGridState();
}

class MegaGridState extends State<MegaGrid> {
  late List<MegaColumn> _columns;
  final Map<int, double> _columnWidths = {};

  @override
  void initState() {
    super.initState();
    _columns = widget.columns;
    for (var i = 0; i < _columns.length; i++) {
      _columnWidths[i] = _columns[i].minWidth ?? 100.0;
    }
  }

  void _swapColumns(int index1, int index2) {
    setState(() {
      // Troca as colunas
      final tempColumn = _columns[index1];
      _columns[index1] = _columns[index2];
      _columns[index2] = tempColumn;

      // Troca as larguras das colunas
      final tempWidth = _columnWidths[index1] ?? 100.0;
      _columnWidths[index1] = _columnWidths[index2] ?? 100.0;
      _columnWidths[index2] = tempWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.width ?? double.infinity,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ClipRRect(
              borderRadius: widget.style?.borderRadius ?? BorderRadius.zero,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(widget.style?.headerBackgroundColor),
                border: TableBorder(
                  top: widget.style?.border?.top ??
                      BorderSide(
                        color: widget.style?.borderColor ?? Colors.black,
                        width: widget.style?.borderWidth ?? 1.0,
                      ),
                  bottom: widget.style?.border?.bottom ??
                      BorderSide(
                        color: widget.style?.borderColor ?? Colors.black,
                        width: widget.style?.borderWidth ?? 1.0,
                      ),
                  left: widget.style?.border?.left ??
                      BorderSide(
                        color: widget.style?.borderColor ?? Colors.black,
                        width: widget.style?.borderWidth ?? 1.0,
                      ),
                  right: widget.style?.border?.right ??
                      BorderSide(
                        color: widget.style?.borderColor ?? Colors.black,
                        width: widget.style?.borderWidth ?? 1.0,
                      ),
                  borderRadius: widget.style?.borderRadius ?? BorderRadius.zero,
                ),
                columns: _columns.asMap().entries.map((entry) {
                  final index = entry.key;
                  final column = entry.value;

                  return DataColumn(
                    label: Draggable<int>(
                      data: index,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
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
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: _buildColumnLabel(column, index),
                      ),
                      child: DragTarget<int>(
                        onAccept: (draggedIndex) {
                          _swapColumns(draggedIndex, index);
                        },
                        builder: (context, candidateData, rejectedData) {
                          return _buildColumnLabel(column, index);
                        },
                      ),
                    ),
                  );
                }).toList(),
                rows: widget.items.map((item) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      if (widget.style?.rowAlternateBackgroundColor == null) {
                        return widget.style?.rowBackgroundColor;
                      }
                      return states.contains(MaterialState.selected) ? widget.style?.rowBackgroundColor : widget.style?.rowAlternateBackgroundColor;
                    }),
                    cells: _columns.asMap().entries.map((entry) {
                      final columnIndex = entry.key;
                      final column = entry.value;
                      final cellValue = item[column.field] ?? '';

                      TextStyle? textStyle = widget.style?.cellTextStyle;
                      if (widget.style?.rowTextStyle != null) {
                        textStyle = widget.style?.rowTextStyle;
                      }
                      if (widget.style?.rowAlternateTextStyle != null) {
                        textStyle = widget.style?.rowAlternateTextStyle;
                      }

                      return DataCell(
                        Container(
                          width: _columnWidths[columnIndex] ?? 100.0,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            cellValue.toString(),
                            style: textStyle,
                            textAlign: column.cellTextAlign,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumnLabel(MegaColumn column, int index) {
    return Row(
      children: [
        //const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
        // const SizedBox(width: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _columnWidths[index] ?? 100.0,
          alignment: Alignment.centerLeft,
          child: Text(
            column.title,
            style: widget.style?.headerTextStyle,
            textAlign: column.titleTextAlign,
          ),
        ),
      ],
    );
  }
}