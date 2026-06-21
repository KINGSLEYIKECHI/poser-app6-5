import '_base_widget.dart';
import '_enums.dart';

class ThermerRow extends ThermerWidget {
  final List<ThermerWidget> children;

  final ThermerMainAxisAlignment mainAxisAlignment;

  final ThermerCrossAxisAlignment crossAxisAlignment;

  final double spacing;

  const ThermerRow({
    required this.children,
    this.mainAxisAlignment = ThermerMainAxisAlignment.start,
    this.crossAxisAlignment = ThermerCrossAxisAlignment.center,
    this.spacing = 0,
  });
}
