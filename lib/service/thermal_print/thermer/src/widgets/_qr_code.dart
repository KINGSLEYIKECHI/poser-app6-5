import 'package:qr_flutter/qr_flutter.dart';

import '_base_widget.dart';

class ThermerQRCode extends ThermerWidget {
  final String data;
  final double size;
  final int errorCorrectionLevel;

  const ThermerQRCode({
    required this.data,
    this.size = 100.0,
    this.errorCorrectionLevel = QrErrorCorrectLevel.L,
  });
}
