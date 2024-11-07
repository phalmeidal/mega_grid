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
  });
}
