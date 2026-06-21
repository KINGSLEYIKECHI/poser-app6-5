import '_base_widget.dart';

enum ThermerFlexFit { tight, loose }

class ThermerFlexible extends ThermerWidget {
  final ThermerWidget child;
  final int flex;
  final ThermerFlexFit fit;

  const ThermerFlexible({
    required this.child,
    this.flex = 1,
    this.fit = ThermerFlexFit.loose,
  }) : assert(flex > 0, 'flex must be greater than 0');
}
