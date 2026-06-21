import 'package:flutter/material.dart';
import '../widgets/widgets.export.dart';

class TextMeasurementCache {
  static final Map<String, _CachedMeasurement> _cache = {};

  static void clear() {
    _cache.clear();
  }

  static _CachedMeasurement _getCachedMeasurement(
    String text,
    TextStyle style,
    TextDirection direction,
    TextAlign textAlign,
    int? maxLines,
    double maxWidth,
    List<String>? fallbackFonts,
  ) {
    final key = _generateKey(
      text,
      style,
      direction,
      textAlign,
      maxLines,
      maxWidth,
      fallbackFonts,
    );
    if (_cache.length >= 1000) {
      _cache.clear();
    }
    return _cache[key] ??= _CachedMeasurement(
      text,
      style,
      direction,
      textAlign,
      maxLines,
      maxWidth,
      fallbackFonts,
    );
  }

  static String _generateKey(
    String text,
    TextStyle style,
    TextDirection direction,
    TextAlign textAlign,
    int? maxLines,
    double maxWidth,
    List<String>? fallbackFonts,
  ) {
    return '$text|${style.hashCode}|$direction|$textAlign|$maxLines|$maxWidth|${fallbackFonts?.join(',')}';
  }

  static double getWidth(
    String text,
    TextStyle style,
    TextDirection direction,
    TextAlign textAlign,
    int? maxLines,
    double maxWidth, [
    List<String>? fallbackFonts,
  ]) {
    return _getCachedMeasurement(
      text,
      style,
      direction,
      textAlign,
      maxLines,
      maxWidth,
      fallbackFonts,
    ).width;
  }

  static double getHeight(
    String text,
    TextStyle style,
    TextDirection direction,
    TextAlign textAlign,
    int? maxLines,
    double maxWidth, [
    List<String>? fallbackFonts,
  ]) {
    return _getCachedMeasurement(
      text,
      style,
      direction,
      textAlign,
      maxLines,
      maxWidth,
      fallbackFonts,
    ).height;
  }

  static TextPainter getPainter(
    String text,
    TextStyle style,
    TextDirection direction,
    TextAlign textAlign,
    int? maxLines,
    double maxWidth, [
    List<String>? fallbackFonts,
  ]) {
    return _getCachedMeasurement(
      text,
      style,
      direction,
      textAlign,
      maxLines,
      maxWidth,
      fallbackFonts,
    ).painter;
  }
}

class _CachedMeasurement {
  late final TextPainter painter;
  late final double width;
  late final double height;

  _CachedMeasurement(
    String text,
    TextStyle style,
    TextDirection direction,
    TextAlign textAlign,
    int? maxLines,
    double maxWidth,
    List<String>? fallbackFonts,
  ) {
    final effectiveStyle =
        fallbackFonts != null && fallbackFonts.isNotEmpty ? style.copyWith(fontFamilyFallback: fallbackFonts) : style;
    if (fallbackFonts != null && fallbackFonts.isNotEmpty) {
      debugPrint('TextMeasurementCache: Using font fallback for text: "$text"');
    }
    painter = TextPainter(
      text: TextSpan(text: text, style: effectiveStyle),
      textDirection: direction,
      textAlign: textAlign,
      maxLines: maxLines,
    );
    painter.layout(maxWidth: maxWidth);
    width = painter.width;
    height = painter.height;
  }
}

class LayoutUtils {
  static List<double> calculateCellWidths(
    ThermerTable table,
    double availableWidth,
    int numColumns,
  ) {
    List<double> actualWidths = [];
    if (table.cellWidths != null) {
      double totalFixed = 0;
      int nullCount = 0;
      for (int col = 0; col < numColumns; col++) {
        double? frac = table.cellWidths![col];
        if (frac != null) {
          totalFixed += frac;
        } else {
          nullCount++;
        }
      }
      double remaining = 1.0 - totalFixed;
      double nullFrac = nullCount > 0 ? remaining / nullCount : 0;
      for (int col = 0; col < numColumns; col++) {
        double? frac = table.cellWidths![col];
        actualWidths.add((frac ?? nullFrac) * availableWidth);
      }
    } else {
      double totalSpacing = (numColumns - 1) * table.columnSpacing;
      double cellWidth = (availableWidth - totalSpacing) / numColumns;
      actualWidths = List.filled(numColumns, cellWidth);
    }
    return actualWidths;
  }

  static double calculateWidgetWidth(
    ThermerWidget widget,
    double availableWidth, {
    TextDirection defaultTextDirection = TextDirection.ltr,
  }) {
    if (widget is ThermerText) {
      return TextMeasurementCache.getWidth(
        widget.data,
        widget.style ?? const TextStyle(),
        widget.direction ?? defaultTextDirection,
        widget.textAlign,
        widget.maxLines,
        availableWidth,
        widget.fallbackFonts,
      );
    } else if (widget is ThermerSizedBox) {
      return widget.width ?? availableWidth;
    } else if (widget is ThermerQRCode) {
      return widget.size;
    } else if (widget is ThermerImage) {
      return widget.width ?? availableWidth;
    } else if (widget is ThermerExpanded) {
      return calculateWidgetWidth(widget.child, availableWidth, defaultTextDirection: defaultTextDirection);
    } else if (widget is ThermerFlexible) {
      return calculateWidgetWidth(widget.child, availableWidth, defaultTextDirection: defaultTextDirection);
    } else if (widget is ThermerAlign) {
      return availableWidth;
    }

    return availableWidth;
  }

  static double calculateWidgetHeight(
    ThermerWidget widget,
    double maxWidth, {
    TextDirection defaultTextDirection = TextDirection.ltr,
  }) {
    if (widget is ThermerText) {
      return TextMeasurementCache.getHeight(
        widget.data,
        widget.style ?? const TextStyle(),
        widget.direction ?? defaultTextDirection,
        widget.textAlign,
        widget.maxLines,
        maxWidth,
        widget.fallbackFonts,
      );
    } else if (widget is ThermerRow) {
      double maxHeight = 0;
      for (final child in widget.children) {
        final childHeight = calculateWidgetHeight(child, maxWidth, defaultTextDirection: defaultTextDirection);
        if (childHeight > maxHeight) maxHeight = childHeight;
      }
      return maxHeight;
    } else if (widget is ThermerColumn) {
      double totalHeight = 0;
      for (int i = 0; i < widget.children.length; i++) {
        totalHeight += calculateWidgetHeight(widget.children[i], maxWidth, defaultTextDirection: defaultTextDirection);
        if (i < widget.children.length - 1) totalHeight += widget.spacing;
      }
      return totalHeight;
    } else if (widget is ThermerTable) {
      final numColumns = widget.data.isNotEmpty ? widget.data[0].cells.length : (widget.header?.cells.length ?? 0);
      final actualWidths = calculateCellWidths(widget, maxWidth, numColumns);

      double totalHeight = 0;

      double borderHeight = 0;
      if (widget.enableHeaderBorders && widget.header != null) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.horizontalBorderChar,
            style: TextStyle(fontSize: 20, color: Color(0xFF000000), fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: maxWidth);
        borderHeight = textPainter.height;
      }

      if (widget.header != null) {
        if (widget.enableHeaderBorders) {
          totalHeight += borderHeight;
        }
        double rowHeight = 0;
        for (int col = 0; col < widget.header!.cells.length; col++) {
          final cell = widget.header!.cells[col];
          final cellWidth = actualWidths[col];
          final cellHeight = calculateWidgetHeight(cell, cellWidth, defaultTextDirection: defaultTextDirection);
          if (cellHeight > rowHeight) rowHeight = cellHeight;
        }
        totalHeight += rowHeight;
        if (widget.enableHeaderBorders) {
          totalHeight += widget.rowSpacing + borderHeight;
        } else {
          totalHeight += widget.rowSpacing;
        }
      }

      for (int i = 0; i < widget.data.length; i++) {
        double rowHeight = 0;
        for (int col = 0; col < widget.data[i].cells.length; col++) {
          final cell = widget.data[i].cells[col];
          final cellWidth = actualWidths[col];
          final cellHeight = calculateWidgetHeight(cell, cellWidth, defaultTextDirection: defaultTextDirection);
          if (cellHeight > rowHeight) rowHeight = cellHeight;
        }
        totalHeight += rowHeight;
        if (i < widget.data.length - 1) totalHeight += widget.rowSpacing;
      }
      return totalHeight;
    } else if (widget is ThermerDivider) {
      if (widget.isHorizontal) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.character,
            style: TextStyle(fontSize: 20, color: Color(0xFF000000), fontWeight: FontWeight.w500),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: maxWidth);
        return textPainter.height;
      } else {
        return (widget.length ?? 1) * 20.0;
      }
    } else if (widget is ThermerQRCode) {
      return widget.size;
    } else if (widget is ThermerImage) {
      return widget.height ?? ((widget.width ?? maxWidth) / widget.image.width) * widget.image.height;
    } else if (widget is ThermerSizedBox) {
      return widget.height ??
          (widget.child != null
              ? calculateWidgetHeight(widget.child!, maxWidth, defaultTextDirection: defaultTextDirection)
              : 0);
    } else if (widget is ThermerExpanded) {
      return calculateWidgetHeight(widget.child, maxWidth, defaultTextDirection: defaultTextDirection);
    } else if (widget is ThermerFlexible) {
      return calculateWidgetHeight(widget.child, maxWidth, defaultTextDirection: defaultTextDirection);
    } else if (widget is ThermerAlign) {
      return calculateWidgetHeight(widget.child, maxWidth, defaultTextDirection: defaultTextDirection);
    }
    return 0;
  }
}
