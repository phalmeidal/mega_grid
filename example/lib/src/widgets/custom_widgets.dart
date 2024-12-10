import 'package:flutter/material.dart';

/// The `CustomWidgets` class includes static methods for creating pre-designed widgets.
/// These widgets serve as templates for building custom components, demonstrating best practices
/// such as consistent styling, Material Design wrapping, and dynamic customization.
///
/// ### Example Usage
/// Here’s how to use the `CustomWidgets` class in a `MegaGrid`:
///
/// ```dart
/// return MegaGrid(
///   feedback: (t) => CustomWidgets.customFeedback(t),
///   customIncreaseRow: CustomWidgets.customLoadButton,
/// );
/// ```
///
/// This example demonstrates the integration of custom widgets for feedback and loading more rows
/// in a `MegaGrid`. The `customFeedback` method provides visual feedback when dragging a column,
/// while the `customLoadButton` allows users to add more rows to the grid.
///

class CustomWidgets {
  /// Creates a feedback widget that displays the name of the column being dragged and an icon.
  /// This widget is wrapped in a [Material] with elevation and rounded corners.
  /// It displays a row containing the provided name of the column and an icon.
  /// - [value]: The string to display in the widget (the name of the column). If null, an empty string is shown.
  /// Returns a [Widget] that can be directly used in layouts.
  /// - Example: `feedback: (t) => CustomWidgets.customFeedback(t),`.
  static Widget Function(String) customFeedback = (String? value) {
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
        ]),
      ),
    );
  };

  /// Creates a customizable button widget designed for loading more items.
  ///
  /// When tapped, it executes the provided callback to add more rows to the table.
  /// - [onTap]: A [VoidCallback] executed when the button is tapped, which adds
  ///   more items to the table.
  /// Returns a [Widget] that can be directly used in layouts.
  /// ### Example Usage: 
  ///  ```dart
  /// return MegaGrid(
  ///   customIncreaseRow: CustomWidgets.customLoadButton,
  /// );
  /// ```
  static Widget customLoadButton(VoidCallback onTap) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 114, 200, 219).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Carregar mais itens",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}