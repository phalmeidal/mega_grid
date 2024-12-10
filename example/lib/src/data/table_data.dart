import 'dart:math';
import 'package:mega_grid/mega_grid.dart';

class TableData {
  /// A list of predefined table items representing companies and their associated data.
  ///
  /// Each item is a map containing:
  /// - `company`: The name of the company (String).
  /// - `borrower`: The name of the borrower (String).
  /// - `installment`: The installment number (int).
  /// - `deadline`: The payment deadline in DD/MM/YYYY format (String).
  /// - `value`: The monetary value associated with the entry (double).
  ///
  /// This data can be used to populate tables or grids in the UI.
  final List<TableItem> tableItems = [
    {'company': 'Empresa 1', 'borrower': 'Pessoa 1', 'installment': 7, 'deadline': '15/09/2026', 'value': 1700.0},
    {'company': 'Empresa 2', 'borrower': 'Pessoa 2', 'installment': 3, 'deadline': '30/02/2026', 'value': 5000.0},
    {'company': 'Empresa 3', 'borrower': 'Pessoa 3', 'installment': 2, 'deadline': '01/01/2025', 'value': 3400.0},
    {'company': 'Empresa 4', 'borrower': 'Pessoa 4', 'installment': 5, 'deadline': '01/04/2026', 'value': 7100.0},
    {'company': 'Empresa 5', 'borrower': 'Pessoa 5', 'installment': 6, 'deadline': '07/05/2026', 'value': 1800.0},
    {'company': 'Empresa 6', 'borrower': 'Pessoa 6', 'installment': 7, 'deadline': '15/09/2026', 'value': 1600.0},
    {'company': 'Empresa 7', 'borrower': 'Pessoa 7', 'installment': 3, 'deadline': '30/02/2026', 'value': 4900.0},
    {'company': 'Empresa 8', 'borrower': 'Pessoa 8', 'installment': 2, 'deadline': '01/01/2025', 'value': 3300.0},
    {'company': 'Empresa 9', 'borrower': 'Pessoa 9', 'installment': 5, 'deadline': '01/04/2026', 'value': 7000.0},
    {'company': 'Empresa 10', 'borrower': 'Pessoa 10', 'installment': 6, 'deadline': '07/05/2026', 'value': 2000.0},
    {'company': 'Empresa 11', 'borrower': 'Pessoa 11', 'installment': 7, 'deadline': '15/09/2026', 'value': 1900.0},
    {'company': 'Empresa 12', 'borrower': 'Pessoa 12', 'installment': 3, 'deadline': '30/02/2026', 'value': 5200.0},
    {'company': 'Empresa 13', 'borrower': 'Pessoa 13', 'installment': 2, 'deadline': '01/01/2025', 'value': 3600.0},
    {'company': 'Empresa 14', 'borrower': 'Pessoa 14', 'installment': 5, 'deadline': '01/04/2026', 'value': 7300.0},
    {'company': 'Empresa 15', 'borrower': 'Pessoa 15', 'installment': 6, 'deadline': '07/05/2026', 'value': 2100.0},
    {'company': 'Empresa 16', 'borrower': 'Pessoa 16', 'installment': 7, 'deadline': '15/09/2026', 'value': 2000.0},
    {'company': 'Empresa 17', 'borrower': 'Pessoa 17', 'installment': 3, 'deadline': '30/02/2026', 'value': 5300.0},
    {'company': 'Empresa 18', 'borrower': 'Pessoa 18', 'installment': 2, 'deadline': '01/01/2025', 'value': 3700.0},
    {'company': 'Empresa 19', 'borrower': 'Pessoa 19', 'installment': 5, 'deadline': '01/04/2026', 'value': 7400.0},
    {'company': 'Empresa 20', 'borrower': 'Pessoa 20', 'installment': 6, 'deadline': '07/05/2026', 'value': 2200.0},
  ];

  /// Generates a list of company data dynamically based on the given number of rows.
  ///
  /// Each generated entry is a map containing:
  /// - `company`: The name of the company (String).
  /// - `borrower`: The name of the borrower (String).
  /// - `installment`: The installment number (int), cycling between 1 and 12.
  /// - `deadline`: The payment deadline in DD/MM/YYYY format (String), based on the row number.
  /// - `value`: A random monetary value (double) starting at 1500.0.
  ///
  /// Returns a [List] of maps, each representing a row of company data.
  List<Map<String, dynamic>> generateCompanyData(int row) {
    List<Map<String, dynamic>> companies = [];
    Random rng = Random();
    for (int i = 1; i <= row; i++) {
      companies.add({
        'company': 'Empresa $i',
        'borrower': 'Pessoa $i',
        'installment': (i % 12) + 1,
        'deadline': '${((i % 30) + 1).toString().padLeft(2, '0')}/${((i % 12) + 1).toString().padLeft(2, '0')}/${2020 + (i % 6)}',
        'value': 1500.0 + (rng.nextInt(10000)),
      });
    }
    return companies;
  }
}
