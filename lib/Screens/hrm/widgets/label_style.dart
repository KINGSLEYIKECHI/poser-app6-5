import 'package:flutter/material.dart';

Widget labelSpan({required String title, required BuildContext context}) {
  final _theme = Theme.of(context);
  return Text.rich(
    TextSpan(text: title, children: [
      TextSpan(
        text: '*',
        style: TextStyle(color: Colors.red),
      )
    ]),
    style: _theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w500,
    ),
  );
}
