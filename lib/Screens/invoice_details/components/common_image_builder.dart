import 'package:flutter/material.dart';

Widget buildInvoiceLogo({required ImageProvider image}) {
  return Container(
    height: 120,
    width: 120,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(fit: BoxFit.cover, image: image),
    ),
  );
}
