import 'package:flutter/material.dart';

class MegaGridStyle {
  final TextStyle? headerTextStyle;
  final TextStyle? cellTextStyle;
  final TextStyle? rowTextStyle;
  final TextStyle? rowAlternateTextStyle;
  final Color? headerBackgroundColor;
  final Color? rowBackgroundColor;
  final Color? rowAlternateBackgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final Color? borderColor;
  final double? borderWidth;

  /// Sets the background color of the visual feedback during column drag.
  final Color? feedbackBgColor;

  /// Sets the text color of the visual feedback during column drag.
  final Color? feedbackTextColor;

  /// Sets the border radius of the receiver when it is active as a destination during column drag.
  final BorderRadius? receiverDragBorder;

  /// Sets the background color of the receiver to indicate when it is active as a destination during column drag.
  final Color? receiverDragColor;

  final Color? selectedRowColor;
  final Color? selectedCellBorderColor;

  const MegaGridStyle({
    this.headerTextStyle,
    this.cellTextStyle,
    this.rowTextStyle,
    this.rowAlternateTextStyle,
    this.headerBackgroundColor,
    this.rowBackgroundColor,
    this.rowAlternateBackgroundColor,
    this.borderRadius,
    this.border,
    this.borderColor,
    this.borderWidth,
    this.feedbackBgColor,
    this.feedbackTextColor,
    this.receiverDragBorder,
    this.receiverDragColor,
    this.selectedRowColor,
    this.selectedCellBorderColor,
  });
}
