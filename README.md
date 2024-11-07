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
  Widget build

(Build

Context context) {
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
```

### Customization
You can customize the appearance of the grid using the MegaGridStyle class. Here are some of the properties you can set:

headerTextStyle: TextStyle for the header cells.
cellTextStyle: TextStyle for the data cells.
rowTextStyle: TextStyle for the rows.
rowAlternateTextStyle: TextStyle for alternate rows.
headerBackgroundColor: Background color for the header row.
rowBackgroundColor: Background color for the rows.
rowAlternateBackgroundColor: Background color for alternate rows.
borderRadius: Border radius for the grid.
border: Border for the grid.
borderColor: Color of the border.
borderWidth: Width of the border.