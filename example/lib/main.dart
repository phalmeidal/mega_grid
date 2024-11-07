import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      TableItems(nome: 'John', idade: 30, id: 1),
      TableItems(nome: 'Jane', idade: 25, id: 2),
    ];

    final columns = [
      const MegaColumn(title: 'Name', field: 'nome', titleTextAlign: TextAlign.left, cellTextAlign: TextAlign.left),
      const MegaColumn(title: 'Age', field: 'idade', titleTextAlign: TextAlign.right, cellTextAlign: TextAlign.right),
      const MegaColumn(title: 'ID', field: 'id', titleTextAlign: TextAlign.center, cellTextAlign: TextAlign.center),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Grid Example')),
        body: MegaGrid(
          items: items,
          columns: columns,
          width: 600,
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
