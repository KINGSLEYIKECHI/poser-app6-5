import '_base_widget.dart';
import '_enums.dart';

class ThermerColumn extends ThermerWidget {
  final List<ThermerWidget> children;

  final ThermerMainAxisAlignment mainAxisAlignment;

  final ThermerCrossAxisAlignment crossAxisAlignment;

  final double spacing;

  const ThermerColumn({
    required this.children,
    this.mainAxisAlignment = ThermerMainAxisAlignment.start,
    this.crossAxisAlignment = ThermerCrossAxisAlignment.start,
    this.spacing = 3,
  });
}
