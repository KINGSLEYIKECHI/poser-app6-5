import 'package:pdf/widgets.dart' as pw;

/// Helper class for creating RTL-aware tables
class RtlTableHelper {
  /// Reverses column widths map for RTL
  static Map<int, pw.TableColumnWidth> reverseColumnWidths(
    Map<int, pw.TableColumnWidth> widths, {
    required bool isRTL,
  }) {
    if (!isRTL) return widths;

    final entries = widths.entries.toList(growable: false);
    final reversed = <int, pw.TableColumnWidth>{};

    for (var i = 0; i < entries.length; i++) {
      reversed[i] = entries[entries.length - 1 - i].value;
    }

    return reversed;
  }

  /// Reverses children list for RTL
  static List<pw.Widget> reverseChildren(
    List<pw.Widget> children, {
    required bool isRTL,
  }) {
    return isRTL ? children.reversed.toList() : children;
  }

  /// Adjusts text alignment for RTL
  static pw.TextAlign adjustAlignment(pw.TextAlign align, bool isRTL) {
    if (!isRTL) return align;

    switch (align) {
      case pw.TextAlign.left:
        return pw.TextAlign.right;
      case pw.TextAlign.right:
        return pw.TextAlign.left;
      case pw.TextAlign.start:
        return pw.TextAlign.end;
      case pw.TextAlign.end:
        return pw.TextAlign.start;
      default:
        return align;
    }
  }

  /// Creates a table row with RTL support
  static pw.TableRow createRow({
    required List<pw.Widget> children,
    required bool isRTL,
    pw.BoxDecoration? decoration,
  }) {
    return pw.TableRow(
      decoration: decoration,
      children: isRTL ? children.reversed.toList() : children,
    );
  }

  /// Creates column widths map for RTL
  static Map<int, pw.TableColumnWidth> createColumnWidths({
    required List<pw.TableColumnWidth> widths,
    required bool isRTL,
  }) {
    final map = <int, pw.TableColumnWidth>{};
    final effectiveWidths = isRTL ? widths.reversed.toList() : widths;
    for (var i = 0; i < effectiveWidths.length; i++) {
      map[i] = effectiveWidths[i];
    }
    return map;
  }

  /// Creates a table with RTL support
  static pw.Widget createTable({
    required List<pw.TableRow> children,
    required Map<int, pw.TableColumnWidth> columnWidths,
    required bool isRTL,
    pw.TableBorder? border,
  }) {
    final effectiveColumnWidths = isRTL ? reverseColumnWidths(columnWidths, isRTL: isRTL) : columnWidths;

    return pw.Table(
      border: border,
      columnWidths: effectiveColumnWidths,
      children: children,
    );
  }
}
