import 'package:flutter/material.dart';
import '../../models/table_items.dart';
import 'mega_column.dart';
import 'mega_grid_style.dart';

class MegaGrid extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: width ?? double.infinity,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ClipRRect(
              borderRadius: style?.borderRadius ?? BorderRadius.zero,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(style?.headerBackgroundColor),
                border: TableBorder(
                  top: style?.border?.top ?? BorderSide(color: style?.borderColor ?? Colors.black, width: style?.borderWidth ?? 1.0),
                  bottom: style?.border?.bottom ?? BorderSide(color: style?.borderColor ?? Colors.black, width: style?.borderWidth ?? 1.0),
                  left: style?.border?.left ?? BorderSide(color: style?.borderColor ?? Colors.black, width: style?.borderWidth ?? 1.0),
                  right: style?.border?.right ?? BorderSide(color: style?.borderColor ?? Colors.black, width: style?.borderWidth ?? 1.0),
                  borderRadius: style?.borderRadius ?? BorderRadius.zero,
                ),
                columns: columns.map((column) {
                  return DataColumn(
                    label: Container(
                      alignment: Alignment.centerLeft,
                      width: column.minWidth,
                      child: Text(
                        column.title,
                        style: style?.headerTextStyle,
                        textAlign: column.titleTextAlign,
                      ),
                    ),
                  );
                }).toList(),
                rows: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                      return index.isEven ? style?.rowBackgroundColor : style?.rowAlternateBackgroundColor;
                    }),
                    cells: columns.map((column) {
                      final cellValue = item[column.field] ?? '';

                      TextStyle? textStyle = index.isEven ? style?.rowTextStyle : style?.rowAlternateTextStyle ?? style?.cellTextStyle;

                      return DataCell(
                        Text(
                          cellValue.toString(),
                          style: textStyle,
                          textAlign: column.cellTextAlign,
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
