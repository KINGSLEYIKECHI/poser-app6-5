import '_base_widget.dart';

class ThermerSizedBox extends ThermerWidget {
  final double? width;

  final double? height;

  final ThermerWidget? child;

  const ThermerSizedBox({this.width, this.height, this.child});

  const ThermerSizedBox.square({
    double dimension = 0,
    this.child,
  })  : width = dimension,
        height = dimension;
}
