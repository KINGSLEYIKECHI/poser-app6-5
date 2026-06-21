import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '_shared_types.dart';
import '_layout_utils.dart';
import '../widgets/widgets.export.dart';

class ThermerPainter extends CustomPainter {
  final List<LayoutItem> layoutItems;
  final double layoutGap;
  final TextDirection textDirection;
  static const double charWidth = 10;

  ThermerPainter(this.layoutItems,
      {this.layoutGap = 3.0, this.textDirection = TextDirection.ltr});

  @override
  void paint(Canvas canvas, Size size) {
    double yOffset = 0;
    final linePaint = Paint()
      ..color = const Color(0xFF000000)
      ..strokeWidth = 1;

    for (final item in layoutItems) {
      _paintWidget(canvas, size, item.widget, yOffset, linePaint);
      yOffset += item.height + layoutGap;
    }
  }

  void _paintWidget(Canvas canvas, Size size, ThermerWidget widget,
      double yOffset, Paint linePaint) {
    if (widget is ThermerText) {
      final textPainter = TextMeasurementCache.getPainter(
        widget.data,
        widget.style ?? const TextStyle(),
        widget.direction ?? textDirection,
        widget.textAlign,
        widget.maxLines,
        size.width,
        widget.fallbackFonts,
      );
      double xOffset = 0;

      final effectiveAlign = widget.textAlign;

      if (effectiveAlign == TextAlign.center) {
        xOffset = (size.width - textPainter.width) / 2;
      } else if (effectiveAlign == TextAlign.right) {
        xOffset = size.width - textPainter.width;
      } else if (effectiveAlign == TextAlign.left) {
        xOffset = 0;
      } else if (effectiveAlign == TextAlign.start) {
        xOffset = textDirection == TextDirection.rtl
            ? size.width - textPainter.width
            : 0;
      } else if (effectiveAlign == TextAlign.end) {
        xOffset = textDirection == TextDirection.rtl
            ? 0
            : size.width - textPainter.width;
      } else if (effectiveAlign == TextAlign.justify) {
        xOffset = textDirection == TextDirection.rtl
            ? size.width - textPainter.width
            : 0;
      }

      textPainter.paint(canvas, Offset(xOffset, yOffset));
    } else if (widget is ThermerRow) {
      _paintRow(canvas, size, widget, yOffset, linePaint);
    } else if (widget is ThermerColumn) {
      _paintColumn(canvas, size, widget, yOffset, linePaint);
    } else if (widget is ThermerTable) {
      _paintTable(canvas, size, widget, yOffset, linePaint);
    } else if (widget is ThermerDivider) {
      _paintDivider(canvas, size, widget, yOffset, linePaint);
    } else if (widget is ThermerImage) {
      _paintImage(canvas, size, widget, yOffset);
    } else if (widget is ThermerQRCode) {
      _paintQRCode(canvas, size, widget, yOffset);
    } else if (widget is ThermerAlign) {
      _paintAlign(canvas, size, widget, yOffset, linePaint);
    } else if (widget is ThermerExpanded) {
      _paintWidget(canvas, size, widget.child, yOffset, linePaint);
    } else if (widget is ThermerFlexible) {
      _paintWidget(canvas, size, widget.child, yOffset, linePaint);
    } else if (widget is ThermerSizedBox) {
      if (widget.child != null) {
        final childSize = Size(
          widget.width ?? size.width,
          widget.height ?? _calculateChildHeight(widget.child!, size.width),
        );
        _paintWidget(canvas, childSize, widget.child!, yOffset, linePaint);
      }
    } else {
      throw Exception('Unknown widget type: ${widget.runtimeType}');
    }
  }

  void _paintTable(Canvas canvas, Size size, ThermerTable widget,
      double yOffset, Paint linePaint) {
    final numColumns = widget.data.isNotEmpty
        ? widget.data[0].cells.length
        : (widget.header?.cells.length ?? 0);
    final actualWidths =
        LayoutUtils.calculateCellWidths(widget, size.width, numColumns);

    double currentY = yOffset;
    final isRtl = textDirection == TextDirection.rtl;

    double getColumnX(int colIndex) {
      if (!isRtl) {
        double x = 0;
        for (int i = 0; i < colIndex; i++) {
          x += actualWidths[i];
          if (widget.cellWidths == null) x += widget.columnSpacing;
        }
        return x;
      } else {
        double rightEdgeOffset = 0;
        for (int i = 0; i < colIndex; i++) {
          rightEdgeOffset += actualWidths[i];
          if (widget.cellWidths == null)
            rightEdgeOffset += widget.columnSpacing;
        }
        return size.width - rightEdgeOffset - actualWidths[colIndex];
      }
    }

    if (widget.header != null) {
      if (widget.enableHeaderBorders) {
        _paintHorizontalBorder(
            canvas, size, currentY, widget.horizontalBorderChar);
        currentY += _getBorderHeight(size.width, widget.horizontalBorderChar);
      }

      double rowHeight = 0;
      for (int col = 0; col < widget.header!.cells.length; col++) {
        final cellWidget = widget.header!.cells[col];
        final cellWidth = actualWidths[col];
        final cellSize = Size(cellWidth, double.infinity);

        final x = getColumnX(col);

        canvas.save();
        canvas.translate(x, 0);
        _paintWidget(canvas, cellSize, cellWidget, currentY, linePaint);
        canvas.restore();

        final cellHeight = _calculateChildHeight(cellWidget, cellWidth);
        if (cellHeight > rowHeight) rowHeight = cellHeight;
      }
      currentY += rowHeight;

      if (widget.enableHeaderBorders) {
        currentY += widget.rowSpacing;
        _paintHorizontalBorder(
            canvas, size, currentY, widget.horizontalBorderChar);
        currentY += _getBorderHeight(size.width, widget.horizontalBorderChar);
      }

      currentY += widget.rowSpacing;
    }

    for (int i = 0; i < widget.data.length; i++) {
      final row = widget.data[i];
      double rowHeight = 0;

      for (int col = 0; col < row.cells.length; col++) {
        final cellWidget = row.cells[col];
        final cellWidth = actualWidths[col];
        final cellSize = Size(cellWidth, double.infinity);

        final x = getColumnX(col);

        canvas.save();
        canvas.translate(x, 0);
        _paintWidget(canvas, cellSize, cellWidget, currentY, linePaint);
        canvas.restore();

        final cellHeight = _calculateChildHeight(cellWidget, cellWidth);
        if (cellHeight > rowHeight) rowHeight = cellHeight;
      }
      currentY += rowHeight;
      if (i < widget.data.length - 1) currentY += widget.rowSpacing;
    }
  }

  void _paintHorizontalBorder(
      Canvas canvas, Size size, double yOffset, String char) {
    const defaultStyle = TextStyle(
        fontSize: 20, color: Color(0xFF000000), fontWeight: FontWeight.w500);
    final borderLength =
        _calculateDividerLength(char, size.width, defaultStyle);
    final borderPainter = TextMeasurementCache.getPainter(
      char * borderLength,
      defaultStyle,
      TextDirection.ltr,
      TextAlign.left,
      null,
      size.width,
    );
    borderPainter.paint(canvas, Offset(0, yOffset));
  }

  double _getBorderHeight(double width, String char) {
    const defaultStyle = TextStyle(
        fontSize: 20, color: Color(0xFF000000), fontWeight: FontWeight.w500);
    final borderLength = _calculateDividerLength(char, width, defaultStyle);
    final borderPainter = TextMeasurementCache.getPainter(
      char * borderLength,
      defaultStyle,
      TextDirection.ltr,
      TextAlign.left,
      null,
      width,
    );
    return borderPainter.height;
  }

  void _paintRow(Canvas canvas, Size size, ThermerRow row, double yOffset,
      Paint linePaint) {
    if (row.children.isEmpty) return;

    final fixedChildren = <ThermerWidget>[];
    final flexibleChildren = <ThermerWidget>[];
    final fixedIndices = <int>[];
    final flexibleIndices = <int>[];
    final flexValues = <int>[];

    for (int i = 0; i < row.children.length; i++) {
      final child = row.children[i];
      if (child is ThermerExpanded) {
        flexibleChildren.add(child);
        flexibleIndices.add(i);
        flexValues.add(child.flex);
      } else if (child is ThermerFlexible &&
          child.fit == ThermerFlexFit.loose) {
        flexibleChildren.add(child);
        flexibleIndices.add(i);
        flexValues.add(child.flex);
      } else {
        fixedChildren.add(child);
        fixedIndices.add(i);
      }
    }

    final fixedWidths = fixedChildren
        .map((child) => _calculateChildWidth(child, size.width))
        .toList();

    final childHeights = row.children
        .map((child) => _calculateChildHeight(
            child, _calculateChildWidth(child, size.width)))
        .toList();
    final rowHeight = childHeights.reduce((a, b) => a > b ? a : b);

    final totalFixedWidth =
        fixedWidths.isNotEmpty ? fixedWidths.reduce((a, b) => a + b) : 0;
    final totalSpacing = (row.children.length - 1) * row.spacing;
    final remainingWidth = size.width - totalFixedWidth - totalSpacing;

    final totalFlex =
        flexValues.isNotEmpty ? flexValues.reduce((a, b) => a + b) : 0;
    final flexibleWidths = <double>[];
    if (totalFlex > 0 && remainingWidth > 0) {
      for (final flex in flexValues) {
        flexibleWidths.add((flex / totalFlex) * remainingWidth);
      }
    } else {
      flexibleWidths.addAll(List.filled(flexibleChildren.length, 0.0));
    }

    final actualWidths = List<double>.filled(row.children.length, 0);
    for (int i = 0; i < fixedIndices.length; i++) {
      actualWidths[fixedIndices[i]] = fixedWidths[i];
    }
    for (int i = 0; i < flexibleIndices.length; i++) {
      actualWidths[flexibleIndices[i]] = flexibleWidths[i];
    }

    final totalChildrenWidth = actualWidths.reduce((a, b) => a + b);
    final isRtl = textDirection == TextDirection.rtl;

    double startX = 0;
    double dynamicSpacing = row.spacing;

    var effectiveAlignment = row.mainAxisAlignment;

    switch (effectiveAlignment) {
      case ThermerMainAxisAlignment.start:
        startX = isRtl ? size.width : 0;
        break;
      case ThermerMainAxisAlignment.center:
        final offset = (size.width -
                totalChildrenWidth -
                (row.children.length - 1) * row.spacing) /
            2;
        startX = isRtl ? size.width - offset : offset;
        break;
      case ThermerMainAxisAlignment.end:
        final offset = size.width -
            totalChildrenWidth -
            (row.children.length - 1) * row.spacing;
        startX = isRtl ? size.width - offset : offset;

        startX = isRtl
            ? totalChildrenWidth + (row.children.length - 1) * row.spacing
            : size.width -
                totalChildrenWidth -
                (row.children.length - 1) * row.spacing;
        break;
      case ThermerMainAxisAlignment.spaceBetween:
        startX = isRtl ? size.width : 0;
        if (row.children.isNotEmpty && row.children.length > 1) {
          dynamicSpacing =
              (size.width - totalChildrenWidth) / (row.children.length - 1);
        }
        break;
      case ThermerMainAxisAlignment.spaceAround:
        final totalSpace = size.width - totalChildrenWidth;
        final spacePerChild =
            row.children.isNotEmpty ? totalSpace / row.children.length : 0.0;
        startX = isRtl ? size.width - spacePerChild / 2 : spacePerChild / 2;
        dynamicSpacing = spacePerChild;
        break;
      case ThermerMainAxisAlignment.spaceEvenly:
        final totalSpace = size.width - totalChildrenWidth;
        final spacePerGap = row.children.isNotEmpty
            ? totalSpace / (row.children.length + 1)
            : 0.0;
        startX = isRtl ? size.width - spacePerGap : spacePerGap;
        dynamicSpacing = spacePerGap;
        break;
    }

    double currentX = startX;

    for (int i = 0; i < row.children.length; i++) {
      final child = row.children[i];
      final childWidth = actualWidths[i];
      final childHeight = childHeights[i];

      double childY = yOffset;
      double effectiveChildHeight = rowHeight;
      if (row.crossAxisAlignment == ThermerCrossAxisAlignment.center) {
        childY += (rowHeight - childHeight) / 2;
      } else if (row.crossAxisAlignment == ThermerCrossAxisAlignment.end) {
        childY += rowHeight - childHeight;
      } else if (row.crossAxisAlignment == ThermerCrossAxisAlignment.stretch) {
        effectiveChildHeight = rowHeight;
        childY = yOffset;
      } else {
        effectiveChildHeight = childHeight;
        childY = yOffset;
      }

      double paintX;
      if (isRtl) {
        currentX -= childWidth;
        paintX = currentX;
      } else {
        paintX = currentX;
        currentX += childWidth;
      }

      canvas.save();
      canvas.translate(paintX, 0);
      _paintWidget(canvas, Size(childWidth, effectiveChildHeight), child,
          childY, linePaint);
      canvas.restore();

      if (i < row.children.length - 1) {
        if (isRtl) {
          currentX -= dynamicSpacing;
        } else {
          currentX += dynamicSpacing;
        }
      }
    }
  }

  void _paintColumn(Canvas canvas, Size size, ThermerColumn column,
      double yOffset, Paint linePaint) {
    if (column.children.isEmpty) return;

    final fixedChildren = <ThermerWidget>[];
    final flexibleChildren = <ThermerWidget>[];
    final fixedIndices = <int>[];
    final flexibleIndices = <int>[];
    final flexValues = <int>[];

    for (int i = 0; i < column.children.length; i++) {
      final child = column.children[i];
      if (child is ThermerExpanded) {
        flexibleChildren.add(child);
        flexibleIndices.add(i);
        flexValues.add(child.flex);
      } else if (child is ThermerFlexible &&
          child.fit == ThermerFlexFit.loose) {
        flexibleChildren.add(child);
        flexibleIndices.add(i);
        flexValues.add(child.flex);
      } else {
        fixedChildren.add(child);
        fixedIndices.add(i);
      }
    }

    final fixedHeights = fixedChildren
        .map((child) => _calculateChildHeight(
            child, _calculateChildWidth(child, size.width)))
        .toList();
    final totalFixedHeight =
        fixedHeights.isNotEmpty ? fixedHeights.reduce((a, b) => a + b) : 0;
    final totalSpacing = (column.children.length - 1) * column.spacing;
    final remainingHeight = size.height - totalFixedHeight - totalSpacing;

    final totalFlex =
        flexValues.isNotEmpty ? flexValues.reduce((a, b) => a + b) : 0;
    final flexibleHeights = <double>[];
    if (totalFlex > 0 && remainingHeight > 0) {
      for (final flex in flexValues) {
        flexibleHeights.add((flex / totalFlex) * remainingHeight);
      }
    } else {
      flexibleHeights.addAll(List.filled(flexibleChildren.length, 0.0));
    }

    final actualHeights = List<double>.filled(column.children.length, 0);
    for (int i = 0; i < fixedIndices.length; i++) {
      actualHeights[fixedIndices[i]] = fixedHeights[i];
    }
    for (int i = 0; i < flexibleIndices.length; i++) {
      actualHeights[flexibleIndices[i]] = flexibleHeights[i];
    }

    double currentY = yOffset;
    final isRtl = textDirection == TextDirection.rtl;

    for (int i = 0; i < column.children.length; i++) {
      final child = column.children[i];
      final childHeight = actualHeights[i];
      final childWidth = _calculateChildWidth(child, size.width);

      double childX = 0;
      double effectiveChildWidth = childWidth;

      if (column.crossAxisAlignment == ThermerCrossAxisAlignment.center) {
        childX = (size.width - effectiveChildWidth) / 2;
      } else if (column.crossAxisAlignment == ThermerCrossAxisAlignment.end) {
        childX = isRtl ? 0 : size.width - effectiveChildWidth;
      } else if (column.crossAxisAlignment == ThermerCrossAxisAlignment.start) {
        childX = isRtl ? size.width - effectiveChildWidth : 0;
      } else if (column.crossAxisAlignment ==
          ThermerCrossAxisAlignment.stretch) {
        effectiveChildWidth = size.width;
        childX = 0;
      } else {
        childX = (size.width - effectiveChildWidth) / 2;
      }

      canvas.save();
      canvas.translate(childX, 0);
      _paintWidget(canvas, Size(effectiveChildWidth, childHeight), child,
          currentY, linePaint);
      canvas.restore();

      currentY += childHeight + column.spacing;
    }
  }

  double _calculateChildWidth(ThermerWidget child, double availableWidth) {
    return LayoutUtils.calculateWidgetWidth(child, availableWidth,
        defaultTextDirection: textDirection);
  }

  double _calculateChildHeight(ThermerWidget child, double maxWidth) {
    return LayoutUtils.calculateWidgetHeight(child, maxWidth,
        defaultTextDirection: textDirection);
  }

  void _paintDivider(Canvas canvas, Size size, ThermerDivider divider,
      double yOffset, Paint linePaint) {
    const dividerStyle = TextStyle(
        fontSize: 20, color: Color(0xFF000000), fontWeight: FontWeight.w500);

    if (divider.isHorizontal) {
      final length = divider.length ??
          _calculateDividerLength(divider.character, size.width, dividerStyle);
      final textPainter = TextMeasurementCache.getPainter(
        divider.character * length,
        dividerStyle,
        TextDirection.ltr,
        TextAlign.left,
        null,
        size.width,
      );
      textPainter.paint(canvas, Offset(0, yOffset));
    } else {
      final length = divider.length ?? 1;
      final textPainter = TextMeasurementCache.getPainter(
        divider.character * length,
        dividerStyle,
        TextDirection.ltr,
        TextAlign.left,
        null,
        size.width,
      );
      for (int i = 0; i < length; i++) {
        textPainter.paint(canvas, Offset(0, yOffset + i * textPainter.height));
      }
    }
  }

  int _calculateDividerLength(
      String character, double maxWidth, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: character,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    if (textPainter.width == 0) return 0;
    return (maxWidth / textPainter.width).floor();
  }

  void _paintImage(
      Canvas canvas, Size size, ThermerImage imageWidget, double yOffset) {
    final srcRect = Rect.fromLTWH(0, 0, imageWidget.image.width.toDouble(),
        imageWidget.image.height.toDouble());
    final dstRect = Rect.fromLTWH(0, yOffset, size.width, size.height);
    canvas.drawImageRect(imageWidget.image, srcRect, dstRect, Paint());
  }

  void _paintQRCode(
      Canvas canvas, Size size, ThermerQRCode qrWidget, double yOffset) {
    canvas.save();
    canvas.translate(0, yOffset);
    final qrPainter = QrPainter(
      data: qrWidget.data,
      version: QrVersions.auto,
      errorCorrectionLevel: qrWidget.errorCorrectionLevel,
      dataModuleStyle: const QrDataModuleStyle(
        color: Color(0xFF000000),
        dataModuleShape: QrDataModuleShape.square,
      ),
      eyeStyle: const QrEyeStyle(
        color: Color(0xFF000000),
        eyeShape: QrEyeShape.square,
      ),
    );
    qrPainter.paint(canvas, Size(qrWidget.size, qrWidget.size));
    canvas.restore();
  }

  void _paintAlign(Canvas canvas, Size size, ThermerAlign alignWidget,
      double yOffset, Paint linePaint) {
    final childWidth = LayoutUtils.calculateWidgetWidth(
      alignWidget.child,
      size.width,
      defaultTextDirection: textDirection,
    );
    final childHeight = LayoutUtils.calculateWidgetHeight(
      alignWidget.child,
      size.width,
      defaultTextDirection: textDirection,
    );

    double xOffset = 0;
    final isRtl = textDirection == TextDirection.rtl;

    switch (alignWidget.alignment) {
      case ThermerAlignment.left:
        xOffset = isRtl ? size.width - childWidth : 0;
        break;
      case ThermerAlignment.center:
        xOffset = (size.width - childWidth) / 2;
        break;
      case ThermerAlignment.right:
        xOffset = isRtl ? 0 : size.width - childWidth;
        break;
    }

    canvas.save();
    canvas.translate(xOffset, 0);
    _paintWidget(canvas, Size(childWidth, childHeight), alignWidget.child,
        yOffset, linePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
