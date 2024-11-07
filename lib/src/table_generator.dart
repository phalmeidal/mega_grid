import 'package:flutter/material.dart';
import 'table_items.dart';
import 'table_styles.dart';
import 'table_columns.dart';

class MegaGrid extends StatelessWidget {
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
                headingRowColor: MaterialStateProperty.all(style?.headerBackgroundColor),
                border: TableBorder(
                  top: style?.border?.top ??
                      BorderSide(
                        color: style?.borderColor ?? Colors.black,
                        width: style?.borderWidth ?? 1.0,
                      ),
                  bottom: style?.border?.bottom ??
                      BorderSide(
                        color: style?.borderColor ?? Colors.black,
                        width: style?.borderWidth ?? 1.0,
                      ),
                  left: style?.border?.left ??
                      BorderSide(
                        color: style?.borderColor ?? Colors.black,
                        width: style?.borderWidth ?? 1.0,
                      ),
                  right: style?.border?.right ??
                      BorderSide(
                        color: style?.borderColor ?? Colors.black,
                        width: style?.borderWidth ?? 1.0,
                      ),
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
                    color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      if (style?.rowAlternateBackgroundColor == null) {
                        return style?.rowBackgroundColor;
                      }
                      return index.isEven ? style?.rowBackgroundColor : style?.rowAlternateBackgroundColor;
                    }),
                    cells: columns.map((column) {
                      final cellValue = item.toMap()[column.field] ?? '';

                      TextStyle? textStyle = style?.cellTextStyle;

                      if (style?.rowTextStyle != null) {
                        textStyle = style?.rowTextStyle;
                      }

                      if (style?.rowAlternateTextStyle != null && !index.isEven) {
                        textStyle = style?.rowAlternateTextStyle;
                      }

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
