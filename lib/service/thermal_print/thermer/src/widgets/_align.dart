import '_base_widget.dart';
import '_enums.dart';

class ThermerAlign extends ThermerWidget {
  final ThermerWidget child;
  final ThermerAlignment alignment;

  const ThermerAlign({
    required this.child,
    this.alignment = ThermerAlignment.center,
  });
}