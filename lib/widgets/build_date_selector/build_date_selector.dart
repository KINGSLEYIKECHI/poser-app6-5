// Helper method
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../constant.dart';

Widget buildDateSelector({required String prefix, required String date, required ThemeData theme}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              text: '$prefix: ',
              style: TextStyle(fontWeight: FontWeight.w500),
              children: [
                TextSpan(text: date),
              ],
            ),
            style: theme.textTheme.bodyMedium,
          ),
          Icon(
            IconlyLight.calendar,
            color: kPeraColor,
          ),
        ],
      ),
    ],
  );
}
