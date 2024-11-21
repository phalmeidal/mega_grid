import 'package:flutter/material.dart';

class MegaColumn {
  final String title;
  final String field;
  final TextAlign titleTextAlign;
  final TextAlign cellTextAlign;
  final bool isEditable;
  final double? minWidth;
  final bool canHide;

  const MegaColumn({
    required this.title,
    required this.field,
    this.titleTextAlign = TextAlign.left,
    this.cellTextAlign = TextAlign.left,
    this.isEditable = false,
    this.minWidth,
    this.canHide = true,
  });
}
