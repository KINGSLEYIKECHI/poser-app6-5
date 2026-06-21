import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';

Widget globalDottedLine({double? height, double? width, Color? borderColor, int? generatedLine}) {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: NeverScrollableScrollPhysics(),
    child: Row(
      spacing: 2,
      children: List.generate(generatedLine ?? 80, (index) {
        return Container(
          height: height ?? 1,
          width: width ?? 4,
          color: borderColor ?? kBorderColor,
        );
      }),
    ),
  );
}
