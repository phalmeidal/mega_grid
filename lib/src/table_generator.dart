import 'package:flutter/material.dart';
import 'table_items.dart';
import 'table_styles.dart';
import 'table_columns.dart';

class MegaGrid extends StatefulWidget {
  final List<TableItems> items;
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
  _MegaGridState createState() => _MegaGridState();
}

class _MegaGridState extends State<MegaGrid> {
  late List<MegaColumn> _columns;
  Map<int, double> _columnWidths = {};

  @override
  void initState() {
    super.initState();
    _columns = widget.columns;
    for (var i = 0; i < _columns.length; i++) {
      _columnWidths[i] = _columns[i].minWidth ?? 100.0;
    }
  }

  double get _totalWidth => _columnWidths.values.fold(0, (sum, width) => sum + width);

  void _onColumnDragUpdate(int index, DragUpdateDetails details) {
    setState(() {
      double deltaX = details.delta.dx;

      // Limite mínimo de largura da coluna atual
      if ((_columnWidths[index] ?? 100.0) + deltaX < 50.0) {
        deltaX = 50.0 - (_columnWidths[index] ?? 100.0);
      }

      // Limite máximo para o tamanho total das colunas dentro da tabela
      if (_totalWidth + deltaX > (widget.width ?? double.infinity)) {
        deltaX = (widget.width ?? double.infinity) - _totalWidth;
      }

      // Atualiza a largura da coluna
      _columnWidths[index] = (_columnWidths[index] ?? 100.0) + deltaX;

      // Lógica para troca de posição das colunas
      if (deltaX < 0 && index > 0 && (_columnWidths[index] ?? 100.0) < (_columnWidths[index - 1] ?? 100.0)) {
        _swapColumns(index, index - 1);
      } else if (deltaX > 0 && index < _columns.length - 1 && (_columnWidths[index] ?? 100.0) > (_columnWidths[index + 1] ?? 100.0)) {
        _swapColumns(index, index + 1);
      }
    });
  }

  void _swapColumns(int index1, int index2) {
    // Troca as colunas
    final tempColumn = _columns[index1];
    _columns[index1] = _columns[index2];
    _columns[index2] = tempColumn;

    // Troca as larguras das colunas
    final tempWidth = _columnWidths[index1] ?? 100.0;
    _columnWidths[index1] = _columnWidths[index2] ?? 100.0;
    _columnWidths[index2] = tempWidth;
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
                    label: GestureDetector(
                      onHorizontalDragUpdate: (details) => _onColumnDragUpdate(index, details),
                      child: Row(
                        children: [
                          const Icon(Icons.drag_indicator, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: _columnWidths[index] ?? 100.0,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              column.title,
                              style: widget.style?.headerTextStyle,
                              textAlign: column.titleTextAlign,
                            ),
                          ),
                        ],
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
                      final cellValue = item.toMap()[column.field] ?? '';

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
}
