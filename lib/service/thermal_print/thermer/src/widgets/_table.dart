import 'package:flutter/material.dart';
import '_base_widget.dart';

class ThermerTableRow {
  final List<ThermerWidget> cells;

  const ThermerTableRow(this.cells);
}

class ThermerTable extends ThermerWidget {
  final List<ThermerTableRow> data;

  final ThermerTableRow? header;

  final Map<int, double?>? cellWidths;

  final double columnSpacing;

  final double rowSpacing;

  final TextStyle? style;

  final TextStyle? headerStyle;

  final String horizontalBorderChar;

  final String verticalBorderChar;

  final bool enableHeaderBorders;

  final bool enableTableBorders;

  const ThermerTable({
    required this.data,
    this.header,
    this.cellWidths,
    this.columnSpacing = 10.0,
    this.rowSpacing = 3.0,
    this.style,
    this.headerStyle,
    this.horizontalBorderChar = '-',
    this.verticalBorderChar = '|',
    this.enableHeaderBorders = true,
    this.enableTableBorders = false,
  });
}
