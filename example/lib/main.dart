import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final columns = [
      const MegaColumn(title: 'Empresa', field: 'company'),
      const MegaColumn(title: 'Tomador', field: 'borrower'),
      const MegaColumn(title: 'Parcela', field: 'installment'),
      const MegaColumn(title: 'Vencimento', field: 'deadline'),
      const MegaColumn(title: 'Valor', field: 'value'),
    ];

    final List<TableItem> items = [
      {'company': 'Empresa 1', 'borrower': 'Pessoa 1', 'installment': 2, 'deadline': '01/01/2026', 'value': 1400.0},
      {'company': 'Empresa 2', 'borrower': 'Pessoa 2', 'installment': 3, 'deadline': '01/02/2026', 'value': 1500.0},
      {'company': 'Empresa 3', 'borrower': 'Pessoa 3', 'installment': 4, 'deadline': '01/03/2026', 'value': 1600.0},
      {'company': 'Empresa 4', 'borrower': 'Pessoa 4', 'installment': 5, 'deadline': '01/04/2026', 'value': 1700.0},
      {'company': 'Empresa 5', 'borrower': 'Pessoa 5', 'installment': 6, 'deadline': '01/05/2026', 'value': 1800.0},
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Grid Example')),
        body: MegaGrid(
          items: items,
          columns: columns,
          width: 1000,
          style: const MegaGridStyle(
            headerTextStyle: TextStyle(fontWeight: FontWeight.bold),
            cellTextStyle: TextStyle(color: Colors.black),
            headerBackgroundColor: Colors.amber,
            rowBackgroundColor: Colors.grey,
            rowTextStyle: TextStyle(color: Colors.white),
            rowAlternateBackgroundColor: Colors.blueGrey,
            rowAlternateTextStyle: TextStyle(color: Colors.black),
            borderColor: Colors.blue,
            borderWidth: 2.0,
          ),
        ),
      ),
    );
  }
}
