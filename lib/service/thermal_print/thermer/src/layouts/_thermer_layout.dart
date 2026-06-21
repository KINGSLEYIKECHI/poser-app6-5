import 'dart:typed_data' as type;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '_shared_types.dart';
import '_thermer_painter.dart';
import '_layout_utils.dart';
import '../widgets/widgets.export.dart';

class PaperSize {
  const PaperSize._(this._width);

  static const mm58 = PaperSize._(58.0);
  static const mm80 = PaperSize._(80.0);
  static const mm110 = PaperSize._(110.0);

  const PaperSize.custom(double width) : _width = width;

  final double _width;

  double get width => _width;
}

/// Main class for creating thermal printer layouts from widgets.
/// Handles layout calculation, rendering to image, and conversion to byte data.
class ThermerLayout {
  /// The list of widgets to include in the layout.
  final List<ThermerWidget> widgets;

  /// The paper size for the thermal printer.
  final PaperSize paperSize;

  /// Dots per inch for the printer resolution.
  final double dpi;

  /// Gap between layout items.
  final double layoutGap;

  /// Whether to convert the output to black and white.
  final bool blackAndWhite;

  /// Horizontal margin in millimeters to account for printer limitations.
  final double marginMm;

  /// The default text direction for the layout.
  final TextDirection textDirection;

  const ThermerLayout({
    required this.widgets,
    this.paperSize = PaperSize.mm80,
    double? dpi,
    this.layoutGap = 3.0,
    this.blackAndWhite = false,
    double? marginMm,
    this.textDirection = TextDirection.ltr,
  })  : dpi = dpi ?? 203.0,
        marginMm = marginMm ?? 5.0;

  double get width => ((paperSize.width - (marginMm * 2)) / 25.4) * dpi;

  // Process layout and calculate heights in one pass
  List<LayoutItem> _processLayout() {
    return widgets.map((widget) {
      final height = _calculateHeight(widget);
      return LayoutItem(widget: widget, height: height);
    }).toList();
  }

  double _calculateHeight(ThermerWidget widget) {
    // subtract margins from width to get printable area
    final printableWidth = width;
    final height = LayoutUtils.calculateWidgetHeight(widget, printableWidth, defaultTextDirection: textDirection);
    if (height == 0 && widget is ThermerText) {
      throw Exception('ThermerText height is 0 for text: "${widget.data}"');
    }
    return height;
  }

  double _calculateTotalHeight(List<LayoutItem> items) {
    double total = 0;
    for (int i = 0; i < items.length; i++) {
      total += items[i].height;
      if (i < items.length - 1) total += layoutGap;
    }
    return total;
  }

  // Public API methods
  Future<type.Uint8List> toUint8List() => generateImage();

  Future<type.Uint8List> generateImage() async {
    TextMeasurementCache.clear();

    if (widgets.isEmpty) {
      throw Exception('No widgets provided to ThermerLayout');
    }

    final layoutItems = _processLayout();
    final totalHeight = _calculateTotalHeight(layoutItems);

    if (totalHeight <= 1) {
      throw Exception('Total height is $totalHeight, cannot generate image');
    }

    if (width <= 0 || width > 10000) {
      throw Exception('Invalid width: $width. Must be > 0 and <= 10000');
    }

    if (totalHeight <= 0 || totalHeight > 10000) {
      throw Exception('Invalid height: $totalHeight. Must be > 0 and <= 10000');
    }

    debugPrint('ThermerLayout: Generating image with size ${width.toInt()}x${totalHeight.toInt()}');

    final size = ui.Size(width, totalHeight);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // Draw white background
    final paint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final painter = ThermerPainter(layoutItems, layoutGap: layoutGap, textDirection: textDirection);
    painter.paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var bytes = byteData!.buffer.asUint8List();

    if (blackAndWhite) {
      debugPrint('ThermerLayout: Converting image to black and white');
      // Decode the PNG
      final decodedImage = img.decodePng(bytes);
      if (decodedImage != null) {
        // Convert to monochrome (1-bit)
        final monoImage = img.monochrome(decodedImage);
        // Encode back to PNG
        bytes = img.encodePng(monoImage);
        debugPrint('ThermerLayout: B&W conversion completed');
      } else {
        debugPrint('ThermerLayout: Failed to decode image for B&W conversion');
      }
    }

    return bytes;
  }
}
