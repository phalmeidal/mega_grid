import 'package:flutter/material.dart';
import 'package:mega_grid/src/controllers/column_controller.dart';

class ColumnVisibilityDialog extends StatefulWidget {
  final ColumnController controller;
  final VoidCallback onVisibilityChanged;

  const ColumnVisibilityDialog({
    super.key,
    required this.controller,
    required this.onVisibilityChanged,
  });

  @override
  State<ColumnVisibilityDialog> createState() => _ColumnVisibilityDialogState();
}

class _ColumnVisibilityDialogState extends State<ColumnVisibilityDialog> {
  bool? _allSelected;

  @override
  void initState() {
    super.initState();
    _updateAllSelectedState();
  }

  void _updateAllSelectedState() {
    final hideableColumns = widget.controller.columns.asMap().entries.where((e) => e.value.canHide).map((e) => e.key).toList();

    if (hideableColumns.every((index) => widget.controller.isColumnVisible(index))) {
      _allSelected = true;
    } else if (hideableColumns.every((index) => !widget.controller.isColumnVisible(index))) {
      _allSelected = false;
    } else {
      _allSelected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      title: Row(
        children: [
          const Text('Show columns'),
          const SizedBox(width: 16),
          Checkbox(
            tristate: true,
            value: _allSelected,
            activeColor: Colors.lightBlue,
            onChanged: (bool? value) {
              setState(() {
                widget.controller.setAllColumnsVisibility(value ?? false);
                _updateAllSelectedState();
                widget.onVisibilityChanged();
              });
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.controller.columns.asMap().entries.where((e) => e.value.canHide).map((entry) {
            final columnIndex = entry.key;
            final column = entry.value;

            return CheckboxListTile(
              title: Text(column.title),
              value: widget.controller.isColumnVisible(columnIndex),
              activeColor: Colors.lightBlue,
              onChanged: (bool? value) {
                setState(() {
                  widget.controller.toggleColumnVisibility(columnIndex);
                  _updateAllSelectedState();
                  widget.onVisibilityChanged();
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
