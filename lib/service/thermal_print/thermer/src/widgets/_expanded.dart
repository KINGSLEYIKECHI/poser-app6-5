import '_base_widget.dart';

class ThermerExpanded extends ThermerWidget {
  final ThermerWidget child;
  final int flex;

  const ThermerExpanded({
    required this.child,
    this.flex = 1,
  }) : assert(flex > 0, 'flex must be greater than 0');
}
