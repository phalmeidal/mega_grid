# Mega Grid

Mega Grid is a Flutter package that provides a customizable grid widget for displaying tabular data. It allows you to define columns, styles, and data items to create a flexible and visually appealing grid.

## Features

- Customizable columns with titles, alignment, and editability options.
- Configurable styles for headers, cells, rows, and alternate rows.
- Support for horizontal and vertical scrolling.
- Border and border radius customization.

## Installation

Add the following dependency to your ```pubspec.yaml``` file:

```
dependencies:
  mega_grid: ^1.0.0
```

Then, run ```flutter pub get``` to install the package.

## Usage

Import the package in your Dart file:

```
import 'package:mega_grid/mega_grid.dart';
```

### Example

Here's a basic example of how to use the Mega Grid widget:

```
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
```

### Customization
You can customize the appearance of the grid using the ```MegaGridStyle``` class. Here are some of the properties you can set:

```headerTextStyle:``` TextStyle for the header cells.
```cellTextStyle:``` TextStyle for the data cells.
```rowTextStyle:``` TextStyle for the rows.
```rowAlternateTextStyle:``` TextStyle for alternate rows.
```headerBackgroundColor:``` Background color for the header row.
```rowBackgroundColor:``` Background color for the rows.
```rowAlternateBackgroundColor:``` Background color for alternate rows.
```borderRadius:``` Border radius for the grid.
```border:``` Border for the grid.
```borderColor:``` Color of the border.
```borderWidth:``` Width of the border.
