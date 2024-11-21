class SelectionController {
  int? selectedRowIndex;
  int? selectedColumnIndex;

  void selectCell(int rowIndex, int columnIndex) {
    selectedRowIndex = rowIndex;
    selectedColumnIndex = columnIndex;
  }

  void clearSelection() {
    selectedRowIndex = null;
    selectedColumnIndex = null;
  }

  bool isCellSelected(int rowIndex, int columnIndex) {
    return selectedRowIndex == rowIndex && selectedColumnIndex == columnIndex;
  }

  bool isRowSelected(int rowIndex) {
    return selectedRowIndex == rowIndex;
  }
}
