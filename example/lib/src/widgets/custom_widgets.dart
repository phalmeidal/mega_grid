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

  /// Creates a customizable loading indicator widget.
  ///
  /// This widget displays three animated dots that move up and down,
  /// indicating that more items are being loaded. It includes a text label
  /// to inform users about the loading process, enhancing the user experience.
  ///
  /// Returns a [Widget] that can be easily integrated into layouts as a
  /// loading indicator.
  ///
  /// ### Example Usage:
  /// ```dart
  /// return MegaGrid(
  ///   child: CustomWidgets.customLoader(),
  /// );
  /// ```
  ///
  static Widget customLoader() {
    return const Material(
      child: SizedBox(
          height: 25,
          width: 300,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading items',
                style: TextStyle(fontSize: 15),
              ),
              LoadingDots(),
            ],
          )),
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  LoadingDotsState createState() => LoadingDotsState();
}

class LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final animation = Tween<double>(begin: 5, end: 12).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.3,
            1.0,
            curve: Curves.easeInOut,
          ),
        ));

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, -animation.value),
                child: const Text(
                  '.',
                  style: TextStyle(fontSize: 25, color: Colors.black),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
