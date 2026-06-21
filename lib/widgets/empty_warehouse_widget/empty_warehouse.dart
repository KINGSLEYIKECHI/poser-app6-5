import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_pos/generated/l10n.dart' as l;

// Empty State Widget
Widget emptyWidget(ThemeData theme, BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        SvgPicture.asset('images/empty_image.svg', width: 319, height: 250),
        const SizedBox(height: 30),
        Text(
          l.S.of(context).oophItsEmptyInHere,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        Text(l.S.of(context).addSomeItemsFirst),
      ],
    ),
  );
}
