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
          feedback: (t) => customFeedback(t),
          style: MegaGridStyle(
            headerTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            cellTextStyle: const TextStyle(color: Colors.black),
            headerBackgroundColor: Colors.white,
            rowBackgroundColor: const Color(0xFFFAFAFA),
            rowTextStyle: const TextStyle(color: Colors.black),
            rowAlternateBackgroundColor: Colors.white,
            borderColor: Colors.transparent,
            borderWidth: 1.0,
            borderRadius: BorderRadius.circular(54),
          ),
        ),
      ),
    );
  }
}

Widget Function(String) customFeedback = (String? value) {
  return Material(
    elevation: 4,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 114, 200, 219).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(value ?? ""),
        const Icon(Icons.query_stats),
        // const Icon(Icons.drag_indicator),
      ]),
    ),
  );
};
